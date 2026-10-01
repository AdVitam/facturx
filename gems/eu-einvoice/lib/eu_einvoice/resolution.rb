# frozen_string_literal: true

require 'digest'
require 'eu_einvoice/error'
require 'eu_einvoice/model/immutable'

module EuEinvoice
  class ResolutionError < Error; end
  class AmbiguousSpecificationError < ResolutionError; end

  module DocumentFingerprint
    module_function

    def call(document)
      digest = Digest::SHA256.new
      append(digest, document)
      digest.hexdigest
    end

    def append(digest, value)
      case value
      when Data then append_data(digest, value)
      when Hash then append_hash(digest, value)
      when Array
        token(digest, 'array', value.size.to_s)
        value.each { |item| append(digest, item) }
      else scalar(digest, value)
      end
    end

    def append_data(digest, value)
      token(digest, 'data', value.class.name.to_s)
      token(digest, 'members', value.members.size.to_s)
      value.to_h.each do |key, item|
        next if item.nil?

        token(digest, 'Symbol', key.name)
        append(digest, item)
      end
      token(digest, 'end_data', '')
    end

    def append_hash(digest, value)
      token(digest, 'hash', value.size.to_s)
      value.sort_by { |key, _| [key.class.name, key.to_s] }.each do |key, item|
        append(digest, key)
        append(digest, item)
      end
    end

    def scalar(digest, value)
      case value
      when BigDecimal then token(digest, 'decimal', value.to_s('F'))
      when Date then token(digest, 'date', value.iso8601)
      else token(digest, value.class.name, value.to_s)
      end
    end

    def token(digest, type, bytes)
      digest << type << ':' << bytes.bytesize.to_s << ':' << bytes
    end
  end

  Resolution = Data.define(:status, :specification, :candidates, :required_inputs, :explanation, :fingerprint,
                           :owner, :requirements, :diagnostics) do
    def initialize(status:, explanation:, fingerprint:, owner:, **attributes)
      attributes = { specification: nil, candidates: [], required_inputs: [],
                     requirements: RecipientRequirements.new, diagnostics: [] }.merge(attributes)
      super(**Model.copy_and_freeze(attributes), status:, explanation: explanation.dup.freeze,
                                                 fingerprint: fingerprint.dup.freeze, owner:)
    end

    def resolved? = status == :resolved

    def verify!(document, expected_owner)
      return if resolved? && owner.equal?(expected_owner) && fingerprint == DocumentFingerprint.call(document)

      raise ResolutionError.new('Resolution is unresolved or does not match this operation', status:)
    end
  end
end
