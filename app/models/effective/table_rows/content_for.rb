# frozen_string_literal: true

module Effective
  module TableRows
    class ContentFor < Effective::TableRow

      def to_html(&block)
        content_tag(:tr) do
          content_tag(:td, label_content) + content_tag(:td, template.capture(&block))
        end
      end

    end
  end
end
