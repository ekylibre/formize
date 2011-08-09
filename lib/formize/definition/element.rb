module Formize

  # Main class for Form definitions
  # It permits to manage tree of form elements
  class Element
    attr_reader :parent, :children, :method_name, :id
    @@count = 0

    def initialize(parent = nil, is_method = false)
      @parent = parent
      @children = []
      @is_method = is_method
      @@count += 1
      @id = @@count.to_s(36)
      @method_name = "_formize_#{@id}"
    end

    def is_method?
      @is_method
    end

    def is_method!(value = true)
      raise ArgumentError.new("Must be true or false (not #{value.inspect})") unless [TrueClass, FalseClass].include?(value.class)
      @is_method = value
    end

    def method_name=(name)
      raise ArgumentError.new("Name of field_set must be written only with a-z and 0-9 and _ (not #{name.inspect})") unless name.to_s == name.to_s.downcase.gsub(/[^a-z0-9\_]/, '')
      @method_name = name
    end


    def method_code(options={})
      varh = options[:html_variable] ||= 'html'
      code  = "def #{method_name}(record)\n"
      code << inner_method_code(options).gsub(/^/, '  ')
      code << "  return #{varh}\n"
      code << "end\n"
      return code
    end

    def method_call_code(options={})
      return inner_method_code(options) unless self.is_method?
      return "#{method_name}(record)"
    end

    def inner_method_code(options={})
      # raise NotImplementedError.new
      return content_tag(:strong, "'#{self.class.name} does not implement :#{__method__} method'", options)
    end


  end


end
