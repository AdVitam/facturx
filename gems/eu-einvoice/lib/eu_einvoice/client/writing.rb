# frozen_string_literal: true

module EuEinvoice
  module ClientWriting
    def validate_document(document:, specification: nil, resolution: nil, allow_loss: false)
      document = document_for_write(document, allow_loss:)
      selected = resolve!(document, specification, resolution)
      instrument(:validate_document, specification: selected.id) do
        @adapters.fetch(pack_for(selected)).validate_document(document:, specification: selected)
      end
    end

    def build_xml(document:, specification: nil, resolution: nil, allow_loss: false)
      document = document_for_write(document, allow_loss:)
      selected = resolve!(document, specification, resolution)
      instrument(:build_xml, specification: selected.id) do
        compilation = compile(document, selected)
        Artifact.new(bytes: compilation.xml, content_type: 'application/xml', filename: 'invoice.xml',
                     report: compilation.report)
      end
    end

    def generate(document:, pdf:, specification: nil, resolution: nil, allow_loss: false)
      document = document_for_write(document, allow_loss:)
      selected = resolve!(document, specification, resolution)
      instrument(:generate, specification: selected.id) do
        compilation = compile(document, selected)
        compose(pdf, compilation.xml, selected, compilation.report)
      end
    end

    def attach(pdf:, xml:, specification: nil)
      bytes = Source.read(xml, limit: limits.xml_bytes)
      input = prepare_xml(bytes)
      selected = detect_specification(input, specification)
      adapter = @adapters.fetch(pack_for(selected))
      report = adapter.validate_xml(xml: bytes, specification: selected, context: input.contexts.fetch(adapter))
      raise InvalidDocumentError.new('XML is invalid', report:) if report.invalid?

      instrument(:attach, specification: selected.id) { compose(pdf, bytes, selected, report) }
    end

    private

    def compile(document, specification)
      compilation = @adapters.fetch(pack_for(specification)).compile(document:, specification:)
      limits.check!(:xml_bytes, compilation.xml.bytesize)
      compilation
    end

    def compose(pdf, xml, specification, report)
      bytes = Source.read(pdf, limit: limits.pdf_bytes)
      output = pack_for(specification, capability: :compose).compose(pdf: bytes, xml:, specification:, limits:)
      Artifact.new(bytes: output, content_type: 'application/pdf', filename: 'invoice.pdf', report:)
    end
  end
end
