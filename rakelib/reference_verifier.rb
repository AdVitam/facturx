# frozen_string_literal: true

require 'digest'
require_relative '../lib/facturx'

module Facturx
  class ReferenceVerifier
    KNOWN_PAIR_MISMATCHES = {
      '3. EN16931/E04_Betriebskostenabrechnung_NEU/E04_01_Betriebskostenabrechnung_NEU.xml' => %w[
        15d37a7fb0901316c1dbd5037e64f9a531fb994a536f0404db41fc733d2f2b47
        14b08cb538ea0556b8e6256dea832a326140307c4ad1d9457428e51267885730
      ],
      '3. EN16931/E14_Kraftfahrversicherung/E14_01_Kraftfahrversicherung.xml' => %w[
        d4e8931a28232305d8973263708717ce2f252d23aef89ddf0d2a63220791644f
        62e9834a192a1cb0f4dcf7be8cc179a942ff4c5066441da58a26755caa579c27
      ]
    }.transform_values(&:freeze).freeze
    EXPECTED_PROFILES = {
      '0. MINIMUM' => :minimum,
      '1. BASIC WL' => :basic_wl,
      '2. BASIC' => :basic,
      '3. EN16931' => :en16931,
      '4. EXTENDED' => :extended
    }.freeze
    INVALID_VALUE_CODES = %i[empty_value invalid_value].freeze

    def initialize(root:)
      @root = root
    end

    def call
      verify_reference_files
      verify_node_names
      paths = example_paths
      paths.each { |path| verify_example(path) }
      report(paths.size)
    end

    private

    def verify_reference_files
      Terms::REFERENCE_FILES.each_value do |relative_path, expected_sha256|
        path = File.join(@root, relative_path)
        raise "Missing reference file: #{relative_path}" unless File.file?(path)
        raise "Reference checksum mismatch: #{relative_path}" unless sha256(path) == expected_sha256
      end
    end

    def verify_node_names
      schema = schema_source
      (Terms.all + Terms.groups).each do |entry|
        xpath_names(entry).each do |name|
          raise "#{entry.id} references an unknown D22B node: #{name}" unless schema.include?(%(name="#{name}"))
        end
      end
    end

    def schema_source
      Dir[File.join(@root, 'Schema/5. CII D22B XSD/*.xsd')].map { |path| File.binread(path) }.join
    end

    def xpath_names(entry)
      entry.xpath.scan(%r{/(?:@)?(?:\w+:)?([\w-]+)}).flatten - ['CrossIndustryInvoice']
    end

    def example_paths
      paths = Dir[File.join(@root, 'Examples/[0-4]. */**/*.xml')]
      raise 'No official XML examples found' if paths.empty?

      paths
    end

    def verify_example(xml_path)
      xml = File.binread(xml_path)
      reading = Facturx.read(xml)
      Facturx.verify_xml(xml:) unless unknown_profile?(reading)
      verify_reading(xml_path, reading)
      verify_pdf_pair(xml_path, xml)
    end

    def verify_reading(xml_path, reading)
      profile = expected_profile(xml_path)
      raise "Profile mismatch: #{xml_path}" unless reading.profile.id == profile
      raise "Invoice number is not mapped: #{xml_path}" unless reading.document.invoice_number

      diagnostics = reading.diagnostics
      if profile == :extended
        diagnostics = diagnostics.select do |diagnostic|
          INVALID_VALUE_CODES.include?(diagnostic.code)
        end
      end
      raise "Semantic mapping diagnostics for #{xml_path}: #{diagnostics.map(&:code)}" unless diagnostics.empty?
    end

    def expected_profile(xml_path)
      directory = xml_path.delete_prefix("#{@root}/Examples/").split('/').first
      EXPECTED_PROFILES.fetch(directory)
    end

    def unknown_profile?(reading)
      reading.diagnostics.any? { |diagnostic| diagnostic.code == :unknown_profile }
    end

    def verify_pdf_pair(xml_path, xml)
      pdf_path = xml_path.sub(/\.xml\z/, '_fx.pdf')
      raise "Missing paired PDF: #{pdf_path}" unless File.file?(pdf_path)

      embedded_xml = Facturx.extract_xml(pdf: File.binread(pdf_path))
      verify_pair_hashes(xml_path, pdf_path, xml, embedded_xml) unless embedded_xml == xml
    end

    def verify_pair_hashes(xml_path, pdf_path, xml, embedded_xml)
      relative_path = xml_path.delete_prefix("#{@root}/Examples/")
      hashes = [Digest::SHA256.hexdigest(xml), Digest::SHA256.hexdigest(embedded_xml)]
      raise "Embedded XML differs: #{pdf_path}" unless KNOWN_PAIR_MISMATCHES[relative_path] == hashes
    end

    def sha256(path)
      Digest::SHA256.file(path).hexdigest
    end

    def report(count)
      puts "Verified #{count} official XML/PDF pairs (#{KNOWN_PAIR_MISMATCHES.size} pinned upstream mismatches)"
    end
  end
end
