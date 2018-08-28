module Effective
  module FormInputs
    class DateField < DatetimeField

      def input_html_options
        {
          class: ['form-control', 'effective_date_time_picker', 'effective_date', ('not-date-linked' if not_date_linked?)].compact.join(' '),
          pattern: pattern
        }
      end

      def input_js_options
        { format: format, showTodayButton: false, showClear: false, useCurrent: 'hour', disabledDates: disabled_dates.presence }.compact
      end

      def input_group_options
        { input_group: { class: 'input-group effective_date_time_picker_input_group' }, prepend: content_tag(:span, icon('calendar'), class: 'input-group-text') }
      end

      def datetime_to_s # ruby
        value&.strftime('%F')
      end

      def pattern # html
        '\d{4}(-\d{2})?(-\d{2})?'
      end

      def format # moment.js
        'YYYY-MM-DD'
      end

    end
  end
end
