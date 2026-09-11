# frozen_string_literal: true

module PdfSupport
  class PdfBuilder
    def initialize
      @objects = []
    end

    def add(object = nil)
      @objects << object
      @objects.length
    end

    def replace(identifier, object)
      @objects[identifier - 1] = object
    end

    def stream(bytes, dictionary = '')
      add("<< /Length #{bytes.bytesize} #{dictionary} >>\nstream\n#{bytes}\nendstream")
    end

    def build(root: 1)
      pdf = +"%PDF-1.7\n%\xE2\xE3\xCF\xD3\n".b
      offsets = append_objects(pdf)
      append_xref(pdf, offsets, root)
    end

    private

    def append_objects(pdf)
      @objects.each_with_index.with_object([0]) do |(object, index), offsets|
        raise "PDF object #{index + 1} is missing" unless object

        offsets << pdf.bytesize
        pdf << "#{index + 1} 0 obj\n#{object}\nendobj\n".b
      end
    end

    def append_xref(pdf, offsets, root)
      xref_offset = pdf.bytesize
      pdf << xref_header
      offsets.drop(1).each { |offset| pdf << format("%010d 00000 n \n", offset).b }
      pdf << trailer(root, xref_offset)
      pdf
    end

    def xref_header
      "xref\n0 #{@objects.length + 1}\n0000000000 65535 f \n".b
    end

    def trailer(root, xref_offset)
      "trailer\n<< /Size #{@objects.length + 1} /Root #{root} 0 R >>\n" \
      "startxref\n#{xref_offset}\n%%EOF\n".b
    end
  end

  def build_pdf(catalog: '', extra_objects: [])
    builder = PdfBuilder.new
    builder.add("<< /Type /Catalog /Pages 2 0 R #{catalog} >>")
    builder.add('<< /Type /Pages /Kids [3 0 R] /Count 1 >>')
    builder.add('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>')
    extra_objects.each { |object| builder.add(object) }
    builder.build
  end

  def embedded_file_objects(xml, filename: 'factur-x.xml', relationship: 'Alternative', stream_id: 5)
    file_specification = <<~PDF.delete("\n")
      << /Type /Filespec /F (#{filename}) /UF (#{filename})
      /AFRelationship /#{relationship} /EF << /F #{stream_id} 0 R >> >>
    PDF
    stream = "<< /Length #{xml.bytesize} /Type /EmbeddedFile >>\nstream\n#{xml}\nendstream"
    [file_specification, stream]
  end
end
