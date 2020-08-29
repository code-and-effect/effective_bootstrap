module Effective
  module FormInputs
    class NumberTextField < Effective::FormInput

      def build_input(&block)
        @builder.super_text_field(name, options[:input])
      end

      def input_html_options
        { class: 'form-control effective_number_text', autocomplete: 'off', id: tag_id }
      end

    end
  end
end
