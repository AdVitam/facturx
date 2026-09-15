# frozen_string_literal: true

module EuEinvoice
  module ClientReading
    def read(source, specification: nil, on_unknown_profile: :fallback)
      bytes = Source.read(source, limit: limits.pdf_bytes)
      source_type = pdf?(bytes) ? :pdf : :xml
      input = prepare_xml(xml_source(bytes, source_type, specification))
      instrument(:read, source_type:, bytes: bytes.bytesize) do
        read_input(input, specification, on_unknown_profile).with(source_type:)
      end
    end

    def validate_xml(xml:, specification: nil)
      bytes = Source.read(xml, limit: limits.xml_bytes)
      input = prepare_xml(bytes)
      selected = detect_specification(input, specification)
      instrument(:validate_xml, specification: selected.id, bytes: bytes.bytesize) do
        adapter = @adapters.fetch(pack_for(selected))
        adapter.validate_xml(xml: bytes, specification: selected, context: input.contexts.fetch(adapter))
      end
    rescue InvalidXmlError => e
      invalid_xml_report(e, specification)
    end

    def extract_xml(pdf:, specification: nil)
      bytes = Source.read(pdf, limit: limits.pdf_bytes)
      instrument(:extract_xml, bytes: bytes.bytesize) do
        xml = extraction_provider(specification).extract_xml(pdf: bytes, limits:)
        limits.check!(:xml_bytes, xml.bytesize)
        Artifact.new(bytes: xml, content_type: 'application/xml', filename: 'invoice.xml')
      end
    end

    private

    def extraction_provider(specification)
      return pack_for(specification) if specification

      providers = @packs.select { |pack| pack.respond_to?(:extract_xml) }
      raise ResolutionError, 'No PDF container is installed' if providers.empty?
      raise AmbiguousSpecificationError, 'Several PDF extraction providers are installed' unless providers.one?

      providers.first
    end

    def xml_source(bytes, source_type, specification)
      xml = source_type == :pdf ? extract_xml(pdf: bytes, specification:).bytes : bytes
      Source.read(xml, limit: limits.xml_bytes)
    end

    def read_input(input, specification, on_unknown_profile)
      selected = detect_specification(input, specification, allow_unknown: on_unknown_profile == :fallback)
      adapter = selected ? @adapters.fetch(pack_for(selected)) : unknown_adapter(input)
      adapter.read(input.xml, specification: selected, on_unknown_profile:, context: input.contexts.fetch(adapter))
    end

    def pdf?(bytes)
      Source.pdf?(bytes)
    end

    PreparedInput = Data.define(:xml, :contexts, :candidates)

    def prepare_xml(xml)
      by_syntax = {}
      contexts = @adapters.to_h do |pack, adapter|
        syntax = pack.specifications.map(&:syntax).uniq.sort
        [adapter, by_syntax[syntax] ||= adapter.prepare(xml:)]
      end
      candidates = contexts.flat_map { |adapter, context| adapter.detect(xml:, context:) }
      PreparedInput.new(xml:, contexts: contexts.freeze, candidates: candidates.freeze)
    end

    def detect_specification(input, hint, allow_unknown: false)
      raise TypeError, 'specification must be a Specification' if hint && !hint.is_a?(Specification)

      candidates = matching_candidates(input, hint)
      return candidates.first if candidates.one?
      return nil if candidates.empty? && allow_unknown && hint.nil?

      unresolved_input!(candidates)
    end

    def matching_candidates(input, hint)
      return input.candidates unless hint

      input.candidates.select { |candidate| candidate.fingerprint == hint.fingerprint }
    end

    def unresolved_input!(candidates)
      error = candidates.empty? ? UnknownProfileError : AmbiguousSpecificationError
      raise error.new('XML does not resolve to one installed specification', candidates: candidates.map(&:id))
    end

    def unknown_adapter(input)
      candidates = input.contexts.filter_map do |adapter, context|
        adapter if adapter.can_read?(xml: input.xml, context:)
      end
      return candidates.first if candidates.one?

      raise AmbiguousSpecificationError.new('Cannot select a unique tolerant reader', candidates: candidates.size)
    end

    def invalid_xml_report(error, specification)
      profile_error = error.is_a?(UnknownProfileError)
      layer = profile_error ? :profile : :syntax
      issue = Validation::Issue.new(code: profile_error ? :unknown_profile : :invalid_xml,
                                    message: error.message, layer:, details: error.details)
      Validation::Report.new(issues: [issue], specification:, requested_coverage: validation,
                             executed_steps: profile_error ? %i[syntax profile] : [:syntax])
    end
  end
end
