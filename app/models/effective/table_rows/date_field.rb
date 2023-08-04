# frozen_string_literal: true

module Effective
  module TableRows
    class DateField < Effective::TableRow

      def content
        nice_date(value)
      end

      def nice_date(value)
        return unless value.respond_to?(:strftime)

        label = value.strftime("%b %-d, %Y")
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
