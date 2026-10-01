# frozen_string_literal: true

require 'eu_einvoice/error'

module EuEinvoice
  module Source
    CHUNK_SIZE = 65_536

    def self.pdf?(bytes)
      prefix = bytes.byteslice(0, 1024).b
      return false if prefix.delete_prefix("\xEF\xBB\xBF".b).lstrip.start_with?('<')

      prefix.include?('%PDF-'.b)
    end

    def self.read(input, limit:)
      raise ArgumentError, 'limit must be a positive Integer' unless limit.is_a?(Integer) && limit.positive?

      input = input.bytes if !input.is_a?(String) && input.respond_to?(:bytes)
      return bounded_string(input, limit) if input.is_a?(String)
      unless input.respond_to?(:read)
        raise InvalidSourceError.new('Source must contain bytes or support read', input_class: input.class.name)
      end

      read_io(input, limit)
    end

    def self.read_io(input, limit)
      buffer = +''.b
      loop do
        chunk = input.read([CHUNK_SIZE, limit - buffer.bytesize + 1].min)
        break if chunk.nil? || chunk == ''

        append_chunk(buffer, chunk, limit)
      end
      buffer.freeze
    end

    def self.append_chunk(buffer, chunk, limit)
      raise InvalidSourceError.new('IO must return bytes', input_class: chunk.class.name) unless chunk.is_a?(String)

      check_size!(buffer.bytesize + chunk.bytesize, limit)
      buffer << chunk.b
    end

    def self.bounded_string(input, limit)
      check_size!(input.bytesize, limit)
      input.b.freeze
    end

    def self.check_size!(actual, limit)
      return if actual <= limit

      raise ResourceLimitError.new('Source exceeds byte limit', resource: :source_bytes, limit:, actual:)
    end

    private_class_method :bounded_string, :check_size!, :read_io, :append_chunk
  end
end
