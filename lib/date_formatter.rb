#require 'gettext/rails' rescue nil
module DateFormatter

  def self._(*argv)
    ActionController::Base.send :_, *argv
  rescue NoMethodError
    argv.first
  end

  private

  mattr_accessor :df
  mattr_accessor :dtf
  mattr_accessor :tf

  public

  def self.date_format_to_human_string_with_literal_percentages( df )
    df.split( '%%' ).collect{ |x| date_format_to_human_string( x ) }.join( '%' )
  end

  def self.date_format_to_regexp_string_with_literal_percentages( df )
    "^%s$" % df.split( '%%' ).collect{ |x| date_format_to_regexp_string( x ) }.join( '%' )
  end

  def self.date_format_to_regexp_string( df )
    Regexp.escape( df ).
      gsub( "%a", "(Sun|Mon|Tue|Wed|Thu|Fri|Sat)" ).
      gsub( "%A", "(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)" ).
      gsub( "%b", "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)" ).
      gsub( "%B", "(January|February|March|April|May|June|July|August|September|October|November|December)" ).
      gsub( "%c", ".*" ). # TODO: %c - The preferred local date and time representation - wtf?
      gsub( "%d", "(%s)" % (1..31) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%H", "(%s)" % (0..23) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%I", "(%s)" % (1..12) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%j", "(%s)" % (1..366).collect{ |x| "%03d" % x }.join("|") ).
      gsub( "%m", "(%s)" % (1..12) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%M", "(%s)" % (0..59) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%p", "(AM|PM)" ).
      gsub( "%S", "(%s)" % (0..60) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%U", "(%s)" % (0..53) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%W", "(%s)" % (0..53) .collect{ |x| "%02d" % x }.join("|") ).
      gsub( "%w", "(%s)" % (0..6)  .collect{ |x| "%01d" % x }.join("|") ).
      gsub( "%x", ".*" ). # TODO: %x - Preferred representation for the date alone, no time - wtf?
      gsub( "%X", ".*" ). # TODO: %X - Preferred representation for the time alone, no date - wtf?
      gsub( "%y", "\\d\\d" ).
      gsub( "%Y", "\\d+" ).
      gsub( "%Z", ".*" )  # TODO: %Z - Time zone name
  end

  def self.date_format_to_human_string( df )
    df.
      gsub( "%a", "Ddd" ).
      gsub( "%A", _("Weekday") ).
      gsub( "%b", "Mmm" ).
      gsub( "%B", _("Month") ).
      gsub( "%c", "???" ). # TODO: %c - The preferred local date and time representation - wtf?
      gsub( "%d", "DD" ).
      gsub( "%H", "hh" ).
      gsub( "%I", "hh" ).
      gsub( "%j", "DDD" ).
      gsub( "%m", "MM" ).
      gsub( "%M", "mm" ).
      gsub( "%p", "AM/PM" ).
      gsub( "%S", "ss" ).
      gsub( "%U", "ww" ).
      gsub( "%W", "ww" ).
      gsub( "%w", "D" ).
      gsub( "%x", "???" ). # TODO: %x - Preferred representation for the date alone, no time - wtf?
      gsub( "%X", "???" ). # TODO: %X - Preferred representation for the time alone, no date - wtf?
      gsub( "%y", "YY" ).
      gsub( "%Y", "YYYY" ).
      gsub( "%Z", "TZ" )  # TODO: %Z - Time zone name
  end

  def self.date_format_to_jquery_format( df, use_two_digit_months_and_days=false )
    day_format = use_two_digit_months_and_days ? "dd" : "d"
    month_format = use_two_digit_months_and_days ? "mm" : "m"
    year_format = use_two_digit_months_and_days ? "yy": "Y"
    df.
      gsub( "%a", "D" ).
      gsub( "%A", "I" ).
      gsub( "%b", "M" ).
      gsub( "%B", "F" ).
      gsub( "%d", day_format ).
      gsub( "%H", "H" ).
      gsub( "%I", "h" ).
      gsub( "%m", month_format ).
      gsub( "%M", "i" ).
      gsub( "%p", "A" ).
      gsub( "%S", "s" ).
      gsub( "%y", "y" ).
      gsub( "%Y", year_format )
  end

  def self.humanize_date_format( df )
    date_format_to_human_string_with_literal_percentages( df )
  end

  def self.regexpize_date_format( df )
    Regexp.new( date_format_to_regexp_string_with_literal_percentages( df ) )
  end

  # Date format
  def self.date_format=( df )
    ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!( :default => df, :db => '%Y-%m-%d' )
    self.df = df
  end

  def self.date_format
    self.df || "%Y-%m-%d"
  end

  def self.date_format_regexp
    regexpize_date_format( date_format )
  end

  def self.human_date_format
    humanize_date_format( date_format )
  end

  def self.jquery_date_format
    self.date_format_to_jquery_format( date_format )
  end

  def self.jquery_datepicker_format
    self.date_format_to_jquery_format( date_format, true )
  end

  # Time format
  def self.timeofday_format=( tf )
    self.tf = tf
  end

  def self.timeofday_format
    self.tf || "%H:%M"
  end

  def self.timeofday_format_regexp
    regexpize_date_format( timeofday_format )
  end

  def self.human_timeofday_format
    humanize_date_format( timeofday_format )
  end
  
  def self.jquery_datetime_format
    self.date_format_to_jquery_format( datetime_format )
  end

  def self.jquery_timeofday_format
    self.date_format_to_jquery_format( timeofday_format )
  end

  # DateTime format
  def self.datetime_format=( dtf )
    ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!( :default => dtf )
    self.dtf = dtf
  end

  def self.datetime_format
    self.dtf || (self.date_format + ' ' + self.timeofday_format)
  end

  def self.datetime_format_regexp
    regexpize_date_format( datetime_format )
  end

  def self.human_datetime_format
    humanize_date_format( datetime_format )
  end

end
