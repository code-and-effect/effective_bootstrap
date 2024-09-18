# frozen_string_literal: true

# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
# select(object, method, choices = nil, options = {}, html_options = {}, &block)
# ActionView::Helpers::FormBuilder.instance_method(:check_box).bind(self).call(m, opts, v)`

module Effective
  module FormInputs
    class Select < CollectionInput
      INCLUDE_NULL = 'Blank (null)'

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
          minimumResultsForSearch: (freeform? ? 0 : 6),
          width: 'style',
          placeholder: placeholder,
          allowClear: (true if include_blank?),
          tokenSeparators: ([',', ';', '\n', '\t'] if tags?),
          tags: (true if tags?),
          noResults: no_results,
          template: js_template,
          containerClass: ('hide-disabled' if hide_disabled?),
          dropdownClass: ('hide-disabled' if hide_disabled?),
          ajax: ({ url: ajax_url, dataType: 'json', delay: 250 } if ajax?)
        }.compact
      end

      def input_html_options
        classes = [
          'effective_select',
          'form-control',
          ('freeform' if freeform?),
          ('polymorphic' if polymorphic?),
          ('grouped' if (grouped? || polymorphic?)),
          ('hide-disabled' if hide_disabled?),
          ('tags-input' if tags?),
          ('disable-open-on-focus' if disable_open_on_focus?),
        ].compact.join(' ')

        { class: classes, multiple: (true if multiple?), include_blank: (true if include_blank?), id: tag_id }.compact
      end

      def assign_options_collection!
        super

        if ajax? && !include_null
          if options_collection.kind_of?(Array) && options_collection.first.respond_to?(:to_select2)
            @options_collection = options_collection.map { |obj| [obj.to_select2, obj.to_param] }
          end
        end

        return unless include_null

        # Check for singles - transform the array
        if options_collection.kind_of?(Array) && !options_collection.first.respond_to?(:to_a) # [:admin, :member]
          @options_collection = options_collection.map { |obj| [obj, obj] }
        end

        if options_collection.kind_of?(Array) && options_collection.first.respond_to?(:to_a)
          options_collection.push(['---------------', '-', disabled: 'disabled'])
          options_collection.push([include_null, 'nil'])
        end

        if options_collection.kind_of?(Hash)
          options_collection[include_null] = [
            Struct.new(:to_s, :id, :first, :second).new(include_null, 'nil', include_null, 'nil')
          ]
        end

        options_collection
      end

      def ajax?
        ajax_url.present?
      end

      private

      def include_null
        return @include_null unless @include_null.nil?

        obj = options.delete(:include_null)

        @include_null = case obj
        when nil then false
        when true then INCLUDE_NULL
        else obj
        end
      end

      def include_blank?
        return @include_blank unless @include_blank.nil?
        @include_blank = (options.key?(:include_blank) ? options.delete(:include_blank) : true) && !multiple?
      end

      def multiple?
        return false if freeform?
        return @multiple unless @multiple.nil?
        @multiple = options.key?(:multiple) ? options.delete(:multiple) : (tags? || name.to_s.ends_with?('_ids'))
      end

      def tags?
        return true if freeform?
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

      def disable_open_on_focus?
        return @disable_open_on_focus unless @disable_open_on_focus.nil?
        @disable_open_on_focus = (options.delete(:disable_open_on_focus) || false)
      end

      def freeform?
        return @freeform unless @freeform.nil?
        @freeform = (options.delete(:freeform) || false)
      end

      def no_results
        return @no_results unless @no_results.nil?

        @no_results = options.delete(:no_results)

        if freeform?
          @no_results ||= 'No results. To create a new one, press ENTER after typing your own free form response.'
        end
      end

      def js_template
        return @js_template unless @js_template.nil?
        @js_template = options.delete(:template)
      end

      def placeholder
        return @placeholder unless @placeholder.nil?

        obj = options.delete(:placeholder)

        @placeholder = case obj
        when nil then
          (freeform? ? 'Choose or enter' : 'Please choose')
        when false then ''
        else obj
        end
      end

      def ajax_url
        @ajax_url ||= (options.delete(:ajax_url) || options.delete(:ajax) || options.delete(:url))
      end

    end
  end
end
