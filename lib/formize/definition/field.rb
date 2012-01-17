module Formize

  module Definition

    # Represents the field element
    class Field < FormElement
      attr_reader :name, :column, :record_name, :method, :type, :required, :choices, :input_id, :source, :item_label, :field_id, :reflection, :html_options, :default, :search_attributes

      TYPES = [:check_box, :choice, :date, :datetime, :label, :numeric, :password, :mono_choice, :string, :text_area].freeze

      def initialize(form, parent, name, options={})
        super(form, parent, options)
        @name = name.to_s
        @column = form.model.columns_hash[@name]
        @record_name = form.record_name
        @method = @name
        unless @options[:default].nil?
          @default = @options.delete(:default) # (@options[:default].is_a?(String) ? Formize::Generator::Code.new(@options[:default]) : @options[:default])
        end
        @html_options = @options.delete(:html_options)||{}
        @depend_on = @options.delete(:depend_on)
        raise ArgumentError.new("A depended element must defined before its dependencies (#{@depended.inspect})") if !@depend_on.blank? and form.all_fields[@depend_on].nil?
        if type = @options.delete(:as)
          raise ArgumentError.new("Unknown field type (got #{@options[:as].inspect}, expects #{TYPES.join(', ')})") unless TYPES.include? type
          @type = type
        else
          @type = :password if @name.to_s.match /password/
          if @choices = @options.delete(:choices)
            if @choices.is_a? Array
              @type = :choice 
            elsif [Symbol, Hash].include? @choices.class
              @type = :mono_choice 
              @reflection = form.model.reflections[@method.to_sym]
              @source = @options.delete(:source) # || @reflection.class_name
              @is_method = true if @options[:new]
              @method_name = self.form.unique_name + "_inf_" + @name
              @method = @reflection.send(Formize.foreign_key)
              unless @item_label = @options.delete(:item_label)
                model = @reflection.class_name.constantize
                available_methods = (model.columns_hash.keys+model.instance_methods).collect{|x| x.to_s}
                @item_label = [:label, :name, :title, :code, :number, :inspect].detect{|x| available_methods.include?(x.to_s)}
              end
              @search_attributes = @options[:search] || @reflection.class_name.constantize.content_columns.select{|c| c.type != :boolean and ![:created_at, :updated_at, :lock_version].include?(c.name.to_sym)}.collect{|c| c.name.to_sym}
            else
              raise ArgumentError.new("Option :choices must be Array, Symbol or Hash (got #{@choices.class.name})")
            end
          end
          if column
            @type = :check_box if column.type == :boolean
            @type = :date if column.type == :date
            @type = :datetime if column.type==:datetime or column.type==:timestamp
            @type = :numeric if [:integer, :float, :decimal].include? column.type
            @type = :text_area if column.type == :text
          end
          @type = :label if @form.model.readonly_attributes.include? @record_name
          @type ||= :string
        end
        @required = false
        @required = !@column.null if @column
        @required = true if @options.delete(:required).is_a?(TrueClass)
        @input_id = form.model.name.underscore << '_' << method.to_s
        @field_id = "ff" << Time.now.to_i.to_s(36) << rand.to_s[2..-1].to_i.to_s(36)
      end

    end

  end

end
