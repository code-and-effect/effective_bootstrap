# frozen_string_literal: true

module Effective
  module FormInputs
    class PriceField < Effective::FormInput

      def build_input(&block)
        @builder.hidden_field(name, value: price, id: tag_id + '_value_as_integer') +
        @template.text_field_tag(name, @template.number_to_currency(currency, unit: ''), options[:input].merge(id: tag_id, name: nil))
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('dollar-sign'), class: 'input-group-text') }
      end

      def input_html_options
        { class: 'form-control effective_price', autocomplete: 'off', id: tag_id }
      end

      private

      def price
        return nil unless value
        value.kind_of?(Integer) ? value : ('%.2f' % (value / 100.0))
      end

      def currency
        return nil unless value
        value.kind_of?(Integer) ? ('%.2f' % (value / 100.0)) : value
      end

    end
  end
end
