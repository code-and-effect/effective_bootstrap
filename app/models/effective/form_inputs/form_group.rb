module Effective
  module FormInputs
    class FormGroup < Effective::FormInput

      def build_input(&block)
        content_tag(:label, (name || '&nbsp;').html_safe) + capture(&block)
      end

      def feedback_options
        false
      end

    end
  end
end
