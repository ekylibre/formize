module Formize

  # Permits to not quote text in inspect method
  class Code < String

    def inspect
      self.to_s
    end

  end


  class Generator
    
    attr_accessor :form, :elements, :record_name, :partial, :controller

    def initialize(form, controller)
      @form = form
      @controller = controller
      @record_name = @form.record_name
      @elements = form.all_elements
      @partials = @elements.select{|e| !e.depend_on.nil? or e.options[:new]}
    end


    # Generates the controller method from a form object
    def controller_code
      code  = "def #{form.controller_method_name}\n"

      # Mono_choice search/filter
      items = form.mono_choices
      if items.size > 0
        code << "  if params[:unroll]\n"
        events = form.mono_choices.collect do |mono_choice|
          event = "if params[:unroll] == '#{mono_choice.html_id}'\n"
          # event << mono_choice_search_code(mono_choice)
          event << "end\n"
        end
        code << events.collect{|e| e.gsub(/^/, '    ')}.join
        code << "  end\n"
      end
      
      # Dependencies refresh
      items = @partials
      if items.size > 0
        code << "  if params[:refresh]\n"
        code << "    #{record_name}   = #{form.model.name}.find(params[:id]) if params[:id].to_i > 0\n"
        code << "    #{record_name} ||= #{form.model.name}.new\n"
        code << "    @#{record_name} = #{record_name}\n"
        events = items.collect do |dependent|
          event  = "if params[:refresh] == '#{dependent.html_id}'\n"
          locals = {record_name.to_sym => Code.new(record_name)}
          for depended in dependent.dependeds
            df = form.fields[depended[:name]]
            event << "  #{df.name} = " << (df.reflection.nil? ? "params[:#{df.input_id}]" : "#{df.reflection.class_name}.find(params[:#{df.input_id}])") << "\n"
            locals[df.name.to_sym] = Code.new(df.name)
          end
          event << "  render(:inline=>'<%=#{dependent.prototype}-%>', :locals=>#{locals.inspect})\n"
          event << "end\n"
        end
        code << events.collect{|e| e.gsub(/^/, '    ')}.join
        code << "  end\n"
      end
      
      # End
      code << "end\n"  
      code.gsub!(/end\s*if/, 'elsif')
      # raise code
      list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}
      return code
    end



    # Generates the view method from a form object
    def view_code
      code  = ""

      varh = 'html'

      # Build view methods assimilated to partials
      for element in @partials
        code << "# #{element.class.name}: #{element.html_id}/#{element.name}\n"
        code << view_method_code(element, varh)
      end


      code << "\n"
      code << "def #{form.options[:view_fields_method_name]}(#{form.record_name}=nil)\n"
      code << "  #{form.record_name} = @#{form.record_name} unless #{form.record_name}.is_a?(#{form.model.name})\n"
      code << "  #{varh} = ''\n"
      for element in form.elements
        code << view_method_call(element, varh).strip.gsub(/^/, '  ') << "\n" # 
        # code << "  #{varh} << " << element.method_call_code.gsub(/^/, '  ').strip << "\n"
      end
      code << "  return #{varh}\n"
      code << "end\n"

      code << "\n"
      code << "def #{form.options[:view_form_method_name]}(#{form.record_name}=nil)\n"
      code << "  #{form.record_name} = @#{form.record_name} unless #{form.record_name}.is_a?(#{form.model.name})\n"
      code << "  return form_for(#{form.record_name}) do\n"
      code << "    #{form.options[:view_fields_method_name]}(#{form.record_name})\n"
      code << "  end\n"
      code << "end\n"

      # raise code
      list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}
      return code
    end
    



    
    def view_method_code(element, varh='varh')
      send("#{element.class.name.split('::')[-1].underscore}_view_method_code", element, varh)
    end

    def view_method_call(element, varh='varh')
      send("#{element.class.name.split('::')[-1].underscore}_view_method_call", element, varh)
    end

    #####################################################################################
    #                         F I E L D _ S E T     M E T H O D S                       #
    #####################################################################################
    
    def field_set_view_partial_code(field_set, varh='varh')
      # Initialize html attributes
      html_options = field_set.html_options
      # html_options[:class] = "formize #{html_options[:class]}".strip
      html_options["id"] = field_set.html_id
      html_options["data-refresh"] = Code.new("url_for(:controller=>:#{controller.controller_name}, :action=>:#{form.action_name}, :refresh=>'#{field_set.html_id}', :id=>#{record_name}.id)") if @partials.include?(field_set)

      varc = field_set.html_id # "field_set_#{field_set.html_id}"
      code  = "#{varh} << hard_content_tag(:fieldset, #{html_options.inspect}) do |#{varc}|\n"
      unless field_set.title.nil?
        code << "  #{varc} << content_tag(:legend, ::I18n.translate('labels.#{field_set.title}'))\n"
      end
      for child in field_set.children
        code << view_method_call(child, varc).strip.gsub(/^/, '  ') << "\n"
      end
      code << "end\n"
      return code
    end

    def field_set_view_method_code(field_set, varh='html')
      code  = "def #{field_set.prototype}\n"
      code << "  #{varh} = ''\n"
      code << field_set_view_partial_code(field_set, varh).strip.gsub(/^/, '  ') << "\n"
      code << "  return #{varh}\n"
      code << "end\n"
      return code
    end

    def field_set_view_method_call(field_set, varh='varh')
      code = ""
      call = if @partials.include?(field_set)
               "#{varh} << #{field_set.prototype}\n"
             else
               field_set_view_partial_code(field_set, varh).strip << "\n"
             end

      if field_set.depend_on
        depended_field = form.fields[field_set.depend_on]
        code << "#{field_set.depend_on} = #{form.record_name}.#{depended_field.name}\n"
        if ref = depended_field.reflection
          code << "#{field_set.depend_on} ||= #{field_datasource(depended_field)}.first\n"
        end
        code << "if #{field_set.depend_on}\n"
        code << call.strip.gsub(/^/, '  ') << "\n"
        code << "else\n"
        opt = {:id=>field_set.html_id, :class=>"waiting", "data-refresh"=>Code.new("url_for(:controller=>:#{controller.controller_name}, :action=>:#{form.action_name}, :refresh=>'#{field_set.html_id}')")}
        code << "  #{varh} << tag(:div, #{opt.inspect})\n"

        code << "end\n"
      else
        code = call
      end

      return code
    end

    #####################################################################################
    #                             F I E L D     M E T H O D S                           #
    #####################################################################################
      
    # varc  = "field_#{field.name}"
    # code  = ""
    # # Initialize html attributes
    # html_options = field.html_options
    # html_options[:id] = field.html_id
    # html_options[:class] = "field #{html_options[:class]}".strip
    # # html_options[:class] = "formize #{html_options[:class]}".strip
    # html_options[:class] = "#{html_options[:class]} #{field.type.to_s.gsub('_', '-')}".strip
    # html_options[:class] = "#{html_options[:class]} required".strip if field.required
    
    # # Call build method
    # if @partials.include?(field)
    #   code << "#{varh} << content_tag(:div, #{field.unique_name}(#{record_name}), #{html_options.inspect})"
    # else
    #   code << "#{varh} << hard_content_tag(:div, #{html_options.inspect}) do |#{varc}|\n"
    #   code << field_view_partial_code(field, varc).strip.gsub(/^/, '  ') << "\n"
    #   code << "end\n"
    # end
    # return code

    def field_view_partial_code(field, varh='varh')
      deps = form.dependents_on(field)
      input_attrs = (field.options[:input_options].is_a?(Hash) ? field.options[:input_options] : {})
      input_attrs["data-dependents"] = deps.collect{|d| d.html_id}.join(',') if deps.size > 0

      # Initialize html attributes
      html_options = field_wrapper_attrs(field)

      varc = field.html_id
      code  = "#{varh} << hard_content_tag(:div, #{html_options.inspect}) do |#{varc}|\n"
      code << "  #{varc} << label(:#{form.record_name}, :#{field.name}, nil, :class=>'attr')\n"
      code << "  #{form.record_name}.#{field.name} ||= #{field.default.inspect}\n" if field.default
      code << self.send("field_#{field.type}_input", field, input_attrs, varc).strip.gsub(/^/, '  ') << "\n"
      code << "end\n"
      return code
    end

    def field_view_method_code(field, varh='html')
      code  = "def #{field.prototype}\n"
      code << "  #{varh} = ''\n"
      code << field_view_partial_code(field, varh).strip.gsub(/^/, '  ') << "\n"
      code << "  return #{varh}\n"
      code << "end\n"
      return code
    end

    def field_view_method_call(field, varh='varh')
      code = ""
      call = if @partials.include?(field)
               "#{varh} << #{field.prototype}\n"
             else
               field_view_partial_code(field, varh).strip << "\n"
             end

      if field.depend_on
        depended_field = form.fields[field.depend_on]
        code << "#{field.depend_on} = #{form.record_name}.#{depended_field.name}\n"
        code << "if #{field.depend_on}\n"
        code << call.strip.gsub(/^/, '  ') << "\n"
        code << "else\n"
        attrs = field_wrapper_attrs(field)
        attrs[:class] = "#{attrs[:class]} waiting".strip
        code << "  #{varh} << tag(:div, #{attrs.inspect})\n"
        code << "end\n"
      else
        code = call
      end

      return code
    end


    def field_datasource(field)
      source = if !field.source.blank?
                 field.source
               elsif Formize.default_source == :foreign_class
                 field.reflection.class_name
               elsif Formize.default_source == :class
                 form.model.name
               else
                 Formize.default_source.to_s
               end
      return "#{source}.#{field.choices}"
    end
    
    def field_input_options(field)
    end

    def field_wrapper_attrs(field)
      html_options = field.html_options
      html_options[:id] = field.html_id
      if @partials.include?(field)
        url = {:controller => controller.controller_name.to_sym, :action=>form.action_name.to_sym, :refresh=>field.html_id}
        for depended in field.dependeds
          df = form.fields[depended[:name]]
          url[df.input_id.to_sym] = Code.new(df.reflection.nil? ? df.name : "#{df.name}.id")
        end
        html_options["data-refresh"] = Code.new("url_for(#{url.inspect})")
      end
      html_options[:class] = "field #{html_options[:class]}".strip
      html_options[:class] = "#{html_options[:class]} #{field.type.to_s.gsub('_', '-')}".strip
      html_options[:class] = "#{html_options[:class]} required".strip if field.required
      return html_options
    end




    def field_check_box_input(field, attrs={}, varc='varc')
      return "#{varc} << check_box(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end

    def field_choice_input(field, attrs={}, varc='varc')
      code = if field.choices.size <= Formize.radio_count_max
               field_radio_input(field, attrs, varc)
             else
               field_select_input(field, attrs, varc)
             end
      return code
    end

    def field_date_input(field, attrs={}, varc='varc')
      attrs[:size] ||= 16
      return "#{varc} << date_field(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end

    def field_datetime_input(field, attrs={}, varc='varc')
      attrs[:size] ||= 16
      return "#{varc} << datetime_field(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end

    def field_label_input(field, attrs={}, varc='varc')
      attrs[:class] = (attrs[:class]+" readonly").strip
      return "#{varc} << content_tag(:span, @:#{field.record_name}.#{field.method}, #{attrs.inspect})\n"
    end

    def field_numeric_input(field, attrs={}, varc='varc')
      attrs[:size] ||= 16
      return "#{varc} << text_field(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end

    def field_password_input(field, attrs={}, varc='varc')
      attrs[:size] ||= 24
      return "#{varc} << password_field(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end

    def field_radio_input(field, attrs={}, varc='varc')
      return "#{varc} << radio(:#{field.record_name}, :#{field.method}, #{field.choices.inspect}, #{attrs.inspect})\n"
      # return "#{varc} << " << field.choices.collect{|x| "content_tag(:span, radio_button(:#{field.record_name}, :#{field.method}, #{x[1].inspect}) << ' ' << content_tag(:label, #{x[0].inspect}, :for=>'#{field.input_id}_#{x[1]}'), :class=>'rad')"}.join(" << ") << "\n"
    end

    def field_select_input(field, attrs={}, varc='varc')
      if (include_blank = field.options.delete(:include_blank)).is_a? String
        field.choices.insert(0, [include_blank, ''])
      end
      return "#{varc} << select(:#{field.record_name}, :#{field.method}), #{field.choices.inspect}, #{attrs.inspect})\n"
    end

    def field_mono_choice_input(field, attrs={}, varc='varc')
      count = "#{field.choices}_count"
      select_first_if_empty = "  #{record_name}.#{field.name} ||= #{field_datasource(field)}.first\n"
      code  = "#{count} = #{field_datasource(field)}.count\n"
      code << "if (#{count} == 0)\n"
      code << field_mono_select_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      code << "elsif (#{count} <= #{Formize.radio_count_max})\n"
      code << select_first_if_empty
      code << field_mono_radio_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      code << "elsif (#{count} <= #{Formize.select_count_max})\n"
      code << select_first_if_empty
      code << field_mono_select_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      code << "else\n"
      code << select_first_if_empty
      code << field_mono_unroll_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      code << "end\n"
      
      new_item_url = field.options.delete(:new)
      if new_item_url.is_a? Symbol
        new_item_url = {:controller=>new_item_url.to_s.pluralize.to_sym} 
      elsif new_item_url.is_a? TrueClass
        new_item_url = {}
      end

      if new_item_url.is_a?(Hash)
        for k, v in new_item_url
          new_item_url[k] = Code.new(v) if v.is_a?(String)
        end
        edit_item_url = {} unless edit_item_url.is_a? Hash
        if field.method.to_s.match(/_id$/) and refl = form.model.reflections[field.method.to_s[0..-4].to_sym]
          new_item_url[:controller] ||= refl.class_name.underscore.pluralize
          edit_item_url[:controller] ||= new_item_url[:controller]
        end
        new_item_url[:action] ||= :new
        edit_item_url[:action] ||= :edit
        data = field.options.delete(:update)||field.html_id
        html_options = {"data-add-item"=>data, :class=>"icon im-new"}
        code << "#{varc} << content_tag(:span, content_tag(:span, link_to(tg(:new), #{new_item_url.inspect}, #{html_options.inspect}).html_safe, :class=>:tool).html_safe, :class=>\"toolbar mini-toolbar\") if authorized?(#{new_item_url.inspect})\n"
      end
      return code
    end

    def field_mono_radio_input(field, attrs={}, varc='varc')
      return "#{varc} <<  radio(:#{field.record_name}, :#{field.method}, #{field_datasource(field)}.collect{|item| [item.#{field.item_label}, item.id]}, {}, #{attrs.inspect})"
    end

    def field_mono_select_input(field, attrs={}, varc='varc')
      return "#{varc} << select(:#{field.record_name}, :#{field.method}, #{field_datasource(field)}.collect{|item| [item.#{field.item_label}, item.id]}, {}, #{attrs.inspect})"
    end
    
    def field_mono_unroll_input(field, attrs={}, varc='varc')
      options = {}
      options[:label] ||= Code.new("Proc.new{|r| \"#{mono_choice_label(field, 'r')}\"}")
      return "#{varc} << unroll(:#{field.record_name}, :#{field.method}, url_for(:controller=>:#{controller.controller_name}, :action=>:#{form.action_name}, :unroll=>:#{field.html_id}), #{options.inspect}, #{attrs.inspect})"
    end

    def field_string_input(field, attrs={}, varc='varc')
      attrs[:size] ||= 24
      if field.column and !field.column.limit.nil?
        attrs[:size] = field.column.limit if field.column.limit<attrs[:size]
        attrs[:maxlength] = field.column.limit
      end
      return "#{varc} << text_field(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end

    def field_text_area_input(field, attrs={}, varc='varc')
      attrs[:cols] ||= 40
      attrs[:rows] ||= 3
      attrs[:class] = "#{attrs[:class]} #{attrs[:cols]==80 ? :code : nil}".strip
      return "#{varc} << text_area(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end






    protected

    def sanitize_conditions(value)
      if value.is_a? Array
        if value.size==1 and value[0].is_a? String
          value[0].to_s
        else
          value.inspect
        end
      elsif value.is_a? String
        '"'+value.gsub('"','\"')+'"'
      elsif [Date, DateTime].include? value.class
        '"'+value.to_formatted_s(:db)+'"'
      else
        value.to_s
      end
    end

    
    def mono_choice_label(choice, varr='record')
      return "\#\{#{varr}.#{choice.item_label}\}"
    end


    def mono_choice_search_code(choice)
      model = (options[:model]||name_db).to_s.singularize.camelize.constantize
      attributes = choice.search_attributes
      attributes = [attributes] unless attributes.is_a? Array
      attributes_hash = {}
      attributes.each_index do |i|
        attribute = attributes[i]
        attributes[i] = [
                         (attribute.to_s.match(/\./) ? attribute.to_s : model.table_name+'.'+attribute.to_s.split(/\:/)[0]),
                         (attribute.to_s.match(/\:/) ? attribute.to_s.split(/\:/)[1] : (options[:filter]||'%X%')),
                         '_a'+i.to_s]
        attributes_hash[attributes[i][2]] = attributes[i][0]
      end
      query = []
      parameters = ''
      if options[:conditions].is_a? Hash
        options[:conditions].each do |key, value| 
          query << (key.is_a?(Symbol) ? model.table_name+"."+key.to_s : key.to_s)+'=?'
          parameters += ', ' + sanitize_conditions(value)
        end
      elsif options[:conditions].is_a? Array
        conditions = options[:conditions]
        case conditions[0]
        when String  # SQL
          #               query << '["'+conditions[0].to_s+'"'
          query << conditions[0].to_s
          parameters += ', '+conditions[1..-1].collect{|p| sanitize_conditions(p)}.join(', ') if conditions.size>1
          #                query << ')'
        else
          raise Exception.new("First element of an Array can only be String or Symbol.")
        end
      end
      
      method_name = name_db.to_s+'_dyli'
      
      select = (model.table_name+".id AS id, "+attributes_hash.collect{|k,v| v+" AS "+k}.join(", ")).inspect
      joins = options[:joins] ? ", :joins=>"+options[:joins].inspect : ""
      
      code  = ""
      code += "conditions = [#{query.join(' AND ').inspect+parameters}]\n"
      code += "if params[:id]\n"
      code += "  conditions[0] += '#{' AND ' if query.size>0}#{model.table_name}.id=?'\n"
      code += "  conditions << params[:id]\n"
      code += "  record = "+model.name.to_s+".find(:first, :select=>#{select}, :conditions=>conditions#{joins})\n"
      code += "  if record\n"
      code += "    render :json=>{:tf_value=>"+attributes.collect{|key| "record.#{key[2]}.to_s"}.join('+", "+')+", :hf_value=>record.id}\n"
      code += "  else\n"
      code += "    render :text=>''\n"
      code += "  end\n"
      code += "else\n"
      code += "  search = params[:#{name_db}][:search]||\"\"\n"
      code += "  words = search.lower.split(/[\\s\\,]+/)\n"
      code += "  if words.size>0\n"
      code += "    conditions[0] += '#{' AND ' if query.size>0}('\n"
      code += "    words.each_index do |index|\n"
      code += "      word = words[index]\n"
      code += "      conditions[0] += ') AND (' if index>0\n"

      if ActiveRecord::Base.connection.adapter_name == "MySQL"
        code += "      conditions[0] += "+attributes.collect{|key| "LOWER(CAST(#{key[0]} AS CHAR)) LIKE ?"}.join(' OR ').inspect+"\n"
      else
        code += "      conditions[0] += "+attributes.collect{|key| "LOWER(CAST(#{key[0]} AS VARCHAR)) LIKE ?"}.join(' OR ').inspect+"\n"
      end

      # code += "      conditions[0] += "+attributes.collect{|key| "LOWER(#{key[0]}) LIKE ?"}.join(' OR ').inspect+"\n"
      code += "      conditions += ["+attributes.collect{|key| key[1].inspect.gsub('X', '"+words[index].to_s+"').gsub(/(^\"\"\+|\+\"\"\+|\+\"\")/, '')}.join(", ")+"]\n"
      code += "    end\n"
      code += "    conditions[0] += ')'\n"
      code += "  end\n"
      order = ", :order=>"+attributes.collect{|key| "#{key[0]} ASC"}.join(', ').inspect
      limit = ", :limit=>"+(options[:limit]||12).to_s
      partial = options[:partial]
      code += "  list = ''\n"
      code += "  for record in "+model.name.to_s+".find(:all, :select=>#{select}, :conditions=>conditions"+joins+order+limit+")\n"
      code += "    content = "+attributes.collect{|key| "record.#{key[2]}.to_s"}.join('+", "+')+"\n"
      display = (partial ? "render(:partial=>"+partial.inspect+", :locals =>{:record=>record, :content=>content, :search=>search})" : 'highlight(#{content.inspect}, #{search.inspect})')
      code += "    list += \"<li id=\\\"#{name_db}_\#\{record.id\}\\\"><%=#{display}%><input type=\\\"hidden\\\" value=\#\{content.inspect\} id=\\\"record_\#\{record.id\}\\\"/></li>\"\n"
      code += "  end\n"
      code += "  render :inline=>'<ul>'+list+'</ul>'\n"
      code += "else\n"
      code += "  render :text=>'', :layout=>true\n"
      code += "end #123\n"

      # File.open("/tmp/test.rb", "wb") {|f| f.write(code)}
      # list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}
      return code
    end


    
  end
  
end
