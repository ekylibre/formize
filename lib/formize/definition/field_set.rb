module Formize

  # Represents a group of fields which can depend on other fields
  class Group < FormElement
    attr_reader :name, :options, :html_options
    
    def initialize(form, parent, name=nil, options={})
      super(form, parent, options)
      @name = if name.blank?
                rand.to_s[2..-1].to_i.to_s(36)
              else
                raise ArgumentError.new("Name of group must be written only with a-z and 0-9 and _ (not #{name.inspect})") unless name.to_s == name.to_s.downcase.gsub(/[^a-z0-9\_]/, '')
                name.to_s
              end
      @depend_on = options.delete(:depend_on)
      raise ArgumentError.new("A depended element must defined before its dependencies (#{@depended.inspect})") if !@depend_on.blank? and form.all_fields[@depend_on].nil?
      @html_options = @options.delete(:html_options)||{}
    end


    def field_set(name=nil, options={}, &block)
      raise ArgumentError.new("Missing block") unless block_given?
      field_set = self.new_child(FieldSet, name, options)
      yield field_set
    end

    def group(name=nil, options={}, &block)
      raise ArgumentError.new("Missing block") unless block_given?
      name, options = nil, name if name.is_a? Hash
      group = self.new_child(Group, name, options)
      yield group
    end

    def field(name, options={})
      self.new_child(Field, name, options)
    end

    def fields(*args)
      options = {}
      options = args.delete_at(-1) if args[-1].is_a?(Hash)
      for name in args
        self.new_child(Field, name, options)
      end
    end

  end


  # Represents a set of fields which can depend on other fields
  # It can be used with a title
  class FieldSet < Group
    attr_reader :title
    
    def initialize(form, parent, name=nil, options={})
      super(form, parent, name, options)
      @title = name
    end

  end


end
