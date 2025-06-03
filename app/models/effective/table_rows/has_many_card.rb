# frozen_string_literal: true

module Effective
  module TableRows
    class HasManyCard < Effective::TableRow

      def to_html(&block)
        table = builder.render(&block)

        content_tag(:tr, class: "#{tr_class}-#{index+1}") do
          content_tag(:td, colspan: 2) do
            content_tag(:div, class: 'card my-3') do
              content_tag(:div, table, class: 'card-body') do
                content_tag(:h5, template.et(object) + " ##{index+1}", class: 'card-title') + table
              end
            end
          end
        end
      end

      def index
        options[:index] || 0
      end
    end
  end
end
