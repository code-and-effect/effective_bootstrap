module Effective
  module FormInputs
    class Editor < Effective::FormInput

      def build_input(&block)
        content = value.presence || (capture(&block) if block_given?)

        @builder.super_text_area(name, (options[:input] || {}).merge(autocomplete: 'off')) +
        content_tag(:div, '', class: 'ql-effective', id: unique_id + '_editor')
      end

      def input_html_options
        { class: 'effective_editor form-control', id: unique_id }
      end

      def input_js_options
        {
          modules: { toolbar: toolbar, syntax: (content_mode == :code) },
          theme: 'snow',
          placeholder: "Add #{name.to_s.pluralize}...",
          content_mode: content_mode
        }
      end

      # Commented out 'Full' toolbar options because currently we don't want headers / source / code options
      def toolbar
        return false if content_mode == :code

        [
          # [{'header': [1, 2, 3, 4, false] }],
          ['bold', 'italic', 'underline'],
          ['link', 'image', 'video'], # also 'code-block'
          [{'list': 'ordered'}, { 'list': 'bullet' }],
          [{'align': [] }, 'clean'],
        ]
      end

      def content_mode # default false
        return @content_mode unless @content_mode.nil?

        @content_mode = (
          if options.delete(:delta)
            :delta
          elsif options.delete(:html)
            :html
          elsif options.delete(:code)
            :code
          else
            :delta
          end
        )
      end

    end
  end
end
