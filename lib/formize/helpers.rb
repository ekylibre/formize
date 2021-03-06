module Formize
  DATE_FORMAT_TOKENS = {
    'dd' => '%d',
    'oo' => '%j',
    'D'  => '%a',
    'DD' => '%A',
    'mm' => '%m',
    'M'  => '%b',
    'MM' => '%B',
    'y'  => '%y',
    'yy' => '%Y'
  }.freeze
  TIME_FORMAT_TOKENS = {
    'HH' => '%H',
    'mm' => '%M',
    'ss' => '%S',
    'tt' => '%p',
    'TT' => '%P'
  }.freeze
                                                

  # @private
  module Helpers
    autoload :TagHelper, 'formize/helpers/tag_helper'
    autoload :FormHelper, 'formize/helpers/form_helper'
    autoload :FormTagHelper, 'formize/helpers/form_tag_helper'
  end
end
