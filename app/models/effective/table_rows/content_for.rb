# frozen_string_literal: true

module Effective
  module TableRows
    class ContentFor < Effective::TableRow

      def to_html(&block)
        content_tag(:tr, class: "effective-table-summary-#{label_content.parameterize}") do
          content_tag(:th, label_content) + content_tag(:td, template.capture(&block))
        end
      end

    end
  end
end
