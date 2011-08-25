require 'rails'

module Formize

  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    unless ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR >= 1
      def copy_assets
        copy_file '../../../../assets/javascripts/formize.js',  'public/javascripts/formize.js'
        # copy_file '../../../../assets/stylesheets/formize.css', 'public/stylesheets/formize.css'
      end
    end

    def copy_initializer_file
      template "initializer.rb", "config/initializers/formize.rb"
    end
  end

end
