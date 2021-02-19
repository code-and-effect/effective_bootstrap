module Effective
  module FormInputs
    class PasswordField < Effective::FormInput

      def input_html_options
        { class: 'form-control effective_password', id: tag_id }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, append: eyes }
      end

      def eyes
        content_tag(:button, icon('eye'),
          class: 'btn input-group-text',
          title: 'Show password',
          'data-effective-password': 'text'
        ) +
        content_tag(:button, icon('eye-off'),
          class: 'btn input-group-text',
          title: 'Hide password',
          style: 'display: none;',
          'data-effective-password': 'password'
        )
      end

      def feedback_options
        case layout
        when :inline
          false
        else
          { valid: { class: 'valid-feedback' }, invalid: { class: 'invalid-feedback' }, reset: true }
        end
      end

    end
  end
end
