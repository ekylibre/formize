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
      # @option options [TrueClass, FalseClass] :monolithic
      #   If +true+ includes a monolithic javascript formize.js else include
      #   choosen specific javascripts with little weight.
      # 
      # @deprecated Will be removed when rails <= 3.0 support won't be effective in 
      #   versions >= 0.1.0
      def formize_include_tag(options={})
        options[:locale] ||= ::I18n.locale
        html  = ""
        if options[:monolithic]
          html << javascript_include_tag('formize')
        else
          html << javascript_include_tag('locales/jquery.ui.datepicker-' + locale.to_s+)
          html << javascript_include_tag('jquery.ui.formize')
        end
        unless options[:skip_stylesheet]
          html << stylesheet_link_tag('jquery-ui')
          html << stylesheet_link_tag('formize') 
        end
        return html.html_safe
      end

    end
  end
end
