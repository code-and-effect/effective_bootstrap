# frozen_string_literal: true

module Effective
  module TableRows
    class TextArea < Effective::TableRow

      def content
        return unless value.present?

        # Might be an Array or Hash. Serialized something.
        return value.to_s unless value.kind_of?(String)

        if value.start_with?('<') && value.end_with?('>')
          value.html_safe
        else
          template.simple_format(value)
        end
      end

    end
  end
end
