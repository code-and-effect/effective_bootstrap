module Effective
  module FormInputs
    class EmailCcField < Effective::FormInput

      def build_input(&block)
        @builder.super_text_field(name, options[:input])
      end

      def input_html_options
        { class: 'form-control', placeholder: 'one@example.com,two@example.com' }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('at-sign'), class: 'input-group-text') }
      end

    end
  end
end
