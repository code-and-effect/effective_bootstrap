# frozen_string_literal: true

module Effective

  module FormInputs
    class Checks < CollectionInput

      def build_input(&block)
        html = @builder.collection_check_boxes(name, options_collection, value_method, label_method, collection_options, item_input_options) { |builder| build_item(builder) }

        if disabled? # collection_check_boxes doesn't correctly disable the input type hidden, but does on the build_items
          html = html.sub('<input type="hidden"', '<input type="hidden" disabled="disabled"').html_safe
        end

        html
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
        return BLANK if options[:label] == false && !actions?
        return BLANK if name.kind_of?(NilClass)

        text = begin
          if options[:label] == false
            nil
          elsif options[:label].key?(:text)
            options[:label].delete(:text)
          elsif object.present?
            object.class.human_attribute_name(name)
          end || BLANK
        end.html_safe

        actions = if !disabled? && actions?
          content_tag(:div, class: 'effective-checks-actions text-muted') do
            link_to('Select All', '#', 'data-effective-checks-all': true) + ' - ' + link_to('Select None', '#', 'data-effective-checks-none': true)
          end
        end

        content_tag(:label, options[:label]) do
          [text, actions].compact.join.html_safe
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

      def actions? # default true
        return @actions unless @actions.nil?
        @actions = (options[:input].delete(:actions) != false)
      end

    end
  end
end
