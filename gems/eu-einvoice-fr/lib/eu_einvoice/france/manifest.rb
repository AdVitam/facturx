# frozen_string_literal: true

require 'digest'
require 'eu_einvoice/specification'
require 'eu_einvoice/france/rule_resources'
require 'eu_einvoice/france/document_types'
require 'eu_einvoice/france/licensing'

module EuEinvoice
  module France
    module Manifest
      ROOT = File.expand_path('../schema', __dir__).freeze
      CHECKSUMS = File.readlines(File.join(ROOT, 'SHA256SUMS'), chomp: true).to_h do |line|
        digest, path = line.split(/\s+/, 2)
        [path.freeze, digest.freeze]
      end.freeze

      class << self
        def for_profile(profile, version:)
          {
            semantic_standard: 'EN 16931', semantic_version: '2017', syntax: :cii,
            syntax_version: 'D22B', jurisdiction: 'FR', document_types: DOCUMENT_TYPES.fetch(profile.id),
            profile: profile.id, artifact_version: version, container: :pdf_a3, required_inputs: [:pdf],
            dependencies: %w[eu-einvoice-syntax-cii eu-einvoice-container-pdf],
            rules: %i[document xsd schematron], code_lists: code_lists(profile, version),
            optional_resources: rule_resources(profile, version),
            effective_from: '2026-09-01', based_on: 'EN 16931:2017',
            resources: resources(profile, version)
          }.merge(entrypoints(profile, version)).merge(provenance)
        end

        def entrypoints(profile, version)
          schemas = resources(profile, version)
          rules = rule_resources(profile, version)
          {
            schema_entrypoint: schemas.keys.find do |path|
              path.end_with?("_#{profile.conformance_level.tr(' ', '')}.xsd")
            end,
            rule_entrypoint: rules.keys.find { |path| path.end_with?('.xslt') },
            code_list_entrypoint: rules.keys.find { |path| path.end_with?('_codedb.xml') },
            licensing: Licensing::CHECKSUMS
          }
        end

        def provenance
          {
            license: 'Apache-2.0',
            source: 'https://github.com/atgp/factur-x/tree/v3.5.0/xsd/factur-x',
            source_revision: 'b448a57074973ab57048aac8f2d208a516d685d9',
            official_source: 'https://www.ferd-net.de/en/downloads/publications/details/zugferd-252-english',
            adaptations: 'schema/NOTICE.md'
          }
        end

        def resources(profile, version)
          prefix = "#{version}/#{profile.id.to_s.tr('_', '-')}/"
          CHECKSUMS.select { |path, _digest| path.start_with?(prefix) }.freeze
        end

        def rule_resources(profile, version)
          prefix = "#{version}/#{profile.id.to_s.tr('_', '-')}/"
          RULE_RESOURCES.select { |path, _digest| path.start_with?(prefix) }.freeze
        end

        def code_lists(profile, version)
          rule_resources(profile, version).select { |path, _digest| path.end_with?('_codedb.xml') }
        end
      end
    end
  end
end
