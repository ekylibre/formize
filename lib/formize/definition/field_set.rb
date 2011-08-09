module Formize



  # Represents a group of fields which can depend on other fields
  class FieldSet < FormElement
    attr_reader :name, :options, :title, :html_options
    
    def initialize(form, parent, name=nil, options={})
      super(form, parent)
      @title = nil
      @name = if name.blank?
                rand.to_s[2..-1].to_i.to_s(36)
              else
                raise ArgumentError.new("Name of field_set must be written only with a-z and 0-9 and _ (not #{name.inspect})") unless name.to_s == name.to_s.downcase.gsub(/[^a-z0-9\_]/, '')
                @title = name
                name.to_s
              end
      @depend_on = options.delete(:depend_on)
      raise ArgumentError.new("A depended element must defined before its dependencies (#{@depended.inspect})") if !@depend_on.blank? and form.fields[@depend_on].nil?
      @options = (options.is_a?(Hash) ? options : {})
      @html_options = @options.delete(:html_options)||{}
    end


    def field_set(name=nil, options={}, &block)
      raise ArgumentError.new("Missing block") unless block_given?
      field_set = self.new_child(FieldSet, name, options)
      yield field_set
    end

    def field(name, options={})
      self.new_child(Field, name, options)
    end

  end



end
