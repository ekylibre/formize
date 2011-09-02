module Formize

  module Definition
    
    # Main class for form elements
    class FormElement
      attr_reader :children, :depend_on, :form, :html_id, :id, :options, :parent, :unique_name
      @@count = 0 #  unless defined? @@count

      def initialize(form, parent = nil, options={})
        raise ArgumentError.new("Bad form (#{form.class.name}). Must be an Formize::Definition::Form") unless form.is_a? Formize::Definition::Form
        @form = form
        @parent = parent
        @options = (options.is_a?(Hash) ? options : {})      
        @depend_on = nil
        @children = []
        @@count += 1
        @id = @@count.to_s(36)
        if Rails.env == "development"
          @html_id = "fz_#{@form.options[:best_name]}_#{@id}"
        else
          @html_id = "fz#{@id}"
        end
        @unique_name = self.form.unique_name + "_" + @html_id
      end


      def dependeds
        l = (self.parent ? self.parent.dependeds : [])
        l << {:name=>self.depend_on} unless self.depend_on.blank?
        return l
      end

      def arguments
        args = []
        args << {:name=>form.record_name}
        # args += self.dependeds
        # args << {:name=>@depend_on} if @depend_on
        return args
      end

      def prototype
        return "#{@unique_name}(" + arguments.collect{|x| x[:name]}.join(', ') + ")"
      end


      def mono_choices
        elements = []
        for child in self.children
          elements += child.mono_choices
        end
        elements << self if self.class == Formize::Definition::Field and self.type == :mono_choice
        return elements      
      end

      def all_fields
        elements = HashWithIndifferentAccess.new()
        for child in self.children
          elements.merge!(child.all_fields)
        end
        elements[self.name] = self if self.class == Formize::Definition::Field
        return elements
      end

      def dependents
        elements = []
        for child in self.children
          elements += child.dependents
        end
        elements << self if self.options[:depend_on]
        return elements      
      end

      
      def all_elements
        elements = self.children.collect{|c| c.all_elements}.flatten
        elements << self
        return elements      
      end


      # Find form elements
      def dependents_on(element)
        elements = []
        for child in self.children
          elements += child.dependents_on(element)
        end
        elements << self if self.depend_on and self.depend_on.to_s == element.name.to_s # form.fields[self.depend_on].name == element.name
        return elements
      end

      def shown_if(element)
        elements = []
        for child in self.children
          elements += child.shown_if(element)
        end
        elements << self if self.options[:shown_if] and self.options[:shown_if].to_s == element.name.to_s
        return elements
      end

      def hidden_if(element)
        elements = []
        for child in self.children
          elements += child.hidden_if(element)
        end
        elements << self if self.options[:hidden_if] and self.options[:hidden_if].to_s == element.name.to_s
        return elements
      end


      protected

      def new_child(klass, *args)
        raise ArgumentError.new("Bad child type (#{klass.name}). Must be an Formize::Definition::FormElement") unless klass < Formize::Definition::FormElement
        element = klass.new(self.form, self, *args)
        @children << element
        return element
      end


    end
  end

end
