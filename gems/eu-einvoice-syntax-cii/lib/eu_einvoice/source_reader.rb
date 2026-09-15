# frozen_string_literal: true

require 'eu_einvoice/error'
require 'eu_einvoice/source'

module EuEinvoice
  class SourceReader
    Result = Data.define(:xml, :source_type)

    def initialize(extractor: nil)
      @extractor = extractor
    end

    def call(source)
      unless source.is_a?(String)
        raise InvalidSourceError.new('Source must be provided as a byte String', input_class: source.class.name)
      end

      return Result.new(xml: source, source_type: :xml) unless pdf?(source)

      raise InvalidSourceError.new('A PDF extractor must be configured', reason: :missing_extractor) unless @extractor

      Result.new(xml: @extractor.call(source).xml, source_type: :pdf)
    end

    private

    def pdf?(bytes)
      Source.pdf?(bytes)
    end
  end
end
