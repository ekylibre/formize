module Formize
  module Helpers
    module FormHelper

      # Code picked from Justin French's formtastic gem
      FIELD_ERROR_PROC = proc do |html_tag, instance_tag| # :nodoc:
        html_tag
      end

      def with_custom_field_error_proc(&block) # :nodoc:
        default_field_error_proc = ::ActionView::Base.field_error_proc
        ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
        yield
      ensure
        ::ActionView::Base.field_error_proc = default_field_error_proc
      end

      # Generates a form with all its fields as defined in controller.
      # If no name is given, it uses the name of the controller to find the corresponding model
      def formize_form(*args)
        name, options = nil, {}
        name = args[0] if args[0].is_a? Symbol
        options = args[-1] if args[-1].is_a? Hash
        self.send("_#{options[:controller]||self.controller_name}_#{__method__}_#{name||self.controller_name}_tag")
      end

      # Generates all the fields as defined in controller with the <form> tag.
      # If no name is given, it uses the name of the controller to find the corresponding model
      def formize_fields(*args)
        name, options = nil, {}
        name = args[0] if args[0].is_a? Symbol
        options = args[-1] if args[-1].is_a? Hash
        self.send("_#{options[:controller]||self.controller_name}_#{__method__}_#{name||self.controller_name}_tag")
      end

      # Permits to create a submit button well named for the given record
      def submit_for(record, value=nil, options={})
        value, options = nil, value if value.is_a?(Hash)
        value ||= ::I18n.translate("helpers.submit.#{record.new_record? ? 'create' : 'update'}", :model=>record.class.model_name.human, :record=>record.class.model_name.human.mb_chars.downcase)
        submit_tag(value, options.reverse_merge(:id => "#{record.class.name.underscore}_submit"))
      end

      # Returns a list of radio buttons for specified attribute (identified by +method+)
      # on an object assigned to the template (identified by +object_name+). It works like +select+
      def radio(object_name, method, choices, options = {}, html_options = {})
        html = ""
        html_options[:class] ||= :rad
        for choice in choices
          html << content_tag(:span, radio_button(object_name, method, choice[1]) + '&nbsp;'.html_safe + label(object_name, method, choice[0], :value=>choice[1]), html_options)
        end
        return html
      end

      # Returns a text field which has the same behavior of +select+ but  with a search 
      # action which permits to find easily in very long lists...
      def unroll(object_name, method, choices, options = {}, input_options={}, html_options = {})
        object = instance_variable_get("@#{object_name}")
        label = options[:label]
        if label.is_a?(String) or label.is_a?(Symbol)
          label = Proc.new{|x| x.send(label)}
        elsif !label.is_a?(Proc)
          label = Proc.new{|x| x.inspect}
        end
        html  = ""
        html << hidden_field(object_name, method, input_options)
        html << tag(:input, :type=>:text, "data-unroll"=>url_for(choices.merge(:format=>:json)), "data-value-container"=>"#{object_name}_#{method}", :value=>label.call(object.send(method.to_s.gsub(/_id$/, ''))), :size=>html_options.delete(:size)||32)
        return content_tag(:span, html.html_safe, html_options)
      end

      
      # Returns a text field for selecting a Date with a hidden field containing
      # the well formatted date
      #
      # @example Set a date field
      #   <%= date_field :post, :published_on -%>
      #   # => <input type="hidden" id="post_published_on" name="post[published_on]" value="#{@post.published_on}"/>
      #   #    <input type="text" data-datepicker="post_published_on" data-date_format="<jQuery_format>" value="<formatted_date>" data-locale="#{I18n.locale}" size="10"/>
      #
      # @option options [Symbol] :format
      #   Select date format used in visible text field. The format must be defined in locale files. To maintain compatibility with jQuery only few tokens can be used to compose the format: `%d`, `%j`, `%a`, `%A`, `%m`, `%b`, `%B`, `%y` and `%Y`
      # @option options [Integer] :size
      #   Set the size of the visible text field
      def date_field(object_name, method, options = {})
        object = instance_variable_get("@#{object_name}")
        format = options[:format]||:default
        raise ArgumentError.new("Option :format must be a Symbol referencing a translation 'date.formats.<format>'")unless format.is_a?(Symbol)
        if localized_value = object.send(method)
          localized_value = I18n.localize(localized_value, :format=>format)
        end
        format = I18n.translate('date.formats.'+format.to_s) 
        Formize::DATE_FORMAT_TOKENS.each{|js, rb| format.gsub!(rb, js)}
        html  = ""
        html << hidden_field(object_name, method)
        html << tag(:input, :type=>:text, "data-datepicker"=>"#{object_name}_#{method}", "data-format"=>format, :value=>localized_value, "data-locale"=>::I18n.locale, :size=>options.delete(:size)||10)
        return html
      end

      
      # Returns a text field for selecting a DateTime/Time
      # with a hidden field containing the well formatted datetime
      def datetime_field(object_name, method, options = {})
        object = instance_variable_get("@#{object_name}")
        format = options[:format]||:default
        raise ArgumentError.new("Option :format must be a Symbol referencing a translation 'time.formats.<format>'")unless format.is_a?(Symbol)
        if localized_value = object.send(method)
          localized_value = I18n.localize(localized_value, :format=>format)
        end
        format = I18n.translate('time.formats.'+format.to_s) 
        Formize::TIME_FORMAT_TOKENS.each{|js, rb| format.gsub!(rb, js)}
        html  = ""
        html << hidden_field(object_name, method)
        html << tag(:input, :type=>:text, "data-datetimepicker"=>"#{object_name}_#{method}", "data-format"=>format, :value=>localized_value, "data-locale"=>::I18n.locale, :size=>options.delete(:size)||10)
      end

      
      # Returns a text area which can be resized in the south-east corner
      # Works exactly the same as +textarea+
      def resizable_text_area(object_name, method, options = {})
        options["data-resizable"] = "true"
        return text_area(object_name, method, options)
      end


    end
  end
end
