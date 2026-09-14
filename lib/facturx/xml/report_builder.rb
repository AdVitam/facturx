# frozen_string_literal: true

require_relative '../validation'

module Facturx
  module Xml
    class ReportBuilder
      class << self
        def syntax(error)
          from_error(error, layer: :syntax, code: :invalid_xml)
        end

        def profile(error)
          guideline_urn = error.details[:guideline_urn]
          code = guideline_urn.nil? || guideline_urn.empty? ? :missing_profile : :unknown_profile
          from_error(error, layer: :profile, code:)
        end

        def xsd(profile, error)
          from_error(error, profile:, layer: :xsd, code: :xsd_violation)
        end

        private

        def from_error(error, layer:, code:, profile: nil)
          diagnostics = error.details[:errors] || [{ message: error.message }]
          issues = diagnostics.map { |diagnostic| issue(error, diagnostic, layer:, code:) }
          Validation::Report.new(profile:, issues:)
        end

        def issue(error, diagnostic, layer:, code:)
          Validation::Issue.new(
            code:,
            message: diagnostic.fetch(:message),
            layer:,
            line: diagnostic[:line],
            column: diagnostic[:column],
            details: error.details.except(:errors).merge(diagnostic.except(:message, :line, :column))
          )
        end
      end
    end
  end
end
