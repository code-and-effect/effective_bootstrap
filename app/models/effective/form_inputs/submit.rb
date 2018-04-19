module Effective
  module FormInputs
    class Submit < Effective::FormInput

      def to_html(&block)
        return super unless (form_readonly? || form_disabled?)
      end

      def build_input(&block)
        tags = [
          icon('check', style: 'display: none;'),
          icon('x', style: 'display: none;'),
          icon('spinner'),
          (block_given? ? capture(&block) : content_tag(:button, name, options[:input]))
        ]

        (left? ? tags.reverse.join : tags.join).html_safe
      end

      def wrapper_options
        @right = true unless (left? || center? || right?)

        classes = [
          ('row' if layout == :horizontal),
          'form-group form-actions',
          ('form-actions-bordered' if border?),
          ('justify-content-start' if left? && layout == :vertical),
          ('justify-content-center' if center? && layout == :vertical),
          ('justify-content-end' if right? && layout == :vertical)
        ].compact.join(' ')

        { class: classes }
      end

      def input_html_options
        { class: 'btn btn-primary', type: 'submit', name: 'commit', value: name }
      end

      def label_options
        false
      end

      private

      def border?
        return @border unless @border.nil?
        @border = options.key?(:border) ? options.delete(:border) : true
      end

      def left?
        return @left unless @left.nil?
        @left = (options.delete(:left) || false)
      end

      def center?
        return @center unless @center.nil?
        @center = (options.delete(:center) || false)
      end

      def right?
        return @right unless @right.nil?
        @right = (options.delete(:right) || false)
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
