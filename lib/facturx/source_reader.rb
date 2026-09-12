# frozen_string_literal: true

require_relative 'error'
require_relative 'pdf/extractor'

module Facturx
  class SourceReader
    Result = Data.define(:xml, :source_type)

    def initialize(extractor: Pdf::Extractor.new)
      @extractor = extractor
    end

    def call(source)
      unless source.is_a?(String)
        raise InvalidXmlError.new('Source must be provided as a byte String', input_class: source.class.name)
      end

      return Result.new(xml: source, source_type: :xml) unless pdf?(source)

      Result.new(xml: @extractor.call(source).xml, source_type: :pdf)
    end

    private

    def pdf?(bytes)
      bytes.b.byteslice(0, 1024)&.include?('%PDF-'.b)
    end
  end
end
