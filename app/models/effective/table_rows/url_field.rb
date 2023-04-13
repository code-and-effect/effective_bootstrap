# frozen_string_literal: true

module Effective
  module TableRows
    class PercentField < Effective::TableRow

      def content
        template.link_to(value) if value.present?
      end

    end
  end
end
