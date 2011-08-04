module Formize

  module ActionController

    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods

      def formize(model=nil, &block)
        model ||= self.controller_name.to_s.singularize
        model = model.classify.constantize
        form = Formize::Form.new(model)
        if block_given?
          yield form
        else
          form.field_set do |f|
            for column in model.columns
              next if column.name =~ /_count$/
              if column.name =~ /_id$/
                reflections = model.reflection.select{|x| x.primary_key_name.to_s == column.name.to_s }
                if reflections.size == 1
                  f.field(column.name.gsub(/_id$/, ''))
                  # elsif reflections.size > 1 # AMBIGUITY
                  # elsif reflections.size < 1 # NOTHING
                end
              else
                f.field(column.name)
              end
            end
          end
        end

        class_eval(form.send(:generate_controller_method_code), __FILE__, __LINE__)
        ActionView::Base.send(:class_eval, form.send(:generate_view_methods_code), __FILE__, __LINE__)
      end

    end

  end


  module ViewsHelper

    def formize_form(*args)
      name, options = nil, {}
      name = args[0] if args[0].is_a? Symbol
      options = args[-1] if args[-1].is_a? Hash
      self.send("_#{options[:controller]||self.controller_name}_#{__method__}_#{name||self.controller_name}_tag")
    end

    def formize_fields(*args)
      name, options = nil, {}
      name = args[0] if args[0].is_a? Symbol
      options = args[-1] if args[-1].is_a? Hash
      self.send("_#{options[:controller]||self.controller_name}_#{__method__}_#{name||self.controller_name}_tag")
    end

  end

end

ActionController::Base.send(:include, Formize::ActionController)
ActionView::Base.send(:include, Formize::ViewsHelper)
