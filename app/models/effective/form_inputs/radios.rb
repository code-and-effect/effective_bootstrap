# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
# select(object, method, choices = nil, options = {}, html_options = {}, &block)
# ActionView::Helpers::FormBuilder.instance_method(:check_box).bind(self).call(m, opts, v)`

module Effective
  module FormInputs
    class Radios < CollectionInput

      def build_input(&block)
        @builder.collection_radio_buttons(name, options_collection, value_method, label_method, collection_options, item_html_options) { |builder| build_item(builder) }
      end

      def build_wrapper(&block)
        if layout == :horizontal
          content_tag(:fieldset, content_tag(:div, yield, class: 'row'), options[:wrapper])
        else
          content_tag(:fieldset, yield, options[:wrapper])
        end
      end

      def wrapper_options
        { class: 'form-group' }
      end

      def build_label
        return BLANK if options[:label] == false
        return BLANK if name.kind_of?(NilClass)

        text = (options[:label].delete(:text) || (object.class.human_attribute_name(name) if object) || BLANK).html_safe

        content_tag(:legend, text, options[:label])
      end

      def feedback_options
        return false if layout == :inline

        {
          valid: { class: 'valid-feedback', style: ('display: block;' if has_error? && !has_error?(name)) }.compact,
          invalid: { class: 'invalid-feedback', style: ('display: block;' if has_error?(name)) }.compact
        }
      end

      def build_item(builder)
        build_item_wrap { builder.radio_button + builder.label(item_label_options) }
      end

      def build_item_wrap(&block)
        if custom?
          content_tag(:div, yield, class: 'custom-control custom-radio ' + (inline? ? 'custom-control-inline' : 'form-group'))
        else
          content_tag(:div, yield, class: 'form-check' + (inline? ? ' form-check-inline' : ''))
        end
      end

      def item_label_options
        if custom?
          { class: 'custom-control-label' }
        else
          { class: 'form-check-label' }
        end
      end

      def item_html_options
        if custom?
          { class: 'custom-control-input' }
        else
          { class: 'form-check-input' }
        end
      end

      def inline? # default false
        return @inline unless @inline.nil?
        @inline = (options[:input].delete(:inline) == true)
      end

      def custom? # default true
        return @custom unless @custom.nil?
        @custom = (options[:input].delete(:custom) != false)
      end

    end
  end
end
