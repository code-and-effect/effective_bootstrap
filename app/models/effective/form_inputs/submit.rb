module Effective
  module FormInputs
    class Submit < Effective::FormInput

      def build_input(&block)
        content_tag(:button, name, options[:input])
      end

      def wrapper_options
        if layout == :horizontal
          { class: 'form-group row form-actions'}
        else
          { class: 'form-group form-actions'}
        end
      end

      def input_html_options
        { class: 'btn btn-primary', type: 'submit', name: 'commit', value: name }
      end

      def label_options
        false
      end

      def feedback_options
        case layout
        when :inline
          false
        else
          {
            valid: { class: 'valid-feedback', text: 'Looks good! Submitting...' },
            invalid: {
              class: 'invalid-feedback',
              text: 'one or more errors are present. please fix the errors above and try again.'
            }
          }
        end
      end

    end
  end
end
