module Effective
  module FormInputs
    class IntegerField < Effective::FormInput

      def build_input(&block)
        @builder.super_text_field(name, options[:input])
      end

      def input_html_options
        { class: 'form-control effective_integer', autocomplete: 'off' }
      end

    end
  end
end
