
module Formize

  module Definition
    # Represents an environment for a form or list of fields of one Record
    class Form
      attr_reader :elements, :model, :name, :record_name, :unique_name, :options, :id
      @@count = 0


      def initialize(name, model, options={})
        @name = name
        @model = model
        @options = options
        @elements = []
        @@count += 1
        @id = @@count.to_s(36)
        @unique_name = @options.delete(:unique_name) unless @options[:unique_name].blank?
        @unique_name ||= "_formize#{@id}"
        @record_name = @model.name.underscore
      end

      def field_set(name=nil, options={}, &block)
        raise ArgumentError.new("Missing block") unless block_given?
        field_set = new_element(FieldSet, name, options)
        yield field_set
      end

      def group(name, options={}, &block)
        raise ArgumentError.new("Missing block") unless block_given?
        name, options = nil, name if name.is_a? Hash
        group = new_element(Group, name, options)
        yield group
      end

      def field(name, options={})
        return new_element(Field, name, options)
      end

      def fields(*args)
        options = {}
        options = args.delete_at(-1) if args[-1].is_a?(Hash)
        for name in args
          new_element(Field, name, options)
        end
      end

      
      # protected

      def controller_method_name
        @options[:controller_method_name] || "formize_#{model.underscore}"
      end

      def view_method_name
        @options[:method_name] || "_form_#{model.underscore}"
      end

      def action_name
        @options[:action_name] || :formize
      end

      def mono_choices
        return elements.collect{|e| e.mono_choices}.flatten
      end

      def all_fields
        return elements.inject(HashWithIndifferentAccess.new){|h, e| h.merge!(e.all_fields)}
      end

      def dependents
        return elements.collect{|e| e.dependents}.flatten
      end

      def all_elements
        return elements.collect{|e| e.all_elements}.flatten
      end

      def dependents_on(element)
        return elements.collect{|e| e.dependents_on(element)}.flatten
      end

      def shown_if(element)
        return elements.collect{|e| e.shown_if(element)}.flatten
      end

      def hidden_if(element)
        return elements.collect{|e| e.hidden_if(element)}.flatten
      end


      private

      def new_element(klass, *args)
        raise ArgumentError.new("Bad child type: #{klass.name} (#{klass.ancestors.inspect}). Must be an Formize::Definition::FormElement") unless klass < Formize::Definition::FormElement # klass.ancestors.include? Formize::FormElement
        element = klass.new(self, nil, *args)
        @elements << element
        return element
      end

    end
  end
end
