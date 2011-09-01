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

          for depended in mono_choice.dependeds
            df = form.fields[depended[:name]]
            event << "  #{df.name} = " << (df.reflection.nil? ? "params[:#{df.input_id}]" : "#{df.reflection.class_name}.find_by_id(params[:#{df.input_id}])") << "\n"
            # locals[df.name.to_sym] = Code.new(df.name)
          end

          event << mono_choice_search_code(mono_choice).strip.gsub(/^/, '  ') << "\n"
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
            event << "  #{record_name}.#{df.name} = " << (df.reflection.nil? ? "params[:#{df.input_id}]" : "#{df.reflection.class_name}.find_by_id(params[:#{df.input_id}])") << "\n"
            # locals[df.name.to_sym] = Code.new(df.name)
          end
          if dependent.is_a?(Formize::Field) and dependent.reflection
            event << "  #{record_name}.#{dependent.reflection.primary_key_name} = params[:selected].to_i if params[:selected]\n"
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
      code << "  with_custom_field_error_proc do\n"
      for element in form.elements
        code << view_method_call(element, varh).strip.gsub(/^/, '    ') << "\n"
      end
      code << "  end\n"
      code << "  return #{varh}.html_safe\n"
      code << "end\n"

      code << "\n"
      code << "def #{form.options[:view_form_method_name]}(#{form.record_name}=nil)\n"
      code << "  #{form.record_name} = @#{form.record_name} unless #{form.record_name}.is_a?(#{form.model.name})\n"
      code << "  #{varh} = ''\n"
      code << "  if #{form.record_name}.errors.any?\n"
      code << "    #{varh} << hard_content_tag(:div, :class=>'errors') do |fe|\n"
      code << "      fe << content_tag(:h2, ::I18n.translate('activerecord.errors.template.body', :count=>#{form.record_name}.errors.size))\n"
      code << "      if #{form.record_name}.errors[:base].any?\n"
      code << "        fe << '<ul>'\n"
      code << "        for error in #{form.record_name}.errors[:base]\n"
      code << "          fe << content_tag(:li, error)\n"
      code << "        end\n"
      code << "        fe << '</ul>'\n"
      code << "      end\n"
      code << "    end\n"
      code << "  end\n"
      code << "  #{varh} << form_for(#{form.record_name}, :html=>(params[:dialog] ? {'data-dialog'=>params[:dialog]} : {})) do\n"
      code << "    concat(#{form.options[:view_fields_method_name]}(#{form.record_name}))\n"
      code << "    concat(submit_for(#{form.record_name}))\n"
      code << "  end\n"
      code << "  return #{varh}.html_safe\n"
      code << "end\n"

      # raise code
      list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}
      return code
    end
    



    
    def view_partial_code(element, varh='varh')
      # send("#{element.class.name.split('::')[-1].underscore}_#{__method__}", element, varh)
      special_method = "#{element.class.name.split('::')[-1].underscore}_#{__method__}".to_sym
      code = ""
      partial_code = send(special_method, element, varh)
      dependeds = element.dependeds.collect{|d| d[:name]}
      if dependeds.size > 0
        for depended in dependeds
          depended_field = form.fields[depended]
          code << "#{depended_field.name} = #{form.record_name}.#{depended_field.name}\n"
          if depended_field.reflection
            code << "#{depended_field.name} ||= #{field_datasource(depended_field)}.first\n"
          end
        end

        code << "if #{dependeds.join(' and ')}\n"

        code << partial_code.strip.gsub(/^/, '  ') << "\n"

        code << "else\n"
        code << "  #{varh} << content_tag(:div, '', #{wrapper_attrs(element).inspect})\n"
        code << "end\n"
      else
        code = partial_code
      end
      return code
    end

    def view_method_code(element, varh='varh')
      # send("#{element.class.name.split('::')[-1].underscore}_#{__method__}", element, varh)
      special_method = "#{element.class.name.split('::')[-1].underscore}_#{__method__}".to_sym
      return send(special_method, element, varh) if self.respond_to?(special_method)
      code  = "def #{element.prototype}\n"
      code << "  #{varh} = ''\n"
      code << view_partial_code(element, varh).strip.gsub(/^/, '  ') << "\n"
      code << "  return #{varh}.html_safe\n"
      code << "end\n"
      return code
    end

    def view_method_call(element, varh='varh')
      special_method = "#{element.class.name.split('::')[-1].underscore}_#{__method__}".to_sym
      return send(special_method, element, varh) if self.respond_to?(special_method)
      if @partials.include?(element)
        return "#{varh} << #{element.prototype}\n"
      else
        return view_partial_code(element, varh).strip << "\n"
      end
    end

    def wrapper_attrs(element)
      html_options = (element.respond_to?(:html_options) ? element.html_options : {})
      html_options[:id] = element.html_id
      if @partials.include?(element)
        url = {:controller => controller.controller_name.to_sym, :action=>form.action_name.to_sym, :refresh=>element.html_id}
        for depended in element.dependeds
          df = form.fields[depended[:name]]
          url[df.input_id.to_sym] = Code.new(df.reflection.nil? ? df.name : "#{df.name}.id")
        end
        html_options["data-refresh"] = Code.new("url_for(#{url.inspect})")
      end
      special_method = "#{element.class.name.split('::')[-1].underscore}_#{__method__}".to_sym
      return send(special_method, element, html_options) if self.respond_to?(special_method)      
      return html_options
    end

    #####################################################################################
    #                         F I E L D _ S E T     M E T H O D S                       #
    #####################################################################################
    
    def field_set_view_partial_code(field_set, varh='varh')
      # Initialize html attributes
      html_options = wrapper_attrs(field_set)

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

    #####################################################################################
    #                             F I E L D     M E T H O D S                           #
    #####################################################################################
      
    def field_view_partial_code(field, varh='varh')
      input_attrs = (field.options[:input_options].is_a?(Hash) ? field.options[:input_options] : {})
      deps = form.dependents_on(field)
      if deps.size > 0
        input_attrs["data-dependents"] = deps.collect{|d| d.html_id}.join(',') 
      end

      # Initialize html attributes
      html_options = wrapper_attrs(field)

      varc = field.html_id
      code  = "#{varh} << hard_content_tag(:table, #{html_options.inspect}) do |#{varc}|\n"
      code << "  #{varc} << '<tr><td class=\"label\">'\n"
      code << "  #{varc} << label(:#{form.record_name}, :#{field.name}, nil, :class=>'attr')\n"
      code << "  #{varc} << '</td><td class=\"input\">'\n"
      code << "  #{form.record_name}.#{field.name} ||= #{field.default.inspect}\n" if field.default
      code << self.send("field_#{field.type}_input", field, input_attrs, varc).strip.gsub(/^/, '  ') << "\n"
      code << "  if @#{form.record_name}.errors['#{field.name}'].any?\n"
      code << "    #{varc} << '<ul class=\"inline-errors\">'\n"
      code << "    for error in @#{form.record_name}.errors['#{field.name}']\n"
      code << "      #{varc} << content_tag(:li, error)\n"
      code << "    end\n"
      code << "    #{varc} << '</ul>'\n"
      code << "  end\n"
      code << "  #{varc} << '</td></tr>'\n"
      code << "end\n"
      return code
    end

    def field_datasource(field)
      source = field.source
      source = Formize.default_source unless [Array, String, Symbol].include?(source.class)
      if source.is_a?(Array)
        return "#{source[0]}.#{field.choices}"
      elsif source == :foreign_class
        # return field.reflection.class_name if field.choices.to_s == "all"
        return "#{field.reflection.class_name}.#{field.choices}"
      elsif source == :class
        # return form.model.name if field.choices.to_s == "all"
        return "#{form.model.name}.#{field.choices}"
      else
        return "#{source}.#{field.choices}"
      end
    end
    
    # Returns the name of the class of the source
    # 
    def field_datasource_class_name(field)
      source = field.source
      source = Formize.default_source unless [Array, String, Symbol].include?(source.class)
      if source.is_a?(Array)
        return source[1]
      elsif source == :foreign_class
        return field.reflection.class_name
      elsif source == :class
        return form.model.name
      else
        return source.to_s.classify
      end
    end
    
    def field_input_options(field)
    end

    def field_wrapper_attrs(field, html_options={})
      html_options[:class] = "fz field #{html_options[:class]}".strip
      html_options[:class] = "#{html_options[:class]} #{field.type.to_s.gsub('_', '-')}".strip
      html_options[:class] = "#{html_options[:class]} required".strip if field.required
      html_options[:class] = Code.new("\"#{html_options[:class]}\#{' invalid' if @#{field.form.record_name}.errors['#{field.name}'].any?}\"")
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
      attrs[:size] ||= 10
      return "#{varc} << date_field(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
    end

    def field_datetime_input(field, attrs={}, varc='varc')
      attrs[:size] ||= 16
      # TODO define Date format
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
      if (include_blank = attrs.delete(:include_blank)).is_a? String
        field.choices.insert(0, [include_blank, ''])
      end
      return "#{varc} << select(:#{field.record_name}, :#{field.method}), #{field.choices.inspect}, #{attrs.inspect})\n"
    end

    def field_mono_choice_input(field, attrs={}, varc='varc')
      source_model = field_datasource_class_name(field).constantize
      reflection = source_model.reflections[field.choices]
      # if reflection.nil?
      #   raise Exception.new("#{source_model.name} must have a reflection :#{field.choices}.")
      # end
      count = "#{field.choices}_count"
      select_first_if_empty = "  #{record_name}.#{field.name} ||= #{field_datasource(field)}.first\n"
      code  = "#{count} = #{field_datasource(field)}.count\n"
      code << "if (#{count} == 0)\n"
      code << field_mono_select_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      code << "elsif (#{count} <= #{Formize.radio_count_max})\n"
      code << select_first_if_empty
      code << field_mono_radio_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      if !reflection or (reflection and reflection.options[:finder_sql].nil?)
        code << "elsif (#{count} <= #{Formize.select_count_max})\n"
        code << select_first_if_empty
        code << field_mono_select_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
        code << "else\n"
        code << select_first_if_empty
        code << field_mono_unroll_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      else
        code << "else\n"
        code << select_first_if_empty
        code << field_mono_select_input(field, attrs, varc).strip.gsub(/^/, '  ') << "\n"
      end
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
        if field.method.to_s.match(/_id$/) and refl = field.reflection # form.model.reflections[field.method.to_s[0..-4].to_sym]
          new_item_url[:controller] ||= refl.class_name.underscore.pluralize
          edit_item_url[:controller] ||= new_item_url[:controller]
        end
        new_item_url[:action] ||= :new
        edit_item_url[:action] ||= :edit
        data = field.options.delete(:update)||field.html_id
        html_options = {"data-add-item"=>data, :class=>"icon im-new"}
        code << "#{varc} << content_tag(:span, content_tag(:span, link_to(::I18n.translate('form.new'), #{new_item_url.inspect}, #{html_options.inspect}).html_safe, :class=>:tool).html_safe, :class=>\"toolbar mini-toolbar\")\n" #  if authorized?(#{new_item_url.inspect})
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
      url = {:controller=>controller.controller_name, :action=>form.action_name, :unroll=>field.html_id}
      for depended in field.dependeds
        df = form.fields[depended[:name]]
        url[df.input_id.to_sym] = Code.new(df.reflection.nil? ? df.name : "#{df.name}.id")
      end
      return "#{varc} << unroll(:#{field.record_name}, :#{field.method}, #{url.inspect}, #{options.inspect}, #{attrs.inspect})"
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
      return "#{varc} << resizable_text_area(:#{field.record_name}, :#{field.method}, #{attrs.inspect})\n"
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

    def mono_choice_search_code(field)
      source_model = field_datasource_class_name(field).constantize
      # reflection = source_model.reflections[field.choices]
      # if reflection.nil?
      #   raise Exception.new("#{source_model.name} must have a reflection :#{field.choices}.")
      # end
      model = field.reflection.class_name.constantize #reflection.class_name.constantize
      foreign_record  = model.name.underscore
      foreign_records = "#{source_model.name.underscore}_#{field.choices}"
      options = field.options
      attributes = field.search_attributes
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
      
      select = (model.table_name+".id AS id, "+attributes_hash.collect{|k,v| v+" AS "+k}.join(", ")).inspect
      
      code  = ""
      code << "conditions = [#{query.join(' AND ').inspect+parameters}]\n"
      code << "search = params[:term]\n"
      code << "words = search.to_s.mb_chars.downcase.strip.normalize.split(/[\\s\\,]+/)\n"
      code << "if words.size > 0\n"
      code << "  conditions[0] << '#{' AND ' if query.size>0}('\n"
      code << "  words.each_index do |index|\n"
      code << "    word = words[index].to_s\n"
      code << "    conditions[0] << ') AND (' if index > 0\n"

      if ActiveRecord::Base.connection.adapter_name == "MySQL"
        code << "    conditions[0] << "+attributes.collect{|key| "LOWER(CAST(#{key[0]} AS CHAR)) LIKE ?"}.join(' OR ').inspect+"\n"
      else
        code << "    conditions[0] << "+attributes.collect{|key| "LOWER(CAST(#{key[0]} AS VARCHAR)) LIKE ?"}.join(' OR ').inspect+"\n"
      end

      code << "    conditions += ["+attributes.collect{|key| key[1].inspect.gsub('X', '"+word+"').gsub(/(^\"\"\+|\+\"\"\+|\+\"\")/, '')}.join(", ")+"]\n"
      code << "  end\n"
      code << "  conditions[0] << ')'\n"
      code << "end\n"

      # joins = options[:joins] ? ", :joins=>"+options[:joins].inspect : ""
      # order = ", :order=>"+attributes.collect{|key| "#{key[0]} ASC"}.join(', ').inspect
      # limit = ", :limit=>"+(options[:limit]||80).to_s
      joins = options[:joins] ? ".joins(#{options[:joins].inspect})" : ""
      order = ".order("+attributes.collect{|key| "#{key[0]} ASC"}.join(', ').inspect+")"
      limit = ".limit(#{options[:limit]||80})"

      partial = options[:partial]

      html  = "<ul><%for #{foreign_record} in #{foreign_records}-%><li id='<%=#{foreign_record}.id-%>'>" 
      html << "<%content=#{foreign_record}.#{field.item_label}-%>"
      # html << "<%content="+attributes.collect{|key| "#{foreign_record}['#{key[2]}'].to_s"}.join('+", "+')+" -%>"
      if partial
        html << "<%=render(:partial=>#{partial.inspect}, :locals =>{:#{foreign_record}=>#{foreign_record}, :content=>content, :search=>search})-%>"
      else
        html << "<%=highlight(content, search)-%>"
      end
      html << '</li><%end-%></ul>'

      # code << "#{foreign_records} = #{field_datasource(field)}.find(:all, :conditions=>conditions"+joins+order+limit+")\n"
      code << "#{foreign_records} = #{field_datasource(field).gsub(/\.all$/, '')}.where(conditions)"+joins+order+limit+"\n"
      # Render HTML is old Style
      code << "respond_to do |format|\n"
      code << "  format.html { render :inline=>#{html.inspect}, :locals=>{:#{foreign_records}=>#{foreign_records}, :search=>search} }\n"
      code << "  format.json { render :json=>#{foreign_records}.collect{|#{foreign_record}| {:label=>#{foreign_record}.#{field.item_label}, :id=>#{foreign_record}.id}}.to_json }\n"
      code << "  format.xml { render :xml=>#{foreign_records}.collect{|#{foreign_record}| {:label=>#{foreign_record}.#{field.item_label}, :id=>#{foreign_record}.id}}.to_xml }\n"
      code << "end\n"      
      return code
    end


    
  end
  
end
