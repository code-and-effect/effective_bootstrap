module Effective
  module FormInputs
    class TimeField < DatetimeField

      def input_html_options
        {
          class: ['form-control', 'effective_date_time_picker', 'effective_time', ('not-date-linked' if not_date_linked?)].compact.join(' '),
          pattern: pattern,
          id: tag_id
        }
      end

      def input_js_options
        { format: format, showTodayButton: false, showClear: false, useCurrent: 'hour', disabledDates: disabled_dates.presence, locale: I18n.locale }.compact
      end

      def input_group_options
        { input_group: { class: 'input-group effective_date_time_picker_input_group' }, prepend: content_tag(:span, icon('clock'), class: 'input-group-text') }
      end

      def datetime_to_s # ruby
        (value&.strftime(am_pm? ? '%I:%M %p' : '%H:%M') rescue nil)
      end

      def pattern # html
        am_pm? ? '\d{1,2}(:\d{2} [aApPmM]{2})?' : '\d{2}(:\d{2})?'
      end

      def format # moment.js
        am_pm? ? 'LT' : 'HH:mm'
      end

    end
  end
end
