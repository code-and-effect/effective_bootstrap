# frozen_string_literal: true

module Effective
  module TableRows
    class FileField < Effective::TableRow

      def content
        values = Array(value) - [nil, '']

        if values.length > 1
          values.map { |file| content_tag(:div, link_to_file(file)) }.join.html_safe
        elsif values.length == 1
          link_to_file(values.first)
        end
      end

      def link_to_file(file)
        link_to(file.filename, template.url_for(file), target: '_blank')
      end

    end
  end
end
