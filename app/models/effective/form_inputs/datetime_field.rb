module Effective
  module FormInputs
    class DatetimeField < Effective::FormInput

      def input_html_options
        {
          class: ['form-control', 'effective_date_time_picker', 'effective_datetime', ('not-date-linked' if not_date_linked?)].compact.join(' '),
          pattern: '\d{4}(-\d{2})?-(\d{2})?( \d+)?(:\d{2})?'
        }
      end

      def input_js_options
        { format: 'YYYY-MM-DD HH:mm', sideBySide: true, showTodayButton: true, showClear: true, useCurrent: 'hour', disabledDates: disabled_dates.presence }.compact
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, 'DateTime', class: 'input-group-text') }
      end

      def build_input(&block)
        @builder.super_text_field(name, options[:input])
      end

      private

      def disabled_dates
        return @disabled_dates unless @disabled_dates.nil?

        @disabled_dates ||= (
          Array(options.delete(:disabledDates)).map do |obj|
            if obj.respond_to?(:strftime)
              obj.strftime('%F')
            elsif obj.kind_of?(Range) && obj.first.respond_to?(:strftime)
              [obj.first].tap do |dates|
                dates << (dates.last + 1.day) until (dates.last + 1.day) > obj.last
              end
            elsif obj.kind_of?(String)
              obj
            else
              raise 'unexpected disabledDates data. Expected a DateTime, Range of DateTimes or String'
            end
          end.flatten.compact
        )
      end

      def not_date_linked?
        return @not_date_linked unless @not_date_linked.nil?
        @not_date_linked = (options.delete(:date_linked) == false)
      end

    end
  end
end
