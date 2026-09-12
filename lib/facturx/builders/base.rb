# frozen_string_literal: true

module Facturx
  module Builders
    class Base
      UNSET = Object.new.freeze
      private_constant :UNSET

      class << self
        attr_reader :model, :associations

        def configure(model, associations)
          @model = model
          @associations = associations
          define_attribute_methods
          self
        end

        def build(**attributes, &block)
          builder = new(**attributes)
          block&.call(builder)
          builder.build
        end

        private

        def define_attribute_methods
          model.members.each do |attribute|
            association = associations[attribute]
            association ? define_association_methods(attribute, association) : define_scalar_methods(attribute)
          end
        end

        def define_scalar_methods(attribute)
          define_method(attribute) { @attributes[attribute] }
          define_method(:"#{attribute}=") { |value| @attributes[attribute] = value }
        end

        def define_association_methods(attribute, association)
          if association.collection
            define_collection_helper(attribute, association)
          else
            define_singular_helper(attribute, association)
          end
          define_method(:"#{attribute}=") { |value| set_association(attribute, association, value) }
        end

        def define_singular_helper(attribute, association)
          define_method(attribute) do |value = UNSET, **attributes, &block|
            assign_association(attribute, association, value, attributes, block)
          end
        end

        def define_collection_helper(attribute, association)
          define_method(association.helper) do |value = UNSET, **attributes, &block|
            append_association(attribute, association, value, attributes, block)
          end
          define_method(attribute) { @attributes.fetch(attribute, []).dup.freeze }
        end
      end

      def initialize(**attributes)
        unknown = attributes.keys - self.class.model.members
        raise ArgumentError, "Unknown attributes: #{unknown.map(&:inspect).join(', ')}" unless unknown.empty?

        @attributes = {}
        attributes.each { |attribute, value| public_send(:"#{attribute}=", value) }
      end

      def build
        self.class.model.new(**@attributes)
      end

      private

      def assign_association(attribute, association, value, attributes, block)
        if @attributes.key?(attribute)
          raise ArgumentError,
                "#{attribute} is already set; use #{attribute}= to replace it"
        end

        object = association_value(attribute, association, value, attributes, block)
        @attributes[attribute] = object
      end

      def append_association(attribute, association, value, attributes, block)
        object = association_value(association.helper, association, value, attributes, block)
        (@attributes[attribute] ||= []) << object
        object
      end

      def set_association(attribute, association, value)
        if association.collection
          set_collection(attribute, association, value)
        else
          validate_object!(attribute, association.model, value) unless value.nil?
          @attributes[attribute] = value
        end
      end

      def set_collection(attribute, association, value)
        raise TypeError, "#{attribute} must be an Array" unless value.is_a?(Array)

        value.each { |object| validate_object!(attribute, association.model, object) }
        @attributes[attribute] = value.dup
      end

      def association_value(name, association, value, attributes, block)
        forms = [!value.equal?(UNSET), !attributes.empty?, !block.nil?]
        unless forms.one?
          raise ArgumentError, "#{name} accepts exactly one of an object, keyword attributes, or a block"
        end

        return validate_object!(name, association.model, value) unless value.equal?(UNSET)

        builder = Builders.for(association.model)
        attributes.empty? ? builder.build(&block) : builder.build(**attributes)
      end

      def validate_object!(attribute, model, object)
        unless object.instance_of?(model) && object.frozen?
          raise TypeError, "#{attribute} must be an immutable #{model.name}"
        end

        object
      end
    end
  end
end
