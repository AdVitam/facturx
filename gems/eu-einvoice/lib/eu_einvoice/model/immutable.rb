# frozen_string_literal: true

module EuEinvoice
  module Model
    module Immutability
      module_function

      def copy(value)
        case value
        when Float then raise TypeError, 'Float values are not supported; use BigDecimal for decimal values'
        when String then value.dup.freeze
        when Array then value.map { |item| copy(item) }.freeze
        when Hash then value.to_h { |key, item| [copy(key), copy(item)] }.freeze
        else copy_object(value)
        end
      end

      def copy_object(value)
        immutable = value.nil? || value == true || value == false || value.is_a?(Numeric) || value.is_a?(Symbol)
        return value if immutable || value.frozen?

        value.dup.freeze
      end
    end

    module ValidatedWith
      def with(**attributes)
        self.class.new(**to_h, **attributes)
      end
    end

    MISSING = Object.new.freeze
    private_constant :MISSING

    module_function

    def define(*members, collections: [], defaults: {})
      collection_members = collections.map(&:to_sym).freeze
      defaults = copy_and_freeze(defaults)

      Data.define(*members) do
        include ValidatedWith

        define_method(:initialize) do |**attributes|
          normalized = Model.normalize_attributes(self.class.members, collection_members, defaults.merge(attributes))
          super(**normalized)
        end
      end
    end

    def normalize_attributes(members, collections, attributes)
      validate_attributes!(members, attributes)
      members.to_h do |member|
        value = attributes.fetch(member, MISSING)
        [member, normalize_value(member, value, collections.include?(member))]
      end
    end

    def validate_attributes!(members, attributes)
      unknown = attributes.keys - members
      raise ArgumentError, "Unknown attributes: #{unknown.map(&:inspect).join(', ')}" unless unknown.empty?
    end

    def normalize_value(member, value, collection)
      value = nil if value.equal?(MISSING)
      value = [] if collection && value.nil?
      raise TypeError, "#{member} must be an Array" if collection && !value.is_a?(Array)

      copy_and_freeze(value)
    end

    def copy_and_freeze(value)
      Immutability.copy(value)
    end
  end
end
