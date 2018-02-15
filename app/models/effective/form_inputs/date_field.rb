module Effective
  module FormInputs
    class DateField < DatetimeField

      def input_html_options
        {
          class: ['form-control', 'effective_date_time_picker', 'effective_date', ('not-date-linked' if not_date_linked?)].compact.join(' '),
          pattern: '\d{4}(-\d{2})?(-\d{2})?'
        }
      end

      def input_js_options
        { format: 'YYYY-MM-DD', showTodayButton: true, showClear: true, useCurrent: 'hour', disabledDates: disabled_dates.presence }.compact
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('calendar'), class: 'input-group-text') }
      end

    end
  end
end
