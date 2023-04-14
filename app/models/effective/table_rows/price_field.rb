# frozen_string_literal: true

module Effective
  module TableRows
    class PriceField < Effective::TableRow

      def content
        template.price_to_currency(value) if value.present?
      end

    end
  end
end
