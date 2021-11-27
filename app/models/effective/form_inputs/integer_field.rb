# frozen_string_literal: true

module Effective
  module FormInputs
    class IntegerField < Effective::FormInput

      def build_input(&block)
        @builder.super_text_field(name, options[:input].merge(value: value_to_i))
      end

      def input_html_options
        { class: 'form-control effective_integer', autocomplete: 'off', id: tag_id }
      end

      def value_to_i
        value.to_i if value
      end
    end
  end
end
