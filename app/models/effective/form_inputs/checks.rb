# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
# select(object, method, choices = nil, options = {}, html_options = {}, &block)
# ActionView::Helpers::FormBuilder.instance_method(:check_box).bind(self).call(m, opts, v)`

module Effective
  module FormInputs
    class Checks < CollectionInput

      def build_input(&block)
        binding.pry

        @builder.collection_check_boxes(name, options_collection, value_method, label_method, collection_options, item_html_options, &proc { |builder| render_item(builder) })
      end

      def item_html_options
        {}
        #@item_html_options ||= html_options
      end

      def render_item(builder)
        build_item_wrap { builder.check_box(item_html_options) + builder.label(item_label_options) }
      end

      def build_wrapper(&block)
        content_tag(:fieldset, yield, options[:wrapper])
      end

      def build_label
        return BLANK if options[:label] == false
        return BLANK if name.kind_of?(NilClass)

        text = (options[:label].delete(:text) || (object.class.human_attribute_name(name) if object) || BLANK).html_safe

        content_tag(:legend, text, options[:label])
      end

      def input_js_options
      end

      def input_html_options
        { class: 'effective_checks form-control' }
      end

      def build_item_wrap(&block)
        if custom?
          content_tag(:div, yield, class: 'form-group custom-control custom-checkbox' + (inline? ? ' custom-control-inline' : ''))
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
        @custom = (options.delete(:custom) != false)
      end

    end
  end
end
