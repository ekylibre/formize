module Formize
  module FormHelper

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
      html << tag(:input, :type=>:text, "data-unroll"=>url_for(choices), "data-value-container"=>"#{object_name}_#{method}", :value=>label.call(object.send(method.to_s.gsub(/_id$/, ''))), :size=>html_options.delete(:size)||32)
      return content_tag(:span, html, html_options)
    end

    
    # Returns a text field for selecting a Date with a hidden field containing
    # the well formatted date
    def date_field(object_name, method, options = {})
      object = instance_variable_get("@#{object_name}")
      html  = ""
      html << hidden_field(object_name, method)
      html << tag(:input, :type=>:text, "data-datepicker"=>"#{object_name}_#{method}", :size=>options.delete(:size)||10)
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


  end

end

ActionView::Base.send :include, Formize::FormHelper
