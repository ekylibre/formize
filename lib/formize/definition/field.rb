module Formize


  # Represents the field element
  class Field < FormElement
    attr_reader :name, :options, :column, :record_name, :method, :type, :required, :choices, :input_id, :source, :item_label, :field_id, :reflection, :html_options, :default

    TYPES = [:check_box, :choice, :date, :datetime, :label, :numeric, :password, :mono_choice, :string, :text_area].freeze

    def initialize(form, parent, name, options={})
      super(form, parent)
      @name = name.to_s
      @options = (options.is_a?(Hash) ? options : {})      
      @column = form.model.columns_hash[@name]
      @record_name = form.record_name
      @method = @name
      unless @options[:default].nil?
        @default = (@options[:default].is_a?(String) ? Code.new(@options[:default]) : @options[:default])
      end
      @html_options = @options.delete(:html_options)||{}
      @depend_on = @options.delete(:depend_on)
      raise ArgumentError.new("A depended element must defined before its dependencies (#{@depended.inspect})") if !@depend_on.blank? and form.fields[@depend_on].nil?
      if type = @options.delete(:as)
        raise ArgumentError.new("Unknown field type (got #{@options[:as].inspect}, expects #{TYPES.join(', ')})") unless TYPES.include? type
        @type = type
      else
        @type = :password if @name.to_s.match /password/
        if @choices = @options.delete(:choices)
          if @choices.is_a? Array
            @type = :choice 
          elsif [Symbol, Hash].include? @choices.class
            @type = :mono_choice 
            @reflection = form.model.reflections[@method.to_sym]
            @source = @options.delete(:source) # || @reflection.class_name
            @is_method = true if @options[:new]
            @method_name = self.form.unique_name + "_inf_" + @name
            @method = @reflection.primary_key_name
            unless @item_label = @options.delete(:item_label)
              model = @reflection.class_name.constantize
              available_methods = (model.columns_hash.keys+model.instance_methods).collect{|x| x.to_s}
              @item_label = [:label, :name, :code, :number, :inspect].detect{|x| available_methods.include?(x.to_s)}
            end

          else
            raise ArgumentError.new("Option :choices must be Array, Symbol or Hash (got #{@choices.class.name})")
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
      @input_id = form.model.name.underscore << '_' << method.to_s
      @field_id = "ff" << Time.now.to_i.to_s(36) << rand.to_s[2..-1].to_i.to_s(36)
    end

    # def inner_method_code(options={})
    #   varc  = options[:html_variable]||"field_#{@name}"
    #   code  = "#{varc}  = label(:#{form.record_name}, :#{@name})\n"
    #   code << self.send("#{type}_input", varc)
    #   return code
    # end

    # def method_call_code(options={})
    #   varc  = "field_#{@name}"
    #   code  = ""
    #   if self.is_method?
    #     code << "content_tag(:div, #{method_name}(record), #{@options.inspect})"
    #   else
    #     code << "hard_content_tag(:div, #{@options.inspect}) do |#{varc}|\n"
    #     code << inner_method_code(:html_variable=>varc).strip.gsub(/^/, '  ') << "\n"
    #     code << "end\n"
    #   end
    #   return code
    # end

    # private




    # def check_box_input(varc)
    #   return "#{varc} << check_box(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    # end

    # def choice_input(varc)
    #   code = if @choices.size <= 10
    #            radio_input(varc)
    #          else
    #            select_input(varc)
    #          end
    #   return code
    # end

    # def date_input(varc)
    #   @options[:size] ||= 16
    #   return "#{varc} << date_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    # end

    # def datetime_input(varc)
    #   @options[:size] ||= 16
    #   return "#{varc} << datetime_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    # end

    # def label_input(varc)
    #   @options[:class] = (@options[:class]+" readonly").strip
    #   return "#{varc} << content_tag(:span, @#{self.record_name}.#{self.method}, #{@options.inspect})\n"
    # end

    # def numeric_input(varc)
    #   @options[:size] ||= 16
    #   return "#{varc} << text_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    # end

    # def password_input(varc)
    #   return "#{varc} << password_field(:#{self.record_name}, :#{self.method}, :size=>24)\n"
    # end

    # def radio_input(varc)
    #   return "#{varc} << " << @choices.collect{|x| "content_tag(:span, radio_button(:#{self.record_name}, :#{self.method}, #{x[1].inspect}) << ' ' << content_tag(:label, #{x[0].inspect}, :for=>'#{input_id}_#{x[1]}'), :class=>'rad')"}.join(" << ") << "\n"
    # end

    # def select_input(varc)
    #   if (include_blank = @options.delete(:include_blank)).is_a? String
    #     @choices.insert(0, [include_blank, ''])
    #   end
    #   return "#{varc} << select(:#{self.record_name}, :#{self.method}), #{@choices.inspect}, #{@options.inspect})\n"
    # end

    # def mono_choice_input(varc)
    #   count = "#{@choices}_count"
    #   code  = "#{count} = #{source}.#{@choices}.count\n"
    #   code << "if (#{count} <= 10)\n"
    #   code << mono_radio_input(varc).strip.gsub(/^/, '  ') << "\n"
    #   code << "elsif (#{count} <= 50)\n"
    #   code << mono_select_input(varc).strip.gsub(/^/, '  ') << "\n"
    #   code << "else\n"
    #   code << mono_unroll_input(varc).strip.gsub(/^/, '  ') << "\n"
    #   code << "end\n"
      
    #   new_item_url = @options.delete(:new)
    #   if new_item_url.is_a? Symbol
    #     new_item_url = {:controller=>new_item_url.to_s.pluralize.to_sym} 
    #   elsif new_item_url.is_a? TrueClass
    #     new_item_url = {}
    #   end

    #   if new_item_url.is_a?(Hash)
    #     edit_item_url = {} unless edit_item_url.is_a? Hash
    #     if method.to_s.match(/_id$/) and refl = form.model.reflections[method.to_s[0..-4].to_sym]
    #       new_item_url[:controller] ||= refl.class_name.underscore.pluralize
    #       edit_item_url[:controller] ||= new_item_url[:controller]
    #     end
    #     new_item_url[:action] ||= :new
    #     edit_item_url[:action] ||= :edit
    #     data = options.delete(:update)||@field_id
    #     code << "#{varc} << content_tag(:span, content_tag(:span, link_to(tg(:new), #{new_item_url.inspect}, \"data-new-item\"=>'#{data}', :class=>\"icon im-new\").html_safe, :class=>:tool).html_safe, :class=>\"toolbar mini-toolbar\") if authorized?(new_item_url)\n"
    #   end
    #   return code
    # end

    # def mono_radio_input(varc)
    #   code  = "for item in #{source}.#{@choices}\n"
    #   code << "  #{varc} << content_tag(:span, radio_button(:#{self.record_name}, :#{self.method}, item.id) + ' ' + content_tag(:label, item.#{@item_label}, :for=>'#{input_id}_'+item.id.to_s), :class=>'rad')\n"
    #   code << "end\n"
    #   return code
    # end

    # def mono_select_input(varc)
    #   return "#{varc} << select(:#{self.record_name}, :#{self.method}, #{source}.#{@choices}.collect{|item| [item.#{@item_label}, item.id]})" # ", options[:options], #{@options.merge('data-refresh'=>url_for(options[:choices].merge(:controller=>:interfacers, :action=>:unroll_options)), 'data-id-parameter-name'=>'selected').inspect} )"
    # end
    
    # def mono_unroll_input(varc)
    #   return "#{varc} << unroll(:#{self.record_name}, :#{self.method}, #{source}.#{@choices}.collect{|item| [item.#{@item_label}, item.id]})" # ", options[:options], #{@options.merge('data-refresh'=>url_for(options[:choices].merge(:controller=>:interfacers, :action=>:unroll_options)), 'data-id-parameter-name'=>'selected').inspect} )"
    # end

    # def string_input(varc)
    #   @options[:size] ||= 24
    #   if column and !column.limit.nil?
    #     @options[:size] = column.limit if column.limit<@options[:size]
    #     @options[:maxlength] = column.limit
    #   end
    #   return "#{varc} << text_field(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    # end

    # def text_area_input(varc)
    #   @options[:cols] ||= 40
    #   @options[:rows] ||= 3
    #   @options[:class] = "#{@options[:class]} #{@options[:cols]==80 ? :code : nil}".strip
    #   return "#{varc} << text_area(:#{self.record_name}, :#{self.method}, #{@options.inspect})\n"
    # end



  end

end
