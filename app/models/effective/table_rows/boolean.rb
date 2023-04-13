# frozen_string_literal: true

module Effective
  module TableRows
    class Boolean < Effective::TableRow

      def content
        value == true ? icon('check') : icon('x')
      end

    end
  end
end
