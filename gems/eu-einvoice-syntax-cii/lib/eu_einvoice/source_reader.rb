# frozen_string_literal: true

require 'eu_einvoice/error'

module EuEinvoice
  class SourceReader
    Result = Data.define(:xml, :source_type)

    def call(source)
      unless source.is_a?(String)
        raise InvalidSourceError.new('Source must be provided as a byte String', input_class: source.class.name)
      end

      Result.new(xml: source, source_type: :xml)
    end
  end
end
