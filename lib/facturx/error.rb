# frozen_string_literal: true

module Facturx
  class Error < StandardError
    attr_reader :details

    def initialize(message = nil, **details)
      @details = details.freeze
      super(message)
    end
  end

  class ValidationError < Error; end
  class InvalidDocumentError < ValidationError; end
  class InvalidXmlError < ValidationError; end
  class UnknownProfileError < InvalidXmlError; end
  class XsdValidationError < InvalidXmlError; end
  class SchemaLoadError < Error; end
  class InvalidSourceError < Error; end
  class UnsupportedProfileError < Error; end
  class FormattingError < Error; end
  class InvalidPdfError < Error; end
  class ProtectedPdfError < InvalidPdfError; end
  class ComposerUnavailableError < Error; end
  class CompositionError < Error; end
  class ExtractionError < Error; end
  class VerificationError < Error; end
end
