module Formize
  module Helpers
    module AssetTagHelper

      # Include all stylesheets, javascripts and locales.
      # For Rails 3.0 only, not needed since Rails 3.1.
      #
      # @example Classic use
      #   <%= formize_include_tag -%>
      #
      # @example Classic use with a specified locale
      #   <%= formize_include_tag :locale=>:jp -%>
      #
      # @option options [Symbol, String] :locale
      #   Select locale file to use for jQuery UI datepickers. The locale must be 
      #   specified using 2 or 5 characters, like `:en` or `"en-GB"`.
      #   By default, `I18n.locale` is used to determine the current locale.
      #
      # @option options [TrueClass, FalseClass] :skip_stylesheet
      #   Skip the inclusion of default stylesheet: formize.css
      # 
      # @option options [TrueClass, FalseClass] :with_formize
      #   Include main javascript formize.js
      # 
      # @deprecated
      def formize_include_tag(options={})
        options[:locale] ||= ::I18n.locale
        html  = ""
        html << javascript_include_tag('jquery.ui.formize') if options[:special_ui]
        html << javascript_include_tag('locales/jquery.ui.datepicker-' + locale.to_s)
        html << javascript_include_tag('formize') if options[:with_formize]
        unless options[:skip_stylesheet]
          html << stylesheet_link_tag('jquery-ui')
          html << stylesheet_link_tag('formize') 
        end
        return html.html_safe
      end


    end
  end
end
