module Effective
  module FormInputs
    class CheckBox < Effective::FormInput

      def label_position
        :after
      end

      def label_options
        { class: 'custom-control-label' }
      end

      def input_html_options
        { class: 'custom-control-input' }
      end

      def input_js_options
        { doit: 'good' }
      end

      def wrapper_options
        { class: 'custom-control custom-checkbox' }
      end

    end
  end
end
