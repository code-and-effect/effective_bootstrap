# frozen_string_literal: true

module Effective
  module FormInputs
    class PercentField < Effective::FormInput

      def build_input(&block)
        @builder.hidden_field(name, value: percent_to_integer, id: tag_id + '_value_as_integer') +
        @template.text_field_tag(name, percent_to_s, options[:input].merge(id: tag_id, name: nil))
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('percent'), class: 'input-group-text') }
      end

      def input_html_options
        { class: 'form-control effective_percent', autocomplete: 'off', id: tag_id }
      end

      # This has gotta be a valid pattern
      def validated?(name)
        true
      end

      private

      def percent_to_integer
        return nil unless value
        value.kind_of?(Integer) ? value : ('%.3f' % (value / 1000.0))
      end

      def percent_to_s
        return nil unless value
        str = value.kind_of?(Integer) ? ('%.3f' % (value / 1000.0)) : value.to_s
        str.gsub('.000', '')
      end

    end
  end
end
