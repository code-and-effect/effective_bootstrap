# frozen_string_literal: true

module Effective
  module TableRows
    class DatetimeField < Effective::TableRow

      def content
        nice_date_time(value)
      end

      def nice_date_time(value)
        return unless value.respond_to?(:strftime)

        label = value.strftime("%b %-d, %Y %l:%M%P")
        full = value.strftime("%A %b %-d, %Y %l:%M%P %z")

        now = Time.zone.now

        distance = if (now > value)
          template.distance_of_time_in_words(now, value) + ' ago'
        else
          template.distance_of_time_in_words(value, now) + ' from now'
        end

        content_tag(:span, label, title: full + ' (' + distance + ')')
      end

    end
  end
end
