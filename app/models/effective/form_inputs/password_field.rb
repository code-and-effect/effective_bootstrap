module Effective
  module FormInputs
    class PasswordField < Effective::FormInput

      def input_html_options
        { class: 'form-control' }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('lock'), class: 'input-group-text') }
      end

    end
  end
end
