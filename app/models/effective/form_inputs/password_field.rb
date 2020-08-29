module Effective
  module FormInputs
    class PasswordField < Effective::FormInput

      def input_html_options
        { class: 'form-control', id: tag_id }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('lock'), class: 'input-group-text') }
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
