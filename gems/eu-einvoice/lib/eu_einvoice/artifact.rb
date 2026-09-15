# frozen_string_literal: true

require 'stringio'
require 'eu_einvoice/model/immutable'

module EuEinvoice
  Artifact = Data.define(:bytes, :content_type, :filename, :report) do
    def initialize(bytes:, content_type:, filename:, report: nil)
      raise TypeError, 'bytes must be a String' unless bytes.is_a?(String)
      unless filename.is_a?(String) && !filename.empty? && !filename.match?(%r{[\\/\x00-\x1f\x7f]})
        raise ArgumentError, 'filename must be a safe basename'
      end

      super(bytes: bytes.b.freeze, content_type: content_type.dup.freeze, filename: filename.dup.freeze, report:)
    end

    def byte_size = bytes.bytesize

    def to_io = StringIO.new(bytes, 'r')
  end
end
