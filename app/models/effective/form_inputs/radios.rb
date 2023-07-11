# frozen_string_literal: true

# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select

# buttons: true
# cards: true
# custom: false

# For cards, you should pass an html collection like
# [[card('First Item') {...}, 'first item'], [card('Second Item') {...}, 'second item']]
# or a collection like
# [['First Item', 'first'], ['Second Item', 'second']]

module Effective
  module FormInputs
    class Radios < CollectionInput

      def build_wrapper(&block)
        tag = (buttons? || cards?) ? :div : :fieldset

        if layout == :horizontal
          content_tag(tag, content_tag(:div, yield, class: 'row'), options[:wrapper])
        else
          content_tag(tag, yield, options[:wrapper])
        end
      end

      def build_input(&block)
        build_button_group do
          html = @builder.collection_radio_buttons(name, options_collection, value_method, label_method, collection_options, item_input_options) { |builder| build_item(builder) }

          if disabled? # collection_check_boxes doesn't correctly disable the input type hidden, but does on the build_items
            html = html.sub('<input type="hidden"', '<input type="hidden" disabled="disabled"').html_safe
          end

          html
        end
      end

      def build_button_group(&block)
        if buttons?
          content_tag(:div, yield, id: button_group_id, class: button_group_class, 'data-toggle': 'buttons')
        elsif cards?
          content_tag(:div, yield, id: button_group_id, class: button_group_class, 'data-toggle': 'cards')
        else
          yield
        end
      end

      def wrapper_options
        if buttons? || cards?
          { class: "form-group #{tag_id}" }
        else
          { class: "form-group #{tag_id} #{button_group_class}" }
        end
      end

      def button_group_class
        [
          'effective-radios',
          ('btn-group btn-group-toggle' if buttons?),
          ('cards card-deck' if cards?),
          ('no-feedback' unless feedback_options),
          ('is-invalid' if feedback_options && has_error?(name)),
          ('is-valid' if feedback_options && has_error? && !has_error?(name))
        ].compact.join(' ')
      end

      def feedback_options
        return false if layout == :inline

        {
          valid: { class: 'valid-feedback' }.compact,
          invalid: { class: 'invalid-feedback' }.compact
        }
      end

      def input_html_options
        if buttons?
          { autocomplete: 'off', class: 'effective-radios-input' }
        elsif cards?
          { autocomplete: 'off', class: 'effective-radios-input' }
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
        elsif cards?
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
        elsif cards?
          opts = item_label_options.merge(for: item_id)
          opts[:class] = [opts[:class], ('active' if active_item?(builder)), ('first-card' if first_item?) ].compact.join(' ')

          builder.label(opts) { builder.radio_button(id: item_id) + build_item_wrap { builder.text } }
        else
          build_item_wrap { builder.radio_button(id: item_id) + builder.label(item_label_options.merge(for: item_id)) }
        end
      end

      def build_item_wrap(&block)
        if cards? && options_collection_includes_cards?
          yield # Not required.
        elsif cards?
          content_tag(:div, class: 'card') do
            content_tag(:div, yield, class: ('card-body' if card_body?))
          end
        elsif custom?
          content_tag(:div, yield, class: 'custom-control custom-radio ' + (inline? ? 'custom-control-inline' : 'form-group'))
        else
          content_tag(:div, yield, class: 'form-check' + (inline? ? ' form-check-inline' : ''))
        end
      end

      def item_input_options
        options[:input].except(:inline, :custom, :buttons)
      end

      def options_collection_includes_cards?
        return @options_collection_includes_cards unless @options_collection_includes_cards.nil?
        @options_collection_includes_cards = options_collection.first(3).any? { |text, _| text.to_s.include?("div class=\"card") }
      end

      def item_label_options
        if buttons?
          { class: 'btn btn-outline-secondary' }
        elsif cards?
          { class: 'form-card-label' }
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

      def cards? # default false
        return @cards unless @cards.nil?
        @cards = (options.delete(:cards) || false)
      end

      def card_body? # default true
        return @card_body unless @card_body.nil?
        value = options.delete(:card_body)
        @card_body = (value == nil ? true : value)
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
