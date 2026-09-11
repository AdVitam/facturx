# frozen_string_literal: true

require 'nokogiri'
require 'digest'

require_relative '../embedding'
require_relative '../error'

module Facturx
  module Pdf
    class Verifier
      PDFA_NAMESPACE = 'http://www.aiim.org/pdfa/ns/id/'
      RDF_NAMESPACE = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
      XMP_META_NAMESPACE = 'adobe:ns:meta/'
      XMP_NAMESPACES = {
        'fx' => FACTURX_EMBEDDING.xmp_namespace,
        'pdfaid' => PDFA_NAMESPACE,
        'rdf' => RDF_NAMESPACE,
        'x' => XMP_META_NAMESPACE
      }.freeze
      DESCRIPTION_XPATH = '/x:xmpmeta/rdf:RDF/rdf:Description'
      XMPField = Data.define(:xpath, :expected)
      XMP_FIELDS = {
        pdfa_part: XMPField.new(
          xpath: "#{DESCRIPTION_XPATH}/pdfaid:part | " \
                 "#{DESCRIPTION_XPATH}/@pdfaid:part",
          expected: '3'
        ),
        pdfa_conformance: XMPField.new(
          xpath: "#{DESCRIPTION_XPATH}/pdfaid:conformance | " \
                 "#{DESCRIPTION_XPATH}/@pdfaid:conformance",
          expected: 'B'
        ),
        document_filename: XMPField.new(
          xpath: "#{DESCRIPTION_XPATH}/fx:DocumentFileName", expected: FACTURX_EMBEDDING.filename
        ),
        document_type: XMPField.new(
          xpath: "#{DESCRIPTION_XPATH}/fx:DocumentType", expected: FACTURX_EMBEDDING.document_type
        ),
        facturx_version: XMPField.new(
          xpath: "#{DESCRIPTION_XPATH}/fx:Version", expected: FACTURX_EMBEDDING.version
        )
      }.freeze
      CONFORMANCE_LEVEL_XPATH = "#{DESCRIPTION_XPATH}/fx:ConformanceLevel".freeze
      private_constant :XMPField

      def call(result:, expected_xml:, expected_page_count:, profile:)
        verify_result!(result, expected_xml, expected_page_count)
        xmp = parse_xmp(result.metadata)
        verify_xmp!(xmp, profile)
        true
      end

      private

      def verify_xmp!(xmp, profile)
        XMP_FIELDS.each do |field, definition|
          verify_xmp_value!(xmp, field, definition.xpath, definition.expected)
        end
        verify_xmp_value!(xmp, :facturx_conformance_level, CONFORMANCE_LEVEL_XPATH, profile.conformance_level)
      end

      def verify_result!(result, expected_xml, expected_page_count)
        verify_xml!(result.xml, expected_xml)
        verify_value!(:filename, result.filename, FACTURX_EMBEDDING.filename)
        verify_value!(:relationship, result.relationship, FACTURX_EMBEDDING.relationship)
        verify_value!(:page_count, result.page_count, expected_page_count)
      end

      def verify_xml!(actual, expected)
        unless actual.is_a?(String) && expected.is_a?(String)
          raise VerificationError.new('PDF verification input is invalid', reason: :invalid_input, field: :xml)
        end
        return if actual.b == expected.b

        raise VerificationError.new('Composed PDF does not contain the requested XML bytes',
                                    reason: :result_mismatch, field: :xml, **xml_details(actual, expected))
      end

      def xml_details(actual, expected)
        {
          expected_sha256: Digest::SHA256.hexdigest(expected),
          actual_sha256: Digest::SHA256.hexdigest(actual),
          expected_size: expected.bytesize,
          actual_size: actual.bytesize
        }
      end

      def parse_xmp(metadata)
        raise VerificationError.new('PDF XMP metadata is missing', reason: :missing_xmp) unless metadata.is_a?(String)

        Nokogiri::XML(metadata) { |config| config.strict.nonet }
      rescue Nokogiri::XML::SyntaxError => e
        raise VerificationError.new('PDF XMP metadata is invalid', reason: :invalid_xmp, cause: e.class.name)
      end

      def verify_xmp_value!(xmp, field, xpath, expected)
        values = xmp.xpath(xpath, XMP_NAMESPACES).map(&:text)
        return if values.one? && values.first == expected

        raise VerificationError.new('PDF XMP metadata does not match Factur-X requirements',
                                    reason: :xmp_mismatch, field:, expected:, actual: xmp_value(values))
      end

      def xmp_value(values)
        values.one? ? values.first : values
      end

      def verify_value!(field, actual, expected)
        return if actual == expected

        raise VerificationError.new('Composed PDF does not match the requested Factur-X document',
                                    reason: :result_mismatch, field:, expected:, actual:)
      end
    end
  end
end
