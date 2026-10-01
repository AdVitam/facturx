# frozen_string_literal: true

require 'eu_einvoice/resolution'

module EuEinvoice
  class Resolver
    def initialize(specifications:, policy:, owner:)
      @specifications = specifications
      @policy = policy
      @owner = owner
      freeze
    end

    def call(document:, specification: nil, requirements: RecipientRequirements.new)
      raise TypeError, 'document must be a Document' unless document.is_a?(Document)
      raise TypeError, 'requirements must be RecipientRequirements' unless requirements.is_a?(RecipientRequirements)

      requested = specification || @policy.preferred_id(document)
      candidates = select_candidates(document, requested).select { |candidate| requirements.accepts?(candidate) }
      status = status_for(candidates, requested || requirements.constrains_format?)
      result(document, requirements, candidates, status, requested)
    end

    private

    def result(document, requirements, candidates, status, requested)
      diagnostics = requirements.diagnostics(document)
      status = :missing_information if status == :resolved && !diagnostics.empty?
      resolved = candidates.first if status == :resolved
      Resolution.new(status:, specification: resolved, candidates: candidates.map(&:id),
                     required_inputs: required_inputs(resolved), requirements:, diagnostics:,
                     explanation: explanation(status, requested),
                     fingerprint: DocumentFingerprint.call(document), owner: @owner)
    end

    def required_inputs(specification)
      specification ? specification.manifest.fetch(:required_inputs, []) : []
    end

    def select_candidates(document, requested)
      @specifications.select do |candidate|
        matches_request?(candidate, requested) && matches_document?(candidate, document)
      end
    end

    def matches_request?(candidate, requested)
      return true unless requested
      return candidate.fingerprint == requested.fingerprint if requested.is_a?(Specification)

      candidate.id == requested
    end

    def matches_document?(candidate, document)
      guideline = document.guideline_urn
      matches_guideline = guideline.nil? || guideline.empty? || candidate.guideline_urn == guideline
      types = candidate.manifest.fetch(:document_types)
      matches_guideline && document.semantic_version == candidate.semantic_version &&
        (document.type_code.nil? || types.include?(document.type_code))
    end

    def status_for(candidates, requested)
      return :unsupported if candidates.empty?
      return :missing_information unless requested
      return :ambiguous unless candidates.one?

      :resolved
    end

    def explanation(status, requested)
      case status
      when :resolved then resolved_explanation(requested)
      when :unsupported then 'No installed specification satisfies the requested identity and declared guideline'
      when :ambiguous then 'Several installed versions match; select an exact specification'
      else 'Configure a country-pair preference or provide an explicit specification'
      end
    end

    def resolved_explanation(requested)
      return 'Declared recipient format requirements' unless requested

      requested.is_a?(Specification) ? 'Explicit specification' : 'Configured specification preference'
    end
  end
end
