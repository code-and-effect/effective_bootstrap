# http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
# select(object, method, choices = nil, options = {}, html_options = {}, &block)

module Effective
  module FormInputs
    class Select < Effective::FormInput

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
          ('polymorphic' if polymorphic?),
          ('grouped' if grouped?),
          ('hide-disabled' if hide_disabled?),
          ('tags-input' if tags?),
        ].compact.join(' ')

        { class: classes, multiple: multiple? }.compact
      end

      private

      def multiple? # default false
        return @multiple unless @multiple.nil?
        @multiple = (options.delete(:multiple) || false)
      end

      def tags? # default false
        return @tags unless @tags.nil?
        @tags = (options.delete(:tags) || false)
      end

      def polymorphic? # default false
        return @polymorphic unless @polymorphic.nil?
        @polymorphic = (options.delete(:polymorphic) || false)
      end

      def grouped? # default false
        return @grouped unless @grouped.nil?
        @grouped = (options.delete(:grouped) || false)
      end

      def hide_disabled? # default false
        return @hide_disabled unless @hide_disabled.nil?
        @hide_disabled = (options.delete(:hide_disabled) || false)
      end

      def js_template # default false
        return @js_template unless @js_template.nil?
        @js_template = options.delete(:template)
      end

    end
  end
end
