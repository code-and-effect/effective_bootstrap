# frozen_string_literal: true

module Effective
  module TableRows
    class PercentField < Effective::TableRow

      def content
        return unless value.present?
        str = value.kind_of?(Integer) ? ('%.3f' % (value / 1000.0)) : value.to_s
        str.gsub('.000', '') + '%'
      end
    end
  end
end
