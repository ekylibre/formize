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
        name_id = name.to_s.gsub(/[^a-z]+/, '_')
        html  = ""
        html << hidden_field_tag(name, (value.is_a?(Date) ? value.to_s(:db) : value.to_s), :id => name_id)
        html << tag(:input, :type=>:text, "data-datepicker" => name_id, "data-date-format" => format, :value => localized_value, "data-locale" => ::I18n.locale, :size => options.delete(:size)||10)
        return html.html_safe
      end

      # Returns a text field with a default placeholder for timestamp
      def datetime_field_tag(name, value=nil, options={})
        default = {}
        default[:placeholder] = I18n.translate!('time.placeholder') rescue nil
        default[:size] ||= 24
        return text_field_tag(name, value, default.merge(options))
      end


    end
  end
end
