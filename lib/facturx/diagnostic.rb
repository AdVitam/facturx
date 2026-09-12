# frozen_string_literal: true

require_relative 'model/immutable'

module Facturx
  Diagnostic = Data.define(:code, :term_id, :path, :message, :details) do
    include Model::ValidatedWith

    def initialize(code:, message:, term_id: nil, path: nil, details: {})
      raise TypeError, 'details must be a Hash' unless details.is_a?(Hash)

      bounded_details = details.to_h do |key, value|
        [key, value.is_a?(String) ? value.byteslice(0, 200).scrub('') : value]
      end
      super(code: Model.copy_and_freeze(code), term_id: Model.copy_and_freeze(term_id),
            path: Model.copy_and_freeze(path), message: Model.copy_and_freeze(message),
            details: Model.copy_and_freeze(bounded_details))
    end
  end
end
