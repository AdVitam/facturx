# frozen_string_literal: true

module EuEinvoice
  module Terms
    class Selections
      Selection = Data.define(:terms, :by_model_group, :by_model_attribute)

      def initialize(terms)
        @terms = terms
        @cache = {}
        @mutex = Mutex.new
      end

      def fetch(profile)
        @mutex.synchronize do
          @cache.shift if @cache.size >= 32 && !@cache.key?(profile)
          @cache[profile] ||= build(profile)
        end
      end

      private

      def build(profile)
        terms = profile ? @terms.select { |term| profile.cardinality(term) }.freeze : @terms
        Selection.new(terms:, by_model_group: group(terms, :group_id), by_model_attribute: group(terms, :attribute))
      end

      def group(terms, attribute)
        terms.group_by { |term| [term.model, term.public_send(attribute)].freeze }.transform_values(&:freeze).freeze
      end
    end
  end
end
