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
          values.map { |v| content_tag(:div, item_content(v)) }.join.html_safe
        elsif values.length == 1
          item_content(values.first)
        end
      end

      def item_content(value)
        item = @collection.find { |k, v| (k && k == value) || (v && v == value) || k.try(:id) == value }
        (item || value).to_s
      end

    end
  end
end
