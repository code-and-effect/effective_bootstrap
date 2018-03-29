module Effective
  module FormInputs
    class Submit < Effective::FormInput

      def build_input(&block)
        icon('spinner') + (block_given? ? capture(&block) : content_tag(:button, name, options[:input]))
      end

      def wrapper_options
        border = options.key?(:border) ? options.delete(:border) : true
        left = options.delete(:left) || false
        center = options.delete(:center) || false
        right = options.delete(:right) || false
        right = true unless (left || center)

        classes = [
          ('row' if layout == :horizontal),
          'form-group form-actions',
          ('form-actions-bordered' if border),
          ('justify-content-start' if left),
          ('justify-content-center' if center),
          ('justify-content-end' if right)
        ].compact.join(' ')

        { class: classes }
      end

      def input_html_options
        { class: 'btn btn-primary', type: 'submit', name: 'commit', value: name }
      end

      def label_options
        false
      end

      def feedback_options
        # case layout
        # when :inline
        #   false
        # else
        #   {
        #     valid: { class: 'valid-feedback', text: 'Looks good! Submitting...' },
        #     invalid: {
        #       class: 'invalid-feedback',
        #       text: 'one or more errors are present. please fix the errors above and try again.'
        #     }
        #   }
        # end
        false
      end

    end
  end
end
