# frozen_string_literal: true

module Effective
  module TableRows
    class UrlField < Effective::TableRow

      def content
        template.link_to(value, value, target: '_blank') if value.present?
      end

    end
  end
end
