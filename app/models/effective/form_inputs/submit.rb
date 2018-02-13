module Effective
  module FormInputs
    class Submit < Effective::FormInput

      def wrapper_options
        if layout == :horizontal
          { class: 'form-group row form-actions'}
        else
          { class: 'form-group form-actions'}
        end
      end

      def input_html_options
        { class: 'btn btn-primary' }
      end

      def label_options
        false
      end

      def feedback_options
        false
      end

    end
  end
end
