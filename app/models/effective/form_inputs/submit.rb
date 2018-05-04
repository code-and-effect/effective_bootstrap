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
          (
            if block_given?
              capture(&block)
            else
              content_tag(:button, options[:input]) do
                icon_name.present? ? (icon(icon_name) + name) : name
              end
            end
          )
        ]

        (left? ? tags.reverse.join : tags.join).html_safe
      end

      def wrapper_options
        @right = true unless (left? || center? || right?)

        classes = [
          ('row' if layout == :horizontal),
          'form-group form-actions',
          ('form-actions-inline' if inline?),
          ('form-actions-bordered' if border?),
          ('justify-content-start' if left? && layout == :vertical),
          ('justify-content-center' if center? && layout == :vertical),
          ('justify-content-end' if right? && layout == :vertical)
        ].compact.join(' ')

        { class: classes, id: tag_id }
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

      # Changes the svg feedback to use position absolute.
      def inline?
        return @form_actions_inline unless @form_actions_inline.nil?
        @form_actions_inline = (options.delete(:inline) || false)
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

      def icon_name
        return @icon unless @icon.nil?
        @icon = options[:input].delete(:icon) || ''.html_safe
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
