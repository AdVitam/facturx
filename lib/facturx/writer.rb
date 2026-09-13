# frozen_string_literal: true

require_relative 'conformance'
require_relative 'error'
require_relative 'terms'
require_relative 'writer/context'
require_relative 'writer/stage'
require_relative 'writer/stages/document_context'
require_relative 'writer/stages/exchanged_document'
require_relative 'writer/stages/trade_lines'
require_relative 'writer/stages/trade_agreement'
require_relative 'writer/stages/trade_delivery'
require_relative 'writer/stages/trade_settlement'
require_relative 'xml/schema_validator'

module Facturx
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

    unless MODELED_TERM_IDS.sort == Terms.all.map(&:id).sort
      raise 'Factur-X writer stages must cover every modeled term exactly once'
    end

    def initialize(schema_validator: Xml::SchemaValidator.new, tracker: Conformance::Tracker, stages: STAGES)
      @schema_validator = schema_validator
      @tracker_class = tracker
      @stages = stages.freeze
    end

    def call(document:, profile:)
      context = compile(document:, profile:)
      report = context.tracker.report
      raise_conformance_error(profile, report) if report.invalid?

      @schema_validator.call(document: context.xml, profile:)
      context.to_xml
    end

    def validate(document:, profile:)
      compile(document:, profile:).tracker.report
    end

    private

    def compile(document:, profile:)
      tracker = @tracker_class.new(profile:)
      tracker.check_document(document, path: Terms.fetch('BT-24').xpath)
      context = Context.new(document:, profile:, tracker:)
      @stages.each { |stage| stage.new(context).call }
      context
    end

    def raise_conformance_error(profile, report)
      raise ConformanceError.new(
        'Factur-X document does not conform to the selected profile',
        profile: profile.id, report:, issues: report.issues
      )
    end
  end
end
