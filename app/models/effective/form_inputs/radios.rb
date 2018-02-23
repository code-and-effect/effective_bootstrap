# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
module Effective
  module FormInputs
    class Radios < CollectionInput

      def build_input(&block)
        @builder.collection_radio_buttons(name, options_collection, value_method, label_method, collection_options, item_input_options) { |builder| build_item(builder) }
      end

      def build_wrapper(&block)
        if layout == :horizontal
          content_tag(:fieldset, content_tag(:div, yield, class: 'row'), options[:wrapper])
        else
          content_tag(:fieldset, yield, options[:wrapper])
        end
      end

      def wrapper_options
        { class: "form-group #{tag_id}" }
      end

      def feedback_options
        return false if layout == :inline

        {
          valid: { class: 'valid-feedback', style: ('display: block;' if has_error? && !has_error?(name)) }.compact,
          invalid: { class: 'invalid-feedback', style: ('display: block;' if has_error?(name)) }.compact
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

        content_tag((inline? ? :label : :legend), text, options[:label])
      end

      def build_item(builder)
        item_id = unique_id(builder.object)
        build_item_wrap { builder.radio_button(id: item_id) + builder.label(item_label_options.merge(for: item_id)) }
      end

      def build_item_wrap(&block)
        if custom?
          content_tag(:div, yield, class: 'custom-control custom-radio ' + (inline? ? 'custom-control-inline' : 'form-group'))
        else
          content_tag(:div, yield, class: 'form-check' + (inline? ? ' form-check-inline' : ''))
        end
      end

      def item_input_options
        options[:input].except(:inline, :custom)
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
