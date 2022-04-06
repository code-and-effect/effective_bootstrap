# frozen_string_literal: true

module Effective
  module FormInputs
    class FloatField < Effective::FormInput

      def build_input(&block)
        @builder.super_number_field(name, options[:input])
      end

      def input_html_options
        {
          class: 'form-control effective_float',
          autocomplete: 'off',
          step: '0.001',
          id: tag_id
        }
      end

      # This has gotta be a valid pattern
      def validated?(name)
        true
      end

    end
  end
end
