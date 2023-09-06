# frozen_string_literal: true

module Effective
  module TableRows
    class ArticleEditor < Effective::TableRow

      def content
        return unless value.present?

        if value.start_with?('<') && value.end_with?('>')
          value.html_safe
        else
          template.simple_format(value)
        end
      end

    end
  end
end
