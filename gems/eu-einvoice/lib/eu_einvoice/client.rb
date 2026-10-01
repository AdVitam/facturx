# frozen_string_literal: true

require 'eu_einvoice/resolver'
require 'eu_einvoice/client/reading'
require 'eu_einvoice/client/writing'

module EuEinvoice
  class Client
    include ClientReading
    include ClientWriting

    attr_reader :specifications, :limits, :validation

    def initialize(packs:, policy: Policy.new, validation: :full, limits: ResourceLimits.new, instrumenter: nil)
      raise ArgumentError, 'Unknown validation coverage' unless %i[full structural].include?(validation)

      @limits = limits
      @validation = validation
      @instrumenter = instrumenter
      configure_packs(packs)
      @owner = Object.new.freeze
      @resolver = Resolver.new(specifications:, policy: policy || Policy.new, owner: @owner)
      freeze
    end

    def resolve(document:, specification: nil, requirements: RecipientRequirements.new)
      @resolver.call(document:, specification:, requirements:)
    end

    private

    def configure_packs(packs)
      raise ArgumentError, 'At least one pack is required' if packs.empty?

      @packs = packs.dup.freeze
      @specifications = @packs.flat_map(&:specifications).freeze
      verify_unique_specifications!
      @adapters = @packs.to_h { |pack| [pack, pack.adapter(validation:, limits:)] }.freeze
    end

    def verify_unique_specifications!
      identities = specifications.map { |spec| [spec.id, spec.version] }
      return if identities.uniq.size == identities.size

      raise ArgumentError, 'Duplicate specification identity/version in client packs'
    end

    def pack_for(specification, capability: nil)
      raise TypeError, 'specification must be a Specification' unless specification.is_a?(Specification)

      pack = @packs.find { |item| item.specifications.any? { |spec| spec.fingerprint == specification.fingerprint } } ||
             raise(ResolutionError.new('Specification is not installed in this client',
                                       specification: specification.id))
      return pack unless capability && !pack.respond_to?(capability)

      raise ResolutionError.new('Pack does not provide the required capability', specification: specification.id,
                                                                                 capability:)
    end

    def instrument(event, payload = {}, &)
      return yield unless @instrumenter

      @instrumenter.call(event, payload.merge(validation:), &)
    end

    def resolve!(document, specification, resolution)
      raise TypeError, 'specification must be a Specification' if specification && !specification.is_a?(Specification)

      result = resolution || new_resolution!(document, specification)
      result.verify!(document, @owner) if resolution
      if specification && result.specification.fingerprint != specification.fingerprint
        raise ResolutionError.new('Explicit specification conflicts with resolution', reason: :conflict)
      end

      result.specification
    end

    def new_resolution!(document, specification)
      result = resolve(document:, specification:)
      return result if result.resolved?

      raise ResolutionError.new('Document does not resolve to a usable specification', status: result.status,
                                                                                       diagnostics: result.diagnostics)
    end

    def document_for_write(document, allow_loss:)
      return document unless document.is_a?(Reading)
      return document.document if document.diagnostics.empty? || allow_loss

      raise InvalidDocumentError.new('Reading contains diagnostics requiring an explicit loss decision',
                                     reason: :reading_diagnostics, diagnostics: document.diagnostics)
    end
  end
end
