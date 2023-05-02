# frozen_string_literal: true

module Effective
  module TableRows
    class Collection < Effective::TableRow

      def initialize(name, collection, options, builder:)
        @collection = collection
        super(name, options, builder: builder)
      end

      def content
        values = Array(value) - [nil, '']

        if values.length > 1
          values.map { |v| content_tag(:div, v) }.join.html_safe
        elsif values.length == 1
          values.first
        end

      end

    end
  end
end
