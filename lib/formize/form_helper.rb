module Formize
  module FormHelper

    # Include all stylesheets, javascripts and locales
    # For Rails 3.0, not needed in Rails 3.1
    def formize_include_tag(options={})
      options[:locale] ||= I18n.locale
      html  = ""
      html << javascript_include_tag('jquery.ui.formize')
      html << javascript_include_tag('locales/jquery.ui.datepicker-' + locale.to_s)
      html << javascript_include_tag('formize')
      html << stylesheet_link_tag('jquery-ui')
      html << stylesheet_link_tag('formize') unless options[:skip_stylesheet]
      return html.html_safe
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

    # Permits to use content_tag in helpers with easy add
    def hard_content_tag(name, options={}, escape=true, &block)
      content = ''
      yield content
      return content_tag(name, content.html_safe, options, escape)
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
    # Options are:
    #  - +:format+: If +format+ is a +String+ it specify date format using a little subset of strftime options
    #               %d, %j, %a, %A, %m, %b, %B, %y and %Y
    #               else if +format+ is a +Symbol+ it uses I18n to find format
    def date_field(object_name, method, options = {})
      object = instance_variable_get("@#{object_name}")
      format = options[:format]||:default
      format = I18n.translate('date.formats.'+format.to_s) if format.is_a?(Symbol)
      conv = {
        'dd' => '%d',
        'oo' => '%j',
        'D'  => '%a',
        'DD' => '%A',
        'mm' => '%m',
        'M'  => '%b',
        'MM' => '%B',
        'y'  => '%y',
        'yy' => '%Y'
      }
      conv.each{|js, rb| format.gsub!(rb, js)}
      html  = ""
      html << hidden_field(object_name, method)
      html << tag(:input, :type=>:text, "data-datepicker"=>"#{object_name}_#{method}", "data-date-format"=>format, "data-locale"=>I18n.locale, :size=>options.delete(:size)||10)
      return html
    end

    
    # Returns a text field for selecting a Date with hour 
    # with a hidden field containing the well formatted datetime
    def datetime_field(object_name, method, options = {})
      object = instance_variable_get("@#{object_name}")
      html  = ""
      html << hidden_field(object_name, method)
      html << tag(:input, :type=>:text, "data-datepicker"=>"#{object_name}_#{method}", :size=>options.delete(:size)||10)
      return html
    end

    
    # Returns a text area which can be resized in the south-east corner
    # Works exactly the same as +textarea+
    def resizable_text_area(object_name, method, options = {})
      options["data-resize-in"] = "ri"+rand.to_s[2..-1].to_i.to_s(36)
      return content_tag(:div, text_area(object_name, method, options), :id=>options["data-resize-in"], :class=>"input")
    end


  end

end

ActionView::Base.send :include, Formize::FormHelper
