module DateFormatter
  module ActiveRecordExtension
    module ClassMethods
     
=begin    
      def validates_date_formats( configuration = {} )
        configuration = { 
          :message => _("%{fn} must be formatted as %{df}"),
          :on => :save 
        }.merge( configuration )

        # Validate date formats
        column_names =  self.columns.select{ |c| :date == c.type }.collect{ |c| c.name }

        validates_each column_names, configuration do |record, attr_name, value| 
          value = record.send( :get_raw_date_value, attr_name )
          record.errors.add(attr_name, configuration[:message] % { :df => DateFormatter.human_date_format} ) unless value.to_s =~ DateFormatter.date_format_regexp unless value.nil?
        end
          
        # Valitime datetime formats
        column_names =  self.columns.select{ |c| :datetime == c.type }.collect{ |c| c.name }
          
        validates_each column_names, configuration do |record, attr_name, value| 
          value = record.send( :get_raw_datetime_value, attr_name )
          record.errors.add(attr_name, configuration[:message] % { :df => DateFormatter.human_datetime_format} ) unless value.to_s =~ DateFormatter.datetime_format_regexp unless value.nil?
        end
        
        # Valitime time formats
        column_names =  self.columns.select{ |c| :time == c.type }.collect{ |c| c.name }
          
        validates_each column_names, configuration do |record, attr_name, value| 
          value = record.send( :get_raw_time_value, attr_name )
          record.errors.add(attr_name, configuration[:message] % { :df => DateFormatter.human_timeofday_format} ) unless value.to_s =~ DateFormatter.timeofday_format_regexp unless value.nil?
        end
          
          
      end
=end

    end

    private
    
    def set_raw_date_value( attr_name, value )
      instance_variable_set("@date_formatter_#{attr_name}", value )
    end

    def get_raw_date_value( attr_name )
      value = instance_variable_get("@date_formatter_#{attr_name}")
      value
    end

    alias_method :set_raw_datetime_value, :set_raw_date_value
    alias_method :get_raw_datetime_value, :get_raw_date_value
    alias_method :set_raw_time_value, :set_raw_date_value
    alias_method :get_raw_time_value, :get_raw_date_value

    def try_to_write_value( attr_name, value )
      set_raw_date_value( attr_name, nil )
      write_attribute_without_date_formatter( attr_name, value )
    end

    public

    def read_attribute_before_type_cast_with_date_formatter( attr_name )
      column = column_for_attribute( attr_name )
      return ( read_attribute( attr_name ) and read_attribute( attr_name ).strftime( DateFormatter.date_format ) ) if (:date == column.type)
      return ( read_attribute( attr_name ) and read_attribute( attr_name ).strftime( DateFormatter.datetime_format ) ) if (:datetime == column.type)
      return ( read_attribute( attr_name ) and read_attribute( attr_name ).strftime( DateFormatter.datetime_format ) ) if (:time == column.type)
      return read_attribute_before_type_cast_without_date_formatter( attr_name )
    end

    def write_attribute_with_date_formatter( attr_name, value )
      column = column_for_attribute( attr_name )

      if value.is_a?String and value.empty? 
        value = nil
      end

      if !column.nil? and value.is_a?String and (:date == column.type)
        value = Date.strptime( value, DateFormatter.date_format ) 
        try_to_write_value attr_name, value 
      elsif !column.nil? and value.is_a?String and (:datetime == column.type)
        # A hack. Some machines demand that DateTime always have Y, M and D.
        value = DateTime.strptime( '2000 01 01 ' + value.to_s, "%Y %m %d " + DateFormatter.datetime_format.to_s ).to_time
        try_to_write_value attr_name, value 
      elsif !column.nil? and value.is_a?String and (:time == column.type)
        # A hack. Some machines demand that DateTime always have Y, M and D.
        value = DateTime.strptime( '2000 01 01 ' + value.to_s, "%Y %m %d " + DateFormatter.datetime_format.to_s ).to_time
        try_to_write_value attr_name, value 
      else
        write_attribute_without_date_formatter( attr_name, value )
      end

    rescue ArgumentError
      set_raw_date_value( attr_name, value )
      write_attribute_without_date_formatter( attr_name, nil )
    end

    def clone_with_date_formatter
      self.class.new do |record|
        self.attributes.each do |key, value|
          record.write_attribute( key, value ) unless self.class.primary_key == key
        end
      end
    end
    
    def self.included( base )
      base.class_eval do
        alias_method_chain :write_attribute, :date_formatter
        alias_method_chain :read_attribute_before_type_cast, :date_formatter
        alias_method_chain :clone, :date_formatter
      end

      base.extend( ClassMethods )
    end

  end
end
