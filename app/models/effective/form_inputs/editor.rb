module Effective
  module FormInputs
    class Editor < Effective::FormInput

      def build_input(&block)
        content = value.presence || (capture(&block) if block_given?)

        @builder.super_text_field(name, options[:input]) +
        content_tag(:div, '', class: 'ql-effective', id: unique_id + '_editor')
      end

      def input_html_options
        { class: 'effective_editor form-control', id: unique_id }
      end

      def input_js_options
        { modules: { toolbar: toolbar }, theme: 'snow', placeholder: "Add #{name.to_s.pluralize}...", delta: delta? }
      end

      # Commented out 'Full' toolbar options because currently we don't want headers / source / code options
      def toolbar
        [
          # [{'header': [1, 2, 3, 4, false] }],
          ['bold', 'italic', 'underline'],
          ['link', 'image', 'video'], # also 'code-block'
          [{'list': 'ordered'}, { 'list': 'bullet' }],
          [{'align': [] }, 'clean'],
        ]
      end

      def delta? # default false
        return @delta unless @delta.nil?

        if options.key?(:html)
          @delta = (options.delete(:html) == false)
        else
          @delta = (options.delete(:delta) || false)
        end
      end

    end
  end
end
