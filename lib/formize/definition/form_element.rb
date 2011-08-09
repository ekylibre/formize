module Formize
    
  # Main class for form elements
  class FormElement
    attr_reader :form, :parent, :children, :unique_name, :id, :depend_on, :html_id
    @@count = 0

    def initialize(form, parent = nil)
      raise ArgumentError.new("Bad form (#{form.class.name}). Must be an Formize::Form") unless form.is_a? Formize::Form
      @form = form
      @parent = parent
      @depend_on = nil
      @children = []
      @@count += 1
      @id = @@count.to_s(36)
      @html_id = "fz#{@id}"
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
      args += self.dependeds
      # args << {:name=>@depend_on} if @depend_on
      return args
    end

    def prototype
      return "#{@unique_name}(" + arguments.collect{|x| x[:name]}.join(', ') + ")"
    end

    # def method_name=(name)
    #   raise ArgumentError.new("Name of field_set must be written only with a-z and 0-9 and _ (not #{name.inspect})") unless name.to_s == name.to_s.downcase.gsub(/[^a-z0-9\_]/, '')
    #   @method_name = name
    # end


    # def method_code(options={})
    #   varh = options[:html_variable] ||= 'html'
    #   code  = "def #{method_name}(record)\n"
    #   code << inner_method_code(options).gsub(/^/, '  ')
    #   code << "  return #{varh}\n"
    #   code << "end\n"
    #   return code
    # end

    # def method_call_code(options={})
    #   return inner_method_code(options) unless self.is_method?
    #   return "#{method_name}(record)"
    # end

    # def inner_method_code(options={})
    #   # raise NotImplementedError.new
    #   return content_tag(:strong, "'#{self.class.name} does not implement :#{__method__} method'", options)
    # end



    # def is_method?
    #   @depend_on.nil?
    # end

    # def methodics
    #   elements = []
    #   for child in self.children
    #     elements += child.methodics
    #   end
    #   elements << self if self.is_method?
    #   return elements
    # end

    def mono_choices
      elements = []
      for child in self.children
        elements += child.mono_choices
      end
      elements << self if self.class == Formize::Field and self.type == :mono_choice
      return elements      
    end

    def fields
      elements = HashWithIndifferentAccess.new()
      for child in self.children
        elements.merge!(child.fields)
      end
      elements[self.name] = self if self.class == Formize::Field
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




    protected

    def new_child(klass, *args)
      raise ArgumentError.new("Bad child type (#{klass.name}). Must be an Formize::FormElement") unless klass < FormElement
      element = klass.new(self.form, self, *args)
      @children << element
      return element
    end


  end


end
