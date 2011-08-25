module Formize

  module ActionController

    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods

      # Generates controller and view method working together
      # This methods allows to develop dynamic forms without using partials
      # and another action, only formize or formize_*.
      def formize(*args, &block)
        name, options = nil, {}
        name = args[0] if args[0].is_a? Symbol
        options = args[-1] if args[-1].is_a? Hash
        name ||= self.controller_name.to_sym
        model = (options[:model]||name).to_s.classify.constantize
        options[:controller_method_name] = "formize#{'_'+name.to_s if name != self.controller_name.to_sym}"
        options[:view_form_method_name]   = "_#{self.controller_name}_formize_form_#{name}_tag"
        options[:view_fields_method_name] = "_#{self.controller_name}_formize_fields_#{name}_tag"
        options[:method_name] = options[:view_fields_method_name]
        form = Formize::Form.new(name, model, options)
        if block_given?
          yield form
        else
          formize_by_default(form)
        end
        generator = Formize::Generator.new(form, self)
        class_eval(generator.controller_code, "#{__FILE__}:#{__LINE__}")
        ActionView::Base.send(:class_eval, generator.view_code, "#{__FILE__}:#{__LINE__}")
      end

      private

      # Generates list of usable field 
      def formize_by_default(form)
        form.field_set(:general) do |f|
          for column in form.model.columns
            next if column.name =~ /_count$/ or [:id, :created_at, :updated_at, :lock_version, :type, :creator_id, :updater_id].include?(column.name.to_sym)
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
        return form
      end

    end

  end

end

require 'action_controller'
ActionController::Base.send(:include, Formize::ActionController)
