# frozen_string_literal: true

module Effective
  module FormInputs
    class ScaleField < Effective::FormInput

      def build_input(&block)
        @builder.hidden_field(name, value: scale_to_integer, id: tag_id + '_value_as_integer') +
        @template.text_field_tag(name, scale_to_s, options[:input].merge(id: tag_id, name: nil))
      end

      def input_html_options
        { class: 'form-control effective_scale', autocomplete: 'off', id: tag_id, 'data-scale': scale }
      end

      private

      def scale
        @scale ||= (options.delete(:scale) || 2)
      end

      def scaled(value)
        "%.#{scale}f" % (value / (10.0 ** scale))
      end

      def scale_to_integer
        return nil unless value
        value.kind_of?(Integer) ? value : scaled(value)
      end

      def scale_to_s
        return nil unless value

        str = (value.kind_of?(Integer) ? scaled(value) : value).to_s
        str.gsub('.' + ('0' * scale), '')
      end

    end
  end
end
