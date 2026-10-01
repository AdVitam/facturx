# frozen_string_literal: true

require 'eu_einvoice/error'
require 'eu_einvoice/format'
require 'eu_einvoice/terms'
require 'eu_einvoice/writer/stage_support/contact_details'
require 'eu_einvoice/writer/stage_support/emission'
require 'eu_einvoice/writer/stage_support/identifiers'
require 'eu_einvoice/writer/stage_support/structure'

module EuEinvoice
  class Writer
    class Stage
      include StageSupport::Emission
      include StageSupport::Structure
      include StageSupport::ContactDetails
      include StageSupport::Identifiers

      class << self
        def term_ids(*ids)
          @term_ids = ids.map(&:to_s).freeze unless ids.empty?
          @term_ids || [].freeze
        end
      end

      def initialize(context)
        @context = context
      end

      private

      attr_reader :context

      def document
        context.document
      end

      def profile
        context.profile
      end

      def tracker
        context.tracker
      end
    end
  end
end
