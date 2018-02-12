module Effective
  module FormInputs
    class FormGroup < Effective::FormInput

      def to_html(&block)
        case layout
        when :horizontal
          build_wrapper do
            content_tag(:div, '', class: 'col-sm-2') + content_tag(:div, capture(&block), class: 'col-sm-10')
          end
        else
          content_tag(:div, capture(&block), class: 'form-group')
        end
      end

    end
  end
end
