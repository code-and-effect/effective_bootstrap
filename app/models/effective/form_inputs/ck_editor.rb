module Effective
  module FormInputs
    class CkEditor < Effective::FormInput

      def build_input(&block)
        content = value.presence || (capture(&block) if block_given?)
        @builder.super_text_area(name, (options[:input] || {}).merge(autocomplete: 'off'))
      end

      def input_html_options
        { class: 'effective_ck_editor form-control', id: unique_id }
      end

      def input_js_options
        {
          effective_ckeditor_js_path: asset_path('effective_ckeditor.js'),
          effective_ckeditor_css_path: asset_path('effective_ckeditor.css'),
          contentsCss: contentsCss,
          toolbar: toolbar,
          height: height,
          width: width
        }.compact
      end

      def contentsCss
        @contents_css ||= case (obj = options.delete(:contentsCss))
        when :bootstrap
          'https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css'
        when false then nil
        else obj || asset_path('application.css')
        end
      end

      def toolbar
        @toolbar ||= (options.delete(:toolbar) || :full)
      end

      def height
        @height ||= options.delete(:height)
      end

      def width
        @width ||= options.delete(:width)
      end

    end
  end
end
