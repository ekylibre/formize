module Formize

  class Form


    def generate_controller_method_code
      code  = "def formize_#{self.model.controller_method_name}\n"
      

      code << "end\n"
      
      list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}
      return code
    end

    def generate_view_methods_code
    end
    

    def self.compile_fields_for(method_name, record_name, options={}, &block)
      model = record_name.classify.constantize
      form = Formize::Form.new(model, method_name)
      yield form

      code  = ""

      for element in form.methodics
        code << "# #{element.class.name} #{element.object_id}\n"
        code << element.method_code
      end


      raise code
      # Formize::CompiledForms.module_eval(code, __FILE__, __LINE__)
      # raise code
      return code
    end

  end
  
end
