module Formize
  module Helpers
    module FormTagHelper


      def date_field_tag(name, value=nil, options={})
        format = options[:format]||:default
        raise ArgumentError.new("Option :format must be a Symbol referencing a translation 'date.formats.<format>'")unless format.is_a?(Symbol)
        unless (localized_value = value).nil?
          localized_value = I18n.localize(localized_value, :format=>format)
        end
        format = I18n.translate('date.formats.'+format.to_s)
        Formize::DATE_FORMAT_TOKENS.each{|js, rb| format.gsub!(rb, js)}        
        html  = ""
        html << hidden_field_tag(name, value.to_s(:db))
        html << tag(:input, :type=>:text, "data-datepicker"=>name, "data-format"=>format, :value=>localized_value, "data-locale"=>::I18n.locale, :size=>options.delete(:size)||10)
        return html
      end


      def datetime_field_tag(name, value=nil, options={})
        format = options[:format]||:default
        raise ArgumentError.new("Option :format must be a Symbol referencing a translation 'time.formats.<format>'")unless format.is_a?(Symbol)
        unless (localized_value = value).nil?
          localized_value = I18n.localize(localized_value, :format=>format)
        end
        format = I18n.translate('time.formats.'+format.to_s)
        Formize::TIME_FORMAT_TOKENS.each{|js, rb| format.gsub!(rb, js)}        
        html  = ""
        html << hidden_field_tag(name, value.to_s(:db))
        html << tag(:input, :type=>:text, "data-datetimepicker"=>name, "data-format"=>format, :value=>localized_value, "data-locale"=>::I18n.locale, :size=>options.delete(:size)||10)
        return html
      end


    end
  end
end
