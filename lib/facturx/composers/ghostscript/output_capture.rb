# frozen_string_literal: true

module Facturx
  module Composers
    class Ghostscript
      class OutputCapture
        TRUNCATION_MARKER = '...[truncated]'

        def initialize(stream, limit:)
          @stream = stream
          @limit = limit
        end

        def call
          buffer = +''.b
          truncated = false
          while (chunk = @stream.read(4_096))
            remaining = @limit - buffer.bytesize
            buffer << chunk.byteslice(0, remaining) if remaining.positive?
            truncated ||= chunk.bytesize > remaining
          end
          truncate(buffer, truncated)
        rescue IOError
          buffer
        end

        private

        def truncate(buffer, truncated)
          return buffer unless truncated

          marker = TRUNCATION_MARKER.byteslice(0, @limit)
          kept_bytes = [@limit - marker.bytesize, 0].max
          buffer.byteslice(0, kept_bytes).to_s << marker
        end
      end
    end
  end
end
