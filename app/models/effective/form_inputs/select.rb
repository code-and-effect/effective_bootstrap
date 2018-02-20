# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
# select(object, method, choices = nil, options = {}, html_options = {}, &block)

module Effective
  module FormInputs
    class Select < Effective::FormInput

      def build_input(&block)
        html = ''

        if polymorphic?
          if grouped
            options[:collection].each { |_, group| polymorphize_collection!(group) }
          else
            polymorphize_collection!(options[:collection])
          end

          html += @builder.hidden_field(polymorphic_type_method, value: polymorphic_type_value)
          html += @builder.hidden_field(polymorphic_id_method, value: polymorphic_id_value)
        end

        single_selected? # Memoize for later. But this deletes the option

        html += capture(&block)

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
          allowClear: !multiple?,
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
          ('grouped' if grouped?),
          ('hide-disabled' if hide_disabled?),
          ('tags-input' if tags?),
        ].compact.join(' ')

        { class: classes, multiple: (true if multiple?), include_blank: !multiple? }.compact
      end

      protected

      # Translate our Collection into a polymorphic collection
      def polymorphize_collection!(collection)
        unless grouped? || collection[0].kind_of?(ActiveRecord::Base) || (collection[0].kind_of?(Array) && collection[0].length >= 2)
          raise "Polymorphic collection expecting a flat Array of mixed ActiveRecord::Base objects, or an Array of Arrays like [['Post A', 'Post_1'], ['Event B', 'Event_2']]"
        end

        collection.each_with_index do |obj, index|
          if obj.kind_of?(ActiveRecord::Base)
            collection[index] = [obj.to_s, "#{obj.class.model_name}_#{obj.id}"]
          end
        end
      end

      def polymorphic_type_method
        name.to_s.sub('_id', '') + '_type'
      end

      def polymorphic_id_method
        name.to_s.sub('_id', '') + '_id'
      end

      def polymorphic_value(obj)
        "#{object.class.model_name}_#{object.id}" if object
      end

      def polymorphic_type_value
        value.try(:class).try(:model_name)
      end

      def polymorphic_id_value
        value.try(:id)
      end

      private

      def multiple?
        return @multiple unless @multiple.nil?
        @multiple = (options.delete(:multiple) || false) || tags?
      end

      def tags?
        return @tags unless @tags.nil?
        @tags = (options.delete(:tags) || false)
      end

      def polymorphic?
        return @polymorphic unless @polymorphic.nil?
        @polymorphic = (options.delete(:polymorphic) || false)
      end

      def grouped?
        return @grouped unless @grouped.nil?
        @grouped = (options.delete(:grouped) || false)
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
