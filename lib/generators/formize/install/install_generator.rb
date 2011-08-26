require 'rails'

module Formize

  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    unless ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR >= 1
      def copy_assets
        copy_file '../../../../assets/javascripts/formize.js',  'public/javascripts/formize.js'
        copy_file '../../../../assets/javascripts/jquery.ui.formize.js',  'public/javascripts/jquery.ui.formize.js'
        for locale in Dir.glob(File.expand_path('../../../../assets/javascripts/locales/*.js', __FILE__))
          file = locale.split(/[\\\/]+/)[-1]
          copy_file "../../../../assets/javascripts/locales/#{file}",  "public/javascripts/locales/#{file}"
        end
        copy_file '../../../../assets/stylesheets/formize.css', 'public/stylesheets/formize.css'
        copy_file '../../../../assets/stylesheets/jquery-ui.css', 'public/stylesheets/jquery-ui.css'
        for image in Dir.glob(File.expand_path('../../../../assets/images/*.png', __FILE__))
          file = image.split(/[\\\/]+/)[-1]
          copy_file "../../../../assets/images/#{file}",  "public/images/#{file}"
        end
      end
    end

    def copy_initializer_file
      template "initializer.rb", "config/initializers/formize.rb"
    end
  end

end
