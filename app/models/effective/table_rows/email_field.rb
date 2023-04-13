# frozen_string_literal: true

module Effective
  module TableRows
    class EmailField < Effective::TableRow

      def content
        value.to_s.include?('@') ? template.mail_to(value) : value.presence
      end

    end
  end
end
