module YasuiForm
  module ActionView

    module FormHelper

      def yasui_form_for(record, options, &block)
        return ""
      end

      def yasui_fields_for(record_or_name_or_array, *args, &block)
        raise ArgumentError, "Missing block" unless block_given?
        options = args.extract_options!
        
        case record_or_name_or_array
        when String, Symbol
          record_name = record_or_name_or_array
          record_object = args.first
        else
          record_object = record_or_name_or_array
          record_name = ActionController::RecordIdentifier.singular_class_name(record_object)
        end

        file, line = caller[0].split(/\:/)[0..1]
        method_name = "_run_" << __method__.to_s << "_" << record_name.to_s << "_in_" << file.gsub(Rails.root, '').gsub(/(^[\\\/]+|[\\\/]+$)/, '').gsub(/\W/){|c| c[0].to_s} << "_at_" << line
        

        # Compile method if not already done
        #unless YasuiForm::CompiledForms.respond_to?(method_name)
        #  YasuiForm::Compiler.compile_fields_for(method_name, record_name, options, &block)
        #end
        YasuiForm::Compiler.compile_fields_for(method_name, record_name, options, &block)

        # Test evaluation of method
        raise Exception.new("Undefined method " << method_name.inspect) unless YasuiForm::CompiledForms.respond_to?(method_name)

        return YasuiForm::CompiledForms.send(method_name, record_object, self)
      end


      # Permits to use content_tag in helpers with easy add
      def hard_content_tag(name, options={}, escape=true, &block)
        content = ''
        yield content
        return content_tag(name, content, options, escape)
      end


    end

  end
end

ActionView::Base.send :include, YasuiForm::ActionView::FormHelper
