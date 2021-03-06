module Formize
  # @private
  module Definition
    autoload :Form, 'formize/definition/form'
    autoload :FormElement, 'formize/definition/form_element'
    autoload :Group,    'formize/definition/field_set'
    autoload :FieldSet, 'formize/definition/field_set'
    autoload :Field, 'formize/definition/field'
  end
end
