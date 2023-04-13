# frozen_string_literal: true

module Effective
  module TableRows
    class Collection < Effective::TableRow

      def initialize(name, collection, options, builder:)
        @collection = collection
        super(name, options, builder: builder)
      end

    end
  end
end
