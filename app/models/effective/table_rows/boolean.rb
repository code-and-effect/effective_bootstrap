# frozen_string_literal: true

module Effective
  module TableRows
    class Boolean < Effective::TableRow

      def to_html(&block)
        content_tag(:tr, class: tr_class) do
          content_tag(:td, colspan: 2) do
            content_tag(:span, content.presence || '-') + label_content
          end
        end
      end

      def content
        if value
          template.badge('Yes', class: 'badge badge-success mr-2')
        else
          template.badge('No', class: 'badge badge-danger mr-2')
        end
      end

    end
  end
end
