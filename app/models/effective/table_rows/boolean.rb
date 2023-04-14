# frozen_string_literal: true

module Effective
  module TableRows
    class Boolean < Effective::TableRow

      def content
        if value
          template.badge('YES')
        else
          template.badge('NO', class: 'badge badge-light')
        end
      end

    end
  end
end
