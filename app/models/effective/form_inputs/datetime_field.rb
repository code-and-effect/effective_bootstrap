module Effective
  module FormInputs
    class DatetimeField < Effective::FormInput

      def input_html_options
        {
          class: ['form-control', 'effective_date_time_picker', 'effective_datetime', ('not-date-linked' if not_date_linked?)].compact.join(' '),
          pattern: pattern
        }
      end

      def input_js_options
        { format: format, sideBySide: true, showTodayButton: false, showClear: false, useCurrent: 'hour', disabledDates: disabled_dates.presence, minDate: min_date.presence, maxDate: max_date.presence }.compact
      end

      def input_group_options
        { input_group: { class: 'input-group effective_date_time_picker_input_group' }, prepend: content_tag(:span, icon('calendar'), class: 'input-group-text') }
      end

      def build_input(&block)
        @builder.super_text_field(name, options[:input].merge(value: datetime_to_s))
      end

      def datetime_to_s # ruby
        value&.strftime(am_pm? ? '%F %I:%M %p' : '%F %H:%M')
      end

      def pattern # html
        am_pm? ? '\d{4}(-\d{2})?(-\d{2})?( \d{1,2})?(:\d{2} [aApPmM]{2})?' : '\d{4}(\-d{2})?(-\d{2})?( \d{2})?(:\d{2})?'
      end

      def format # moment.js
        am_pm? ? 'YYYY-MM-DD LT' : 'YYYY-MM-DD HH:mm'
      end

      private

      def disabled_dates
        return @disabled_dates unless @disabled_dates.nil?
        @disabled_dates ||= Array(options.delete(:disabledDates)).map { |obj| parse_object_date(obj) }.flatten.compact
      end

      def max_date
        return @max_date unless @max_date.nil?
        @max_date = parse_object_date(options.delete(:maxDate))
      end

      def min_date
        return @min_date unless @min_date.nil?
        @min_date = parse_object_date(options.delete(:minDate))
      end

      def not_date_linked?
        return @not_date_linked unless @not_date_linked.nil?
        @not_date_linked = (options.delete(:date_linked) == false)
      end

      def am_pm?
        return @am_pm unless @am_pm.nil?
        @am_pm = options.key?(:am_pm) ? options.delete(:am_pm) : true
      end

      private

      def parse_object_date(obj)
        if obj.respond_to?(:strftime)
          obj.strftime('%F')
        elsif obj.kind_of?(Range) && obj.first.respond_to?(:strftime)
          [obj.first].tap do |dates|
            dates << (dates.last + 1.day) until (dates.last + 1.day) > obj.last
          end
        elsif obj.kind_of?(String)
          obj
        elsif obj.nil?
          obj
        else
          raise "unexpected date object #{obj}. Expected a DateTime, Range of DateTimes or String"
        end
      end

    end
  end
end
