module Effective
  module FormInputs
    class CheckBox < Effective::FormInput

      def wrap(&block)
        case layout
        when :inline
          build_wrapper { build_content(&block) }
        when :horizontal
          build_wrapper do
            content_tag(:div, '', class: 'col-sm-2') + content_tag(:div, class: 'col-sm-10') do
              content_tag(:div, build_item_content(&block), class: 'form-check')
            end
          end
        else # Vertical
          super
        end
      end

      def build_item_content(&block)
        (build_input(&block) + build_label + build_hint + build_feedback).html_safe
      end

      def label_position
        :after
      end

      def label_options
        { class: 'form-check-label' }
      end

      def input_html_options
        { class: 'form-check-input' }
      end

      def wrapper_options
        case layout
        when :inline
          { class: 'form-check mb-2 mr-sm-2' }
        when :horizontal
          { class: 'form-group row' }
        else
          options[:inline] ? { class: 'form-check form-check-inline' } : { class: 'form-check' }
        end
      end

    end
  end
end
