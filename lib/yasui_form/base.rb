module YasuiForm

  # Main class for Form definitions
  # It permits to manage tree of form elements
  class Element
    attr_reader :parent, :children, :method_name

    def initialize(is_method=false)
      @parent = nil
      @children = []
      @method_name = "_run_element_#{self.object_id}"
      @is_method = is_method
    end

    def is_method?
      @is_method
    end

    def is_method!(value = true)
      raise ArgumentError.new("Must be true or false (not #{value.inspect})") unless [TrueClass, FalseClass].include?(value.class)
      @is_method = value
    end

    def method_name=(name)
      raise ArgumentError.new("Name of field_set must be written only with a-z and 0-9 and _ (not #{name.inspect})") unless name.to_s == name.to_s.downcase.gsub(/[^a-z0-9\_]/, '')
      @method_name = name
    end

    def methodics
      elements = []
      for child in self.children
        elements += child.methodics
      end
      elements << self if self.is_method?
      return elements
    end

    def method_code(options={})
      options[:html_variable] ||= 'html'
      code  = "def #{method_name}(record)\n"
      code << inner_method_code(options).gsub(/^/, '  ')
      code << "end\n"
      return code
    end

    def method_call_code(options={})
      return inner_method_code(options) unless self.is_method?
      return "#{method_name}(record)"
    end

    def inner_method_code(options={})
      # raise NotImplementedError.new
      return content_tag(:strong, "'#{self.class.name} does not implement :#{__method__} method'", options)
    end

    protected


    def content_tag(markup, *args, &block)
      options = html_options = {}
      content = []
      if block_given?
        options, html_options = args[0], args[1]
        yield content
      else
        options, html_options = args[1], args[2]
        content = [args[0].to_s] unless args[0].nil?
      end
      varh = options[:html_variable]
      html_options = {} unless html_options.class == {}.class
      code = ""
      if content.size.zero?
        code << "#{varh} << "+markup_start_code(markup, html_options)+"\n"
      elsif content.size == 1 and not block_given?
        code << "#{varh} << "+markup_start_code(markup, html_options, false)+" << #{content} << "+markup_end_code(markup)+"\n"
      else
        code << "#{varh} << "+markup_start_code(markup, html_options, false)+"\n"
        for line in content
          if block_given?
            code << line.strip << "\n"
          else
            code << "#{varh} << " << line.strip << "\n"
          end
        end
        code << "#{varh} << "+markup_end_code(markup)+"\n"
      end
      return code.gsub(/\' \<\< \'/, '') # .gsub(/\'\n\ *#{varh} \<\< \'/, '')
    end


    def new_child(klass, *args)
      raise ArgumentError.new("Bad child type (#{klass.name}). Must be an YasuiForm::Element") unless klass < Element
      element = klass.new(*args)
      element.send("parent=", self)
      @children << element
      return element
    end


    private

    def markup_start_code(name, attributes={}, closed=true)
      return "'<#{name}"+attributes.collect{|a, v| " #{a}=\"' << #{v} << '\""}.join+"#{'/' if closed}>'"
    end
    
    def markup_end_code(name)
      return "'</#{name}>'"
    end
    
    def parent=(my_parent)
      @parent = my_parent
    end

  end


  # Represents an environment for a form or list of fields of one Record
  class Form < Element
    attr_reader :model, :elements, :record_name

    def initialize(model, method_name = nil)
      super(true)
      @model = model
      @method_name = method_name unless method_name.blank?
      @record_name = @model.name.underscore
    end

    def field_set(name=nil, options={}, &block)
      raise ArgumentError.new("Missing block") unless block_given?
      field_set = self.new_child(FieldSet, self, name, options)
      yield field_set
    end

    def field(name, options={})
      self.new_child(Field, self, name, options)
    end

    def inner_method_code(options={})
      varh = options[:html_variable]
      code = "#{varh} = ''\n"
      for child in children
        code << "#{varh} << " << child.method_call_code << "\n"
      end
      code << "return #{varh}\n"
      return code
    end

  end


  # Main class for form elements
  class FormElement < Element
    attr_reader :form

    def initialize(form, is_method = false)
      super(is_method)
      raise ArgumentError.new("Bad form (#{form.class.name}). Must be an YasuiForm::Form") unless form.is_a? YasuiForm::Form
      @form = form
    end

  end


  # Represents a group of fields which can depend on other fields
  class FieldSet < FormElement
    attr_reader :name, :options, :title
    
    def initialize(form, name=nil, options={})
      super(form, true)
      @title = nil
      @name = if name.blank?
                rand.to_s[2..-1].to_i.to_s(36)
              else
                raise ArgumentError.new("Name of field_set must be written only with a-z and 0-9 and _ (not #{name.inspect})") unless name.to_s == name.to_s.downcase.gsub(/[^a-z0-9\_]/, '')
                @title = name
                name.to_s
              end
      # raise ArgumentError.new("Every field_set's name must be unique") if @form.methodics.detect{|fs| @name == fs.name}
      @options = (options.is_a?(Hash) ? options : {})
      @method_name = @form.method_name + "_within_" + @name
    end


    def field_set(name=nil, options={}, &block)
      raise ArgumentError.new("Missing block") unless block_given?
      field_set = self.new_child(FieldSet, @form, name, options)
      yield field_set
    end

    def field(name, options={})
      self.new_child(Field, @form, name, options)
    end

    # def inner_method_code(variable='html')
    #   code  = ""
    #   code << " #{variable} << '<fieldset>'\n"
    #   unless self.title.nil?
    #     code << " #{variable} << '<legend>' << ::I18n.translate('labels.#{self.title}') << '</legend>'\n"
    #   end
    #   for child in self.children
    #   end

    #   code << " #{variable} << '</fieldset>'\n"
    #   return code
    # end

    def inner_method_code(options={})
      code = "#{options[:html_variable]} = ''\n"
      code << content_tag(:fieldset, options) do |c|
        unless self.title.nil?
          c << content_tag(:legend, "::I18n.translate('labels.#{self.title}')", options)
        end
        for child in self.children
          c << child.method_call_code(options)
        end
      end
      code << "return #{options[:html_variable]}\n"
      return code
    end

    def inner_method_code(options={})
      varc = "fieldset_#{@name}"
      code = "return hard_content_tag(:fieldset) do |#{varc}|\n"
      unless self.title.nil?
        code << "  #{varc} << content_tag(:legend, ::I18n.translate('labels.#{self.title}'))\n"
      end
      for child in self.children
        code << "  #{varc} << " << child.method_call_code(options).gsub(/^/, '  ').strip << "\n"
      end
      code << "end\n"
      return code
    end

  end

  # Represents the field element
  class Field < FormElement
    attr_reader :name, :options, :column, :record_name, :method, :type, :required, :choices, :html_id
    TYPES = [:check_box, :choice, :date, :datetime, :label, :numeric, :password, :single_association_choice, :string, :text_area].freeze

    def initialize(form, name, options={})
      super(form, false)
      @name = name.to_s
      @options = (options.is_a?(Hash) ? options : {})      
      @column = form.model.columns_hash[method.to_s]
      @record_name = form.record_name
      @method = @name
      if type = @options.delete(:as)
        raise ArgumentError.new("Unknown field type (got #{@options[:as].inspect}, expects #{TYPES.join(', ')})") unless TYPES.include? type
        @type = type
      else
        @type = :password if method.to_s.match /password/
        if @choices = @options[:choices]
          if @choices.is_a? Array
            @type = :choice 
          elsif [Symbol, Hash].include? @choices.class
            @type = :single_association_choice 
          else
            raise ArgumentError.new("Option :choices must be Array, Symbol or Hash (got #{options[:choices].class.name})")   
          end
        end
        if column
          @type = :check_box if column.type == :boolean
          @type = :date if column.type == :date
          @type = :datetime if column.type==:datetime or column.type==:timestamp
          @type = :numeric if [:integer, :float, :decimal].include? column.type
          @type = :text_area if column.type == :text
        end
        @type = :label if @form.model.readonly_attributes.include? @record_name
        @type ||= :string
      end
      @required = false
      @required = !@column.null if @column
      @required = true if @options.delete(:required).is_a?(TrueClass)
      @options[:class] = @options[:class].to_s
      @options[:class] = (@options[:class]+" required").strip if required
      @html_id = form.model.name.underscore << '_' << method.to_s
      @field_id = "ff" << Time.now.to_i.to_s(36) << rand.to_s[2..-1].to_i.to_s(36)
    end

    def inner_method_code(options={})
      varc  = "field_#{@name}"
      code  = "hard_content_tag(:div, :class=>'field #{self.type}') do |#{varc}|\n"
      # "#{@form.model.name}.human_attribute_name(:#{@name})", options)
      code << "  #{varc} << label(@#{form.record_name}, :#{@name})\n"
      code << self.send("#{type}_input", varc).strip.gsub(/^/, '  ') << "\n"
      # code << "  #{varc} << text_field(:#{form.record_name}, :#{@name})\n"
      code << "end\n"
      return code
    end

    private

    def check_box_input(varc)
      return "#{varc} << check_box(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    end

    def choice_input(varc)
      code = if @choices.size <= 10
               radio_input(varc)
             else
               select_input(varc)
             end
      return code
    end

    def date_input(varc)
      @options[:size] ||= 16
      return "#{varc} << date_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    end

    def datetime_input(varc)
      @options[:size] ||= 16
      return "#{varc} << datetime_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    end

    def label_input(varc)
      @options[:class] = (@options[:class]+" readonly").strip
      return "#{varc} << content_tag(:span, @#{self.record_name}.#{self.method}, #{@options.inspect})\n"
    end

    def numeric_input(varc)
      @options[:size] ||= 16
      return "#{varc} << text_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    end

    def password_input(varc)
      return "#{varc} << password_field(:#{self.record_name}, :#{self.method}, :size=>24)\n"
    end

    def radio_input(varc)
      return "#{varc} << " << @choices.collect{|x| "content_tag(:span, radio_button(:#{self.record_name}, :#{self.method}, #{x[1].inspect}) << " " << content_tag(:label, #{x[0].inspect}, :for=>'#{html_id}_#{x[1]}'), :class=>'rad')"}.join(" << ") << "\n"
    end

    def select_input(varc)
      if (include_blank = @options.delete(:include_blank)).is_a? String
        @choices.insert(0, [include_blank, ''])
      end
      return "#{varc} << select(:#{self.record_name}, :#{self.method}), #{@choices.inspect}, #{@options.inspect})\n"
    end

    def single_association_choice_input(varc)
      source = form.model.reflections[@method.to_sym].class_name
      count = "#{@choices}_count"
      code  = "#{count} = #{source}.#{@choices}.count\n"
      code << "if (#{count} <= 10)\n"
      code << single_association_radio_input(varc).strip.gsub(/^/, '  ') << "\n"
      code << "elsif (#{count} <= 50)\n"
      code << single_association_select_input(varc).strip.gsub(/^/, '  ') << "\n"
      code << "else\n"
      code << single_association_unroll_input(varc).strip.gsub(/^/, '  ') << "\n"
      code << "end\n"
      
      new_item_url = @options.delete(:new)
      if new_item_url.is_a? Symbol
        new_item_url = {:controller=>new_item_url.to_s.pluralize.to_sym} 
      elsif new_item_url.is_a? TrueClass
        new_item_url = {}
      end

      if new_item_url.is_a?(Hash)
        edit_item_url = {} unless edit_item_url.is_a? Hash
        if method.to_s.match(/_id$/) and refl = form.model.reflections[method.to_s[0..-4].to_sym]
          new_item_url[:controller] ||= refl.class_name.underscore.pluralize
          edit_item_url[:controller] ||= new_item_url[:controller]
        end
        new_item_url[:action] ||= :new
        edit_item_url[:action] ||= :edit
        data = options.delete(:update)||@field_id
        code << "#{varc} << content_tag(:span, content_tag(:span, link_to(tg(:new), #{new_item_url.inspect}, \"data-new-item\"=>'#{data}', :class=>\"icon im-new\").html_safe, :class=>:tool).html_safe, :class=>\"toolbar mini-toolbar\") if authorized?(new_item_url)\n"
      end
      return code
    end

    def single_association_radio_input(varc)
      return "#{varc} << RADIO"
    end

    def single_association_select_input(varc)
      return "#{varc} << select(:#{self.record_name}, :#{self.method}, #{source}.#{@choices}.collect{|item| [item.name, item.id]})" # ", options[:options], #{@options.merge('data-refresh'=>url_for(options[:choices].merge(:controller=>:interfacers, :action=>:unroll_options)), 'data-id-parameter-name'=>'selected').inspect} )"
    end
    
    def single_association_unroll_input(varc)
      return "#{varc} << UNROLL"
    end

    def string_input(varc)
      @options[:size] ||= 24
      if column and !column.limit.nil?
        @options[:size] = column.limit if column.limit<@options[:size]
        @options[:maxlength] = column.limit
      end
      return "#{varc} << text_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    end

    def text_area_input(varc)
      @options[:cols] ||= 40
      @options[:rows] ||= 3
      @options[:class] = "#{@options[:class]} #{@options[:cols]==80 ? :code : nil}".strip
      return "#{varc} << text_area(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    end



  end

end
