module DateFormatter
  module ActionViewExtension

    # Exports the date format to Javascript in a snippet
    def javascript_date_format
      <<-JS
      window.date_format=#{DateFormatter.date_format.to_json};
      window.timeofday_format=#{DateFormatter.timeofday_format.to_json};
      window.datetime_format=#{DateFormatter.datetime_format.to_json};
      window.jquery_date_format = #{DateFormatter.jquery_date_format.to_json};
      window.jquery_datepicker_format = #{DateFormatter.jquery_datepicker_format.to_json};
      window.jquery_timeofday_format = #{DateFormatter.jquery_timeofday_format.to_json};
      window.jquery_datetime_format=#{DateFormatter.jquery_datetime_format.to_json};
      JS
    end

    # Exports the date format to Javascript in a Javascript tag
    def javascript_date_format_tag
      javascript_tag javascript_date_format
    end
  end
end
