# frozen_string_literal: true

module EuEinvoice
  module France
    module AdapterReporting
      private

      def raise_compilation_error(error, specification)
        report = annotate(error.details.fetch(:report), specification)
        raise InvalidDocumentError.new(error.message, **error.details, report:, issues: report.issues)
      end

      def check_semantic_version!(document, specification)
        return if document.semantic_version == specification.semantic_version

        report = version_report(document, specification)
        raise InvalidDocumentError.new('Document semantic version conflicts with specification', report:)
      end

      def version_report(document, specification)
        issue = Validation::Issue.new(
          code: :semantic_version_mismatch, layer: :document,
          message: 'Document semantic version conflicts with specification',
          details: { expected: specification.semantic_version, actual: document.semantic_version }
        )
        annotate(Validation::Report.new(profile: specification.profile, issues: [issue], executed_steps: [:document]),
                 specification)
      end

      def annotate(report, specification)
        resources = specification && report.executed_steps.include?(:xsd) ? specification.resources : {}
        resources = resources.merge(Licensing.resources(package: 'eu-einvoice-fr')) unless resources.empty?
        if specification && report.executed_steps.include?(:schematron)
          resources = resources.merge(rule_resources(specification))
        end
        report.with(specification:, requested_coverage: @validation, resources:)
      end

      def rule_resources(specification)
        @pipelines.fetch(specification).schematron.resources(profile: specification.profile)
                  .merge(Licensing.resources(package: 'eu-einvoice-validation-fr'))
      end
    end
  end
end
