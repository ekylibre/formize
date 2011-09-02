# require 'rubygems'
# require 'bundler/setup'
# require 'active_support'
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

  autoload :Definition
  autoload :Helpers
  autoload :ActionController
  autoload :Generator
end

# require 'action_view'

