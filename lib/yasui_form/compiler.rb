module YasuiForm

  # Module which is used to localize every comiled forms
  module CompiledForms
  end


  class Compiler

    

    def self.compile_fields_for(method_name, record_name, options={}, &block)
      model = record_name.classify.constantize
      form = YasuiForm::Form.new(model, method_name)
      yield form

      code  = ""

      for element in form.methodics
        code << "# #{element.class.name} #{element.object_id}\n"
        code << element.method_code
      end

      # code << "# #{form.class.name} #{form.object_id}\n"
      # code << form.method_code

      # # Build field_set methods
      # for field_set in form.field_sets
      #   code << "def self.#{field_set.method_name}(record, view=nil)\n"
      #   code << "  html  = ''\n"
      #   code << "  html << '<fieldset>'\n"
      #   unless field_set.title.nil?
      #     code << "  html << '<legend>' << ::I18n.translate('labels.#{field_set.title}') << '</legend>'\n"          
      #   end
      #   for field in field_set.fields
      #     code << "  html << '<div class=\"field\">'\n"
      #     code << "  html << '<label>' << #{form.model.name}.human_attribute_name(:#{field.name}) << '</label>'\n"
      #     code << "  html << " << field.to_html << "\n"
      #     code << "  html << '</div>'\n"
      #   end
      #   code << "  html << '</fieldset>'\n"
      #   code << "  return html\n"
      #   code << "end\n"
      # end

      # # Build main method
      # code << "def self.#{form.method_name}(record, view=nil)\n"
      # code << "  html = ''\n"
      # for field_set in form.field_sets
      #   code << "  html << " << field_set.method_name << "(record, view)\n"
      # end
      # code << "  return html\n"
      # code << "end\n"


      raise code
      YasuiForm::CompiledForms.module_eval(code, __FILE__, __LINE__)
      # raise code
      return code
    end

  end
  
end
