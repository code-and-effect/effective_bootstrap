# frozen_string_literal: true

module Effective
  module TableRows
    class TextArea < Effective::TableRow

      def content
        template.simple_format(value) if value.present?
      end

    end
  end
end
