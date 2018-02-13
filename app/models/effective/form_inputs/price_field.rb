module Effective
  module FormInputs
    class PriceField < Effective::FormInput

      def build_input(&block)
        @builder.hidden_field(name, value: price, id: tag_id + '_value_as_integer') +
        @template.text_field_tag(name, @template.number_to_currency(currency, unit: ''), options[:input].merge(id: tag_id, name: nil))
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, '$', class: 'input-group-text') }
      end

      def input_html_options
        { class: 'form-control effective_price', maxlength: 14, autocomplete: 'off', 'data-include-blank': include_blank? }
      end

      private

      def price
        return (include_blank? ? 0 : nil) unless value
        value.kind_of?(Integer) ? value : ('%.2f' % (val / 100.0))
      end

      def currency
        return (include_blank? ? 0.00 : nil) unless value
        value.kind_of?(Integer) ? ('%.2f' % (val / 100.0)) : value
      end

      def include_blank? # default false
        return @include_blank unless @include_blank.nil?
        @include_blank = (options.delete(:include_blank) || false)
      end

    end
  end
end
