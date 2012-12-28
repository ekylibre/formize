module Formize
  module Generator

    class Column
      attr_reader :name, :filter, :interpolation_key, :column

      # @@count = 0

      def initialize(model, name, options={})
        @model = model
        @name = name.to_s
        @filter = options.delete(:filter) || "%X%"
        @code = options.delete(:code)
        @interpolation_key = options.delete(:interpolation_key) || @name.gsub(/\W/, '_')
        klass = @model
        @through = (options.delete(:through) || []).collect do |reflection|
          unless klass.reflections[reflection.to_sym]
            raise Exception.new("Model #{klass.name} has no reflections #{reflection.inspect}")
          end
          klass = klass.reflections[reflection.to_sym].class_name.constantize
          reflection.to_sym
        end || []
        @column = foreign_model.columns_hash[@name]
      end

      def sql_name
        return "#{foreign_model.table_name}.#{@name}"
      end

      def value_code(record='record')
        code  = "("
        value = "(#{record}#{'.'+@through.join('.') unless @through.empty?}.#{name})"
        @through.each_index do |i|
          code << "#{record}.#{@through[0..i].join('.')}.nil? ? '' : "
        end
        code << if @code
                  @code.gsub(/RECORD/, record).gsub(/DATUM/, value)
                elsif[:date, :datetime, :timestamp].include? self.type
                  "(#{value}.nil? ? '' : ::I18n.localize(#{value}))"
                else
                  value
                end
        code << ")"
        code << ".to_s" unless name.to_s == "count"
        return code
      end

      def type
        @column.type
      end

      def foreign_model
        model = @model
        for reflection in @through
          model = model.reflections[reflection].class_name.constantize
        end
        return model
      end

    end


    class Base

      attr_accessor :action_name, :controller, :options

      def initialize(controller, action_name, model, options={})
        @controller = controller
        @action_name = action_name.to_sym
        @options = (options.is_a?(Hash) ? options : {})
        @model = model
        columns = @options.delete(:columns)
        columns ||= @model.content_columns.collect{|x| x.name.to_sym}.delete_if{|c| [:lock_version, :created_at, :updated_at].include?(c)}
        columns = [columns] unless columns.is_a? Array
        # Normalize columns
        @columns = columns.collect do |c| 
          c = c.to_s.split(/\:/) if [String, Symbol].include? c.class
          c = if c.is_a? Hash
                Column.new(@model, c.delete(:name), c)
              elsif c.is_a? Array
                sliced = c[0].split('.')
                Column.new(@model, sliced[-1], :filter=>c[1], :interpolation_key=>c[2], :through=>sliced[0..-2])
              else
                raise Exception.new("Bad column: #{c.inspect}")
              end
          c
        end
      end



      def controller_code()
        foreign_record  = @model.name.underscore
        foreign_records = foreign_record.pluralize
        foreign_records = "many_#{foreign_records}" if foreign_record == foreign_records

        query = []
        parameters = ''
        initial_conditions = ""
        if @options[:conditions].is_a? Hash
          @options[:conditions].each do |key, value| 
            query << (key.is_a?(Symbol) ? @model.table_name+"."+key.to_s : key.to_s)+'=?'
            parameters += ', ' + sanitize_conditions(value)
          end
          initial_conditions = query.join(' AND ').inspect+parameters
        elsif @options[:conditions].is_a? Array
          conditions = @options[:conditions]
          if conditions[0].is_a?(String)  # SQL
            query << conditions[0].to_s
            parameters += ', '+conditions[1..-1].collect{|p| sanitize_conditions(p)}.join(', ') if conditions.size>1
          else
            raise Exception.new("First element of an Array can only be String or Symbol.")
          end
          initial_conditions = query.join(' AND ').inspect+parameters
        elsif @options[:conditions].is_a? String
          initial_conditions = "("+@options[:conditions].gsub(/\s*\n\s*/, ';')+")"
        elsif !@options[:conditions].blank?
          raise ArgumentError.new("Option :conditions can be a Hash, an Array or String (not #{@options[:conditions].class}:#{@options[:conditions].inspect})")
        end
        
        code  = ""
        code << "search, conditions = params[:term], []\n"
        code << "if params[:id].to_i > 0\n"
        code << "  conditions[0] = '#{@model.table_name}.id = ?'\n"
        code << "  conditions << params[:id].to_i\n"
        code << "else\n"
        code << "  words = search.to_s.mb_chars.downcase.strip.normalize.split(/[\\s\\,]+/)\n"
        code << "  if words.size > 0\n"
        code << "    conditions[0] = '('\n"
        code << "    words.each_index do |index|\n"
        code << "      word = words[index].to_s\n"
        code << "      conditions[0] << ') AND (' if index > 0\n"
        if ActiveRecord::Base.connection.adapter_name == "MySQL"
          code << "      conditions[0] << "+@columns.collect{|column| "LOWER(CAST(#{column.sql_name} AS CHAR)) LIKE ?"}.join(' OR ').inspect+"\n"
        else
          code << "      conditions[0] << "+@columns.collect{|column| "LOWER(CAST(#{column.sql_name} AS VARCHAR)) LIKE ?"}.join(' OR ').inspect+"\n"
        end
        code << "      conditions += ["+@columns.collect{|column| column.filter.inspect.gsub('X', '"+word+"').gsub(/(^\"\"\+|\+\"\"\+|\+\"\")/, '')}.join(", ")+"]\n"
        code << "    end\n"
        code << "    conditions[0] << ')'\n"
        code << "  end\n"
        code << "end\n"

        joins = (@options[:joins] ? ".joins(#{@options[:joins].inspect}).includes(#{@options[:joins].inspect})" : "")
        order = (@options[:order] ? ".order(#{@options[:order].inspect})" : ".order("+@columns.collect{|c| "#{c.sql_name} ASC"}.join(', ').inspect+")")
        limit = ".limit(#{@options[:limit]||80})"

        partial = @options[:partial]

        html  = "<ul><% for #{foreign_record} in #{foreign_records} -%><li id='<%=#{foreign_record}.id-%>'>" 
        html << "<% content = item_label_for_#{@action_name}_in_#{@controller.controller_name}(#{foreign_record})-%>"
        if partial
          html << "<%=render(:partial=>#{partial.inspect}, :locals =>{:#{foreign_record}=>#{foreign_record}, :content=>content, :search=>search})-%>"
        else
          html << "<%=highlight(content, search)-%>"
        end
        html << '</li><%end-%></ul>'

        code << "#{foreign_records} = #{@model.name}"
        code << ".where(#{initial_conditions})" unless initial_conditions.blank?
        code << ".where(conditions)"+joins+order+limit+"\n"
        # Render HTML is old Style
        code << "respond_to do |format|\n"
        code << "  format.html { render :inline=>#{html.inspect}, :locals=>{:#{foreign_records}=>#{foreign_records}, :search=>search} }\n"
        code << "  format.json { render :json=>#{foreign_records}.collect{|#{foreign_record}| {:label=>#{item_label(foreign_record)}, :id=>#{foreign_record}.id}}.to_json }\n"
        code << "  format.yaml { render :yaml=>#{foreign_records}.collect{|#{foreign_record}| {'label'=>#{item_label(foreign_record)}, 'id'=>#{foreign_record}.id}}.to_yaml }\n"
        code << "  format.xml  { render :xml=>#{foreign_records}.collect{|#{foreign_record}| {:label=>#{item_label(foreign_record)}, :id=>#{foreign_record}.id}}.to_xml }\n"
        code << "end\n"
        return code
      end


      def controller_action()
        code  = "def #{@action_name}\n"
        code << self.controller_code.strip.gsub(/^/, '  ')+"\n"
        code << "end\n"
        # list = code.split("\n"); list.each_index{|x| puts((x+1).to_s.rjust(4)+": "+list[x])}
        return code
      end


      def item_label_code()
        record = 'record'
        code  = "def self.item_label_for_#{@action_name}_in_#{@controller.controller_name}(#{record})\n"
        code << "  if #{record}.is_a? #{@model.name}\n"
        code << "    return #{item_label(record)}\n"
        code << "  else\n"
        code << "    return ''\n"
        code << "  end\n"
        code << "end\n"
        # puts code
        return code
      end

      private

      def item_label(record, options={})
        return "::I18n.translate('views.unroll.#{@controller.controller_name}.#{@action_name}', "+@columns.collect{|c| ":#{c.interpolation_key}=>#{c.value_code(record)}"}.join(', ')+", :default=>[:'labels.#{@action_name}', '"+@columns.collect{|c| "%{#{c.interpolation_key}}"}.join(', ')+"']).gsub(/%s/, \"\\u{00A0}\")"
      end

      def sanitize_conditions(value)
        if value.is_a? Array
          if value.size == 1 and value[0].is_a? String
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

    end

  end

end
