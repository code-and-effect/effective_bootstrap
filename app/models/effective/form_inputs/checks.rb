module Effective
  module FormInputs
    class Checks < CollectionInput

      def build_input(&block)
        @builder.collection_check_boxes(name, options_collection, value_method, label_method, collection_options, item_input_options) { |builder| build_item(builder) }
      end

      def build_wrapper(&block)
        if layout == :horizontal
          content_tag(:fieldset, content_tag(:div, yield, class: 'row'), options[:wrapper])
        else
          content_tag(:fieldset, yield, options[:wrapper])
        end
      end

      def wrapper_options
        { class: [
            'form-group effective-checks',
            ('no-feedback' unless feedback_options),
            tag_id,
            ('is-invalid' if feedback_options && has_error?(name)),
            ('is-valid' if feedback_options && has_error? && !has_error?(name))
          ].compact.join(' ')
        }
      end

      def feedback_options
        return false if layout == :inline

        {
          valid: { class: 'valid-feedback' }.compact,
          invalid: { class: 'invalid-feedback' }.compact
        }
      end

      def input_html_options
        if custom?
          { class: 'custom-control-input' }
        else
          { class: 'form-check-input' }
        end
      end

      def build_label
        return BLANK if options[:label] == false
        return BLANK if name.kind_of?(NilClass)

        text = (options[:label].delete(:text) || (object.class.human_attribute_name(name) if object) || BLANK).html_safe

        content_tag((inline? ? :label : :legend), options[:label]) do
          text + content_tag(:small, class: 'effective-checks-actions text-muted ml-1') do
            link_to('All', '#', 'data-effective-checks-all': true) + ' - ' + link_to('None', '#', 'data-effective-checks-none': true)
          end
        end
      end

      def build_item(builder)
        item_id = unique_id(builder.object)
        build_item_wrap { builder.check_box(id: item_id) + builder.label(item_label_options.merge(for: item_id)) }
      end

      def build_item_wrap(&block)
        if custom?
          content_tag(:div, yield, class: 'custom-control custom-checkbox ' + (inline? ? 'custom-control-inline' : 'form-group'))
        else
          content_tag(:div, yield, class: 'form-check' + (inline? ? ' form-check-inline' : ''))
        end
      end

      def item_input_options
        options[:input].except(:inline, :custom, :required)
      end

      def item_label_options
        if custom?
          { class: 'custom-control-label' }
        else
          { class: 'form-check-label' }
        end
      end

    end
  end
end
