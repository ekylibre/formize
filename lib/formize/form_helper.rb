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


    # def formize_for(record, options, &block)
    #   return ""
    # end

    # def formize_fields_for(record_or_name_or_array, *args, &block)
    #   raise ArgumentError, "Missing block" unless block_given?
    #   options = args.extract_options!
    
    #   case record_or_name_or_array
    #   when String, Symbol
    #     record_name = record_or_name_or_array
    #     record_object = args.first
    #   else
    #     record_object = record_or_name_or_array
    #     record_name = ActionController::RecordIdentifier.singular_class_name(record_object)
    #   end

    #   file, line = caller[0].split(/\:/)[0..1]
    #   method_name = "_run_" << __method__.to_s << "_" << record_name.to_s << "_in_" << file.gsub(Rails.root, '').gsub(/(^[\\\/]+|[\\\/]+$)/, '').gsub(/\W/){|c| c[0].to_s} << "_at_" << line
    

    #   # Compile method if not already done
    #   #unless Formize::CompiledForms.respond_to?(method_name)
    #   #  Formize::Compiler.compile_fields_for(method_name, record_name, options, &block)
    #   #end
    #   Formize::Compiler.compile_fields_for(method_name, record_name, options, &block)

    #   # Test evaluation of method
    #   raise Exception.new("Undefined method " << method_name.inspect) unless Formize::CompiledForms.respond_to?(method_name)

    #   return Formize::CompiledForms.send(method_name, record_object, self)
    # end


    # Permits to use content_tag in helpers with easy add
    def hard_content_tag(name, options={}, escape=true, &block)
      content = ''
      yield content
      return content_tag(name, content, options, escape)
    end


    # Returns a list of radio buttons for specified attribute (identified by +method+)
    # on an object assigned to the template (identified by +object+). It works like +select+
    def radio(object, method, choices, options = {}, html_options = {})
      html = ""
      html_options[:class] ||= :rad
      for choice in choices
        html << content_tag(:span, radio_button(object, method, choice[1]) + '&nbsp;'.html_safe + label(object, method, choice[0], :value=>choice[1]), html_options)
      end
      return html
    end


    # Returns a text field which has the same behavior of +select+ but  with a search 
    # action which permits to find easily in very long lists...
    def unroll(object, method, choices, options = {}, html_options = {})
      html  = ""
      html << hidden_field(object, method)
      html << text_field_tag(object, method, "data-unroll"=>url_for())
      html << tag(:div, "data-unroll"=>url_for())
      return content_tag(:span, html, html_options)
    end



  end

end

ActionView::Base.send :include, Formize::FormHelper
