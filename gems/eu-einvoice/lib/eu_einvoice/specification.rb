# frozen_string_literal: true

require 'digest'
require 'json'
require 'eu_einvoice/model/immutable'

module EuEinvoice
  Specification = Data.define(:id, :version, :profile, :manifest, :fingerprint) do
    include Model::ValidatedWith

    def initialize(id:, version:, profile:, manifest:, fingerprint: nil)
      raise ArgumentError, 'A specification needs an identity and version' if id.to_s.empty? || version.to_s.empty?

      manifest = Model.copy_and_freeze(manifest)
      id = Model.copy_and_freeze(id.to_s)
      version = Model.copy_and_freeze(version.to_s)
      calculated = Digest::SHA256.hexdigest(JSON.generate(canonical([id, version, profile.to_h, manifest])))
      verify_fingerprint!(fingerprint, calculated)

      super(id:, version:, profile:, manifest:, fingerprint: calculated.freeze)
    end

    def guideline_urn = profile.guideline_urn
    def semantic_version = manifest.fetch(:semantic_version)
    def syntax = manifest.fetch(:syntax)
    def jurisdiction = manifest.fetch(:jurisdiction)
    def resources = manifest.fetch(:resources)

    def with(**attributes)
      self.class.new(**to_h.except(:fingerprint), **attributes)
    end

    private

    def verify_fingerprint!(requested, calculated)
      return if requested.nil? || requested == calculated

      raise ArgumentError, 'Specification fingerprint does not match its manifest'
    end

    def canonical(value)
      case value
      when Hash then value.sort_by { |key, _| key.to_s }.map { |key, item| [key.to_s, canonical(item)] }
      when Array then value.map { |item| canonical(item) }
      else value
      end
    end
  end
end
