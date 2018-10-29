# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
# select(object, method, choices = nil, options = {}, html_options = {}, &block)
# ActionView::Helpers::FormBuilder.instance_method(:check_box).bind(self).call(m, opts, v)`

module Effective
  module FormInputs
    class Select < CollectionInput

      def build_input(&block)
        html = if polymorphic?
          @builder.grouped_collection_select(polymorphic_id_method, options_collection, group_method, group_label_method, option_key_method, option_value_method, collection_options, html_options)
        elsif grouped?
          @builder.grouped_collection_select(name, options_collection, group_method, group_label_method, option_key_method, option_value_method, collection_options, html_options)
        else
          @builder.collection_select(name, options_collection, value_method, label_method, collection_options, html_options)
        end

        if polymorphic?
          html += @builder.hidden_field(polymorphic_type_method, value: polymorphic_type_value)
          html += @builder.hidden_field(polymorphic_id_method, value: polymorphic_id_value)
        end

        if single_selected?
          html.gsub!('selected="selected"', '') if html.sub!('selected="selected"', "selected='selected'")
        end

        html.html_safe
      end

      def input_js_options
        opts = {
          theme: 'bootstrap',
          minimumResultsForSearch: 6,
          width: 'style',
          placeholder: (input_html_options.delete(:placeholder) || 'Please choose'),
          allowClear: (true if include_blank?),
          tokenSeparators: ([',', ';', '\n', '\t'] if tags?),
          tags: (true if tags?),
          template: js_template,
          containerClass: ('hide-disabled' if hide_disabled?),
          dropdownClass: ('hide-disabled' if hide_disabled?),
        }.compact
      end

      def input_html_options
        classes = [
          'effective_select',
          'form-control',
          ('polymorphic' if polymorphic?),
          ('grouped' if (grouped? || polymorphic?)),
          ('hide-disabled' if hide_disabled?),
          ('tags-input' if tags?),
        ].compact.join(' ')

        { class: classes, multiple: (true if multiple?), include_blank: (true if include_blank?) }.compact
      end

      private

      def include_blank?
        return @include_blank unless @include_blank.nil?
        @include_blank = (options.key?(:include_blank) ? options.delete(:include_blank) : true) && !multiple?
      end

      def multiple?
        return @multiple unless @multiple.nil?

        @multiple = options.key?(:multiple) ? options.delete(:multiple) : (tags? || name.to_s.ends_with?('_ids'))
      end

      def tags?
        return @tags unless @tags.nil?
        @tags = (options.delete(:tags) || false)
      end

      def hide_disabled?
        return @hide_disabled unless @hide_disabled.nil?
        @hide_disabled = (options.delete(:hide_disabled) || false)
      end

      def single_selected?
        return @single_selected unless @single_selected.nil?
        @single_selected = (options.delete(:single_selected) || false)
      end

      def js_template
        return @js_template unless @js_template.nil?
        @js_template = options.delete(:template)
      end

    end
  end
end
