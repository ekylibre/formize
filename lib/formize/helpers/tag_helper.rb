module Formize
  module Helpers
    module TagHelper

      # Permits to use content_tag in helpers using string concatenation
      def hard_content_tag(name, options={}, escape=true, &block)
        content = ''
        yield content
        return content_tag(name, content.html_safe, options, escape)
      end      

    end
  end
end
