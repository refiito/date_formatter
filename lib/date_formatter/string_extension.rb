module DateFormatter
  module StringExtension
    
    def parse_with_fallback_format
      DateTime.strptime( self, "%d/%m/%Y")
    end

    def to_date_with_custom_format
      if self =~ DateFormatter.date_format_regexp
        Date.strptime self, DateFormatter.date_format
      else
        begin
          parse_with_fallback_format.to_date
        rescue
          to_date_without_custom_format
        end
      end
    end

    def to_time_with_custom_format
      out = if self =~ DateFormatter.datetime_format_regexp
        DateTime.strptime( self, DateFormatter.datetime_format ).to_time
      elsif self =~ DateFormatter.date_format_regexp
        DateTime.strptime( self, DateFormatter.date_format ).to_time
      else
        begin
          parse_with_fallback_format.to_time
        rescue
          to_time_without_custom_format
        end
      end

      if out.respond_to?( :in_time_zone ) && !Time.zone.blank?
        out = out.in_time_zone
        out - out.utc_offset
      else
        out
      end
    end

    def self.included( base )
      base.instance_eval do
        alias_method_chain :to_date, :custom_format
        alias_method_chain :to_time, :custom_format
      end
    end

  end
end
