require 'rails'

module Formize

  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    # class_option :no_ui, :type => :boolean, :default => false, :desc => "Do not include special jQuery-UI JavaScripts"
    class_option :no_locales, :type => :boolean, :default => false, :desc => "Do not include locales for jQuery-UI date picker"
    class_option :no_stylesheet, :type => :boolean, :default => false, :desc => "Do not include stylesheet of jQuery-UI"

    unless ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR >= 1
      def copy_assets
        copy_file '../../../../assets/javascripts/formize.js',  'public/javascripts/formize.js'

        # unless options[:no_ui]
        copy_file '../../../../assets/javascripts/jquery.ui.formize.js',  'public/javascripts/jquery.ui.formize.js'
        # end

        unless options[:no_locales]
          for locale in Dir.glob(File.expand_path('../../../../assets/javascripts/locales/*datepicker*.js', __FILE__))
            file = locale.split(/[\\\/]+/)[-1]
            copy_file "../../../../assets/javascripts/locales/#{file}",  "public/javascripts/locales/#{file}"
          end
        end

        copy_file '../../../../assets/stylesheets/formize.css', 'public/stylesheets/formize.css'

        unless options[:no_stylesheet]
          copy_file '../../../../assets/stylesheets/jquery-ui.css', 'public/stylesheets/jquery-ui.css'
          for image in Dir.glob(File.expand_path('../../../../assets/images/*.png', __FILE__))
            file = image.split(/[\\\/]+/)[-1]
            copy_file "../../../../assets/images/#{file}",  "public/images/#{file}"
          end
        end

      end
    end

    def copy_initializer_file
      template "initializer.rb", "config/initializers/formize.rb"
    end
  end

end
