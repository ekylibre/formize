require 'formize/railtie' if defined?(::Rails)
require 'formize/engine' if defined?(::Rails)

# :include: ../README.rdoc
module Formize
  extend ActiveSupport::Autoload

  def self.configure(name, value = nil) # :nodoc:
    unless self.respond_to?("#{name}=")
      # mattr_accessor(name)
      code  = "unless defined?(@@#{name})\n"
      code << "  @@#{name} = nil\n"
      code << "end\n"
      code << "def self.#{name}\n"
      code << "  @@#{name}\n"
      code << "end\n"
      code << "def self.#{name}=(obj)\n"
      code << "  @@#{name} = obj\n"
      code << "end\n"
      class_eval(code, __FILE__, __LINE__ + 1)
      self.send("#{name}=", value)
    end
  end

  # default_source used by mono_choices:
  # - :foreign_class : Class of foreign object
  # - :class : Class of object
  # - "variable_name" or :variable_name : A variable (Class name is computed with the name
  #     of the variable. Example: "product" will have "Product" class_name. If class_name 
  #     has to be different, use next possibility.
  # - ["variable_name", "class_name"] : Code used to select source with the 
  #     class_name of the variable.
  configure :default_source, :foreign_class

  # How many radio can be displayed before to become a +select+
  configure :radio_count_max, 3

  # How many select options can be displayed before to become a +unroll+
  configure :select_count_max, 7





  # Compile a monolithic javascript file formize.js with all included
  def self.compile!
    # js_dir = Pathname.new(File.dirname(__FILE__)).join("..", "assets", "javascripts")
    js_dir = File.join(File.dirname(__FILE__), "assets", "javascripts")
    File.open("#{js_dir}/formize.js", "wb") do |js|
      js.write "(function($) {\n"
      for file in Dir.glob("#{js_dir}/locales/jquery.ui.datepicker*.js").sort
        File.open(file, "rb") do |f|
          source = f.read
          source.gsub!("jQuery(function($){", '')
          source.gsub!(/\/\*[^\*\/]*\*\//, '')
          source.gsub!(/\$\.datepicker\.setDefaults\(\$\.datepicker\.regional\[\'\w\w(\-\w\w)?\'\]\)\;/, '')
          source.gsub!("});", '')
          source = source.strip.split(/\n/).collect{|l| l.strip}.join(" ").strip.sub(/^.*\$/, '$')
          js.write source
          # js.write f.read
          js.write "\n"
        end
      end
      # js.write "})(jQuery);\n"
      # File.open("#{js_dir}/jquery.ui.timepicker.js", "rb") do |f|
      #   js.write f.read
      #   js.write "\n"
      # end
      # js.write "(function($) {\n"
      # for file in Dir.glob("#{js_dir}/locales/jquery.ui.timepicker*.js").sort
      #   File.open(file, "rb") do |f|
      #     source = f.read
      #     source.gsub!("(function($) {", '')
      #     source.gsub!(/\/\*[^\*\/]*\*\//, '')
      #     source.gsub!(/\$\.timepicker\.setDefaults\(\$\.timepicker\.regional\[\'\w\w(\-\w\w)?\'\]\)\;/, '')
      #     source.gsub!("})(jQuery)\;", '')
      #     source = source.strip.split(/\n/).collect{ |l| l.gsub(/^\s*/, '')}.join(" ").sub(/^.*\$/, '$')
      #     js.write source
      #     js.write "\n"
      #   end
      # end
      # js.write "})(jQuery);\n"
      File.open("#{js_dir}/jquery.ui.formize.js", "rb") do |f|
        js.write f.read
        js.write "\n"
      end
    end

  end







  autoload :Definition
  autoload :Helpers
  autoload :ActionController
  autoload :Generator
end
