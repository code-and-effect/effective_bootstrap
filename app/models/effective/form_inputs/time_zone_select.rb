# frozen_string_literal: true

module Effective
  module FormInputs
    class TimeZoneSelect < Select

      def self.time_zone_collection
        date = Time.zone.now

        ActiveSupport::TimeZone.all.map do |tz|
          ["(UTC #{date.in_time_zone(tz).strftime('%:z')}) #{tz.name}", tz.name]
        end
      end

    end
  end
end
