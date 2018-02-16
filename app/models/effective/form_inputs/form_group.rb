module Effective
  module FormInputs
    class FormGroup < Effective::FormInput

      def input_html_options
        if layout == :horizontal
          { class: 'form-group col-sm-10' }
        else
          { class: 'form-group' }
        end
      end

      def to_html(&block)
        case layout
        when :horizontal
          build_wrapper do
            content_tag(:div, '', class: 'col-sm-2') + content_tag(:div, capture(&block), options[:input])
          end
        else
          content_tag(:div, capture(&block), options[:input])
        end
      end

    end
  end
end
