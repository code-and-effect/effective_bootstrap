module Effective
  module FormInputs
    class TimeField < DatetimeField

      def input_html_options
        {
          class: ['form-control', 'effective_date_time_picker', 'effective_time', ('not-date-linked' if not_date_linked?)].compact.join(' '),
          pattern: '\d{2}:\d{2}'
        }
      end

      def input_js_options
        { format: 'HH:mm', showTodayButton: true, showClear: true, useCurrent: 'hour', disabledDates: disabled_dates.presence }.compact
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('clock'), class: 'input-group-text') }
      end

    end
  end
end
