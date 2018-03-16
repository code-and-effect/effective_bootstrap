# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
module Effective
  module FormInputs
    class Radios < CollectionInput

      def build_wrapper(&block)
        tag = buttons? ? :div : :fieldset

        if layout == :horizontal
          content_tag(tag, content_tag(:div, yield, class: 'row'), options[:wrapper])
        else
          content_tag(tag, yield, options[:wrapper])
        end
      end

      def build_input(&block)
        build_button_group do
          @builder.collection_radio_buttons(name, options_collection, value_method, label_method, collection_options, item_input_options) { |builder| build_item(builder) }
        end
      end

      def build_button_group(&block)
        if buttons?
          content_tag(:div, yield, id: button_group_id, class: 'btn-group btn-group-toggle effective-radios', 'data-toggle': 'buttons')
        else
          yield
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
        if buttons?
          { autocomplete: 'off' }
        elsif custom?
          { class: 'custom-control-input' }
        else
          { class: 'form-check-input' }
        end
      end

      def build_label
        return BLANK if options[:label] == false
        return BLANK if name.kind_of?(NilClass)

        tag = (buttons? || inline?) ? :label : :legend
        text = (options[:label].delete(:text) || (object.class.human_attribute_name(name) if object) || BLANK).html_safe

        if buttons?
          content_tag(:label, text, options[:label].merge(for: button_group_id))
        elsif inline?
          content_tag(:label, text, options[:label])
        else
          content_tag(:legend, text, options[:label])
        end
      end

      def build_item(builder)
        item_id = unique_id(builder.object)

        if buttons?
          opts = item_label_options.merge(for: item_id)
          opts[:class] = [opts[:class], ('active' if active_item?(builder)), ('first-button' if first_item?) ].compact.join(' ')

          builder.label(opts) { builder.radio_button(id: item_id) + builder.text }
        else
          build_item_wrap { builder.radio_button(id: item_id) + builder.label(item_label_options.merge(for: item_id)) }
        end
      end

      def build_item_wrap(&block)
        if custom?
          content_tag(:div, yield, class: 'custom-control custom-radio ' + (inline? ? 'custom-control-inline' : 'form-group'))
        else
          content_tag(:div, yield, class: 'form-check' + (inline? ? ' form-check-inline' : ''))
        end
      end

      def item_input_options
        options[:input].except(:inline, :custom, :buttons)
      end

      def item_label_options
        if buttons?
          { class: 'btn btn-outline-secondary' }
        elsif custom?
          { class: 'custom-control-label' }
        else
          { class: 'form-check-label' }
        end
      end

      def buttons? # default false
        return @buttons unless @buttons.nil?
        @buttons = (options.delete(:buttons) || false)
      end

      def button_group_id
        "#{tag_id}_btn_group"
      end

      def first_item?
        return false unless @first_item.nil?
        @first_item = true
      end

      def active_item?(builder)
        value = self.value || collection_options[:checked]
        value == builder.value || Array(value).map(&:to_s) == Array(builder.value).map(&:to_s)
      end

    end
  end
end