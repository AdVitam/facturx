# frozen_string_literal: true

require 'eu_einvoice/error'
require 'eu_einvoice/terms'
require 'eu_einvoice/writer/context'
require 'eu_einvoice/writer/stage'
require 'eu_einvoice/writer/tracker'
require 'eu_einvoice/writer/stages/document_context'
require 'eu_einvoice/writer/stages/exchanged_document'
require 'eu_einvoice/writer/stages/trade_lines'
require 'eu_einvoice/writer/stages/trade_agreement'
require 'eu_einvoice/writer/stages/trade_delivery'
require 'eu_einvoice/writer/stages/trade_settlement'
require 'eu_einvoice/xml/conformance_validator'
require 'eu_einvoice/xml/report_builder'

module EuEinvoice
  class Writer
    STAGES = [
      Stages::DocumentContext,
      Stages::ExchangedDocument,
      Stages::TradeLines,
      Stages::TradeAgreement,
      Stages::TradeDelivery,
      Stages::TradeSettlement
    ].freeze
    MODELED_TERM_IDS = STAGES.flat_map(&:term_ids).freeze
    Compilation = Data.define(:xml, :report)

    unless MODELED_TERM_IDS.sort == Terms.all.map(&:id).sort
      raise 'Factur-X writer stages must cover every modeled term exactly once'
    end

    def initialize(conformance_validator:)
      @conformance_validator = conformance_validator
    end

    def call(document:, profile:)
      compile(document:, profile:).xml
    end

    def compile(document:, profile:)
      context = build_context(document:, profile:)
      report = validate_context(context, profile)
      raise_invalid_document(profile, report) if report.invalid?

      Compilation.new(xml: context.to_xml.freeze, report:)
    end

    def validate(document:, profile:)
      validate_context(build_context(document:, profile:), profile)
    end

    private

    def build_context(document:, profile:)
      tracker = Tracker.new(profile:)
      tracker.check_document(document, path: Terms.fetch('BT-24').xpath)
      context = Context.new(document:, profile:, tracker:)
      STAGES.each { |stage| stage.new(context).call }
      context
    end

    def validate_context(context, profile)
      report = context.tracker.report
      return report if report.invalid?

      issues = @conformance_validator.call(document: context.xml, profile:)
      report.with(issues: report.issues + issues, executed_steps: [:document, *@conformance_validator.steps])
    rescue XsdValidationError => e
      Xml::ReportBuilder.xsd(profile, e).with(executed_steps: %i[document xsd])
    end

    def raise_invalid_document(profile, report)
      raise InvalidDocumentError.new(
        'Factur-X document does not conform to the selected profile',
        profile: profile.id, report:, issues: report.issues
      )
    end
  end
end
