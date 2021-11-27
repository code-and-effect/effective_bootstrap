# frozen_string_literal: true

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
          modules: {
            toolbar: toolbar,
            imageResize: imageResize,
            imageDropAndPaste: imageDropAndPaste,
            magicUrl: magicUrl,
            syntax: (content_mode == :code)
          },
          theme: 'snow',
          placeholder: "Add #{name.to_s.pluralize}...",
          content_mode: content_mode,
          active_storage: active_storage
        }
      end

      # Commented out 'Full' toolbar options because currently we don't want headers / source / code options
      def toolbar
        return false if content_mode == :code

        [
          # [{'header': [1, 2, 3, 4, false] }],
          ['bold', 'italic', 'underline'],
          ['link', 'image', 'video'], # also 'code-block'
          [{'list': 'ordered'}, {'list': 'bullet'}, 'blockquote'],
          [{'align': [] }, 'clean']
        ]
      end

      def imageDropAndPaste
        active_storage && !(content_mode == :code)
      end

      def imageResize
        {
          displaySize: true,
          displayStyles: {
            backgroundColor: 'black',
            border: 'none',
            color: 'white'
          },
          modules: [ 'Resize', 'DisplaySize' ]
        }
      end

      def magicUrl
        true
      end

      def active_storage
        return @active_storage unless @active_storage.nil?

        @active_storage = if options.key?(:active_storage)
          options.delete(:active_storage)
        else
          defined?(ActiveStorage).present?
        end
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
