module DateFormatter::ActiveRecord::ConnectionAdapters
  module QuotingExtension

    def quote_with_date_formatter(value, column = nil)
      # records are quoted as their primary key
      return value.quoted_id if value.respond_to?(:quoted_id)

      case value
        when String, ActiveSupport::Multibyte::Chars
          value = value.to_s
          if column && column.type == :binary && column.class.respond_to?(:string_to_binary)
            "'#{quote_string(column.class.string_to_binary(value))}'" # ' (for ruby-mode)
          elsif column && [:integer, :float].include?(column.type)
            value = column.type == :integer ? value.to_i : value.to_f
            value.to_s
          else
            "'#{quote_string(value)}'" # ' (for ruby-mode)
          end
        when NilClass                 then "NULL"
        when TrueClass                then (column && column.type == :integer ? '1' : quoted_true)
        when FalseClass               then (column && column.type == :integer ? '0' : quoted_false)
        when Float, Fixnum, Bignum    then value.to_s
        # BigDecimals need to be output in a non-normalized form and quoted.
        when BigDecimal               then value.to_s('F')
        when Date                     then "'#{value.to_s(:db)}'"
        when Time, DateTime           then "'#{quoted_date(value)}'"
        else                          "'#{quote_string(value.to_yaml)}'"
      end
    end

    def self.included( base )
      base.class_eval do 
        alias_method_chain :quote, :date_formatter
      end
    end

  end
end
