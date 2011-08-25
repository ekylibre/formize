module Formize

  class InstallGenerator < Rails::Generator::Base

    unless ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR >= 1
      def copy_assets
        copy_file '../../../assets/javascripts/formize.js',  'public/javascripts/formize.js'
        # copy_file '../../../assets/stylesheets/formize.css', 'public/stylesheets/formize.css'
      end
    end

    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/formize.rb"
    end
  end

end
