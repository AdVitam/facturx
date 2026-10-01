# frozen_string_literal: true

module EuEinvoice
  module Rails
    module ActiveStorage
      module_function

      def attachable(artifact)
        { io: artifact.to_io, filename: artifact.filename, content_type: artifact.content_type, identify: false }
      end
    end
  end
end
