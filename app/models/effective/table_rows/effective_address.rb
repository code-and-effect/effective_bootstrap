# frozen_string_literal: true

module Effective
  module TableRows
    class EffectiveAddress < Effective::TableRow

      def content
        value.to_html if value.present?
      end

    end
  end
end
