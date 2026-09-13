# frozen_string_literal: true

require_relative '../error'
require_relative '../format'
require_relative '../terms'
require_relative 'stage_support/contact_details'
require_relative 'stage_support/emission'
require_relative 'stage_support/identifiers'
require_relative 'stage_support/structure'

module Facturx
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
