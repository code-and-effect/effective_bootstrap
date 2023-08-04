# frozen_string_literal: true

module Effective
  module TableRows
    class PhoneField < Effective::TableRow

      def content
        return unless value.present?

        digits = value.split('x').first.delete('^0-9')
        link_to(value, "tel:+1#{digits}")
      end

    end
  end
end
