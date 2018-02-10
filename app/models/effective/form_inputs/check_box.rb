module Effective
  module FormInputs
    class CheckBox < Effective::FormInput

      def label_position
        :after
      end

      def label_options
        if options[:inline]
          { class: 'form-check-label' }
        else
          { class: 'custom-control-label' }
        end
      end

      def input_html_options
        if options[:inline]
          { class: 'form-check-input' }
        else
          { class: 'custom-control-input' }
        end
      end

      def input_js_options
        {}
      end

      def wrapper_options
        if options[:inline]
          { class: 'form-check-inline form-check' }
        else
          { class: 'custom-control custom-checkbox' }
        end

      end

    end
  end
end
