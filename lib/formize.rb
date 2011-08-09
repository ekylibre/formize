# Formize provides controller's side defined forms.
module Formize

  def self.configure(name, value = nil)
    unless self.respond_to?("#{name}=")
      mattr_accessor(name) 
      self.send("#{name}=", value)
    end
  end

  # default_source used by mono_choices:
  # - :foreign_class : Class of foreign object
  # - :class : Class of object
  # - <string> : Code used to select source
  configure :default_source, :foreign_class

  # How many radio can be displayed before to become a +select+
  configure :radio_count_max, 3

  # How many select options can be displayed before to become a +unroll+
  configure :select_count_max, 7

end

require 'action_view'
require 'formize/definition'
require 'formize/generator'
require 'formize/form_helper'
require 'formize/action_pack'

