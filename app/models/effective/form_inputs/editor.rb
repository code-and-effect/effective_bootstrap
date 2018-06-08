module Effective
  module FormInputs
    class Editor < Effective::FormInput

      def build_input(&block)
        @builder.hidden_field(name, value: value, id: tag_id) +
        content_tag(:div, options[:input]) { value }
      end

      def input_js_options
        { modules: { toolbar: toolbar }, theme: 'snow', placeholder: "Add #{name.to_s.pluralize}..." }
      end

      def input_html_options
        { class: 'effective-editor', id: tag_id + '_editor' }
      end

      def toolbar
        [
          ['bold', 'italic', 'underline', 'strike'],        # toggled buttons
          ['blockquote', 'code-block'],

          [{ 'header': 1 }, { 'header': 2 }],               # custom button values
          [{ 'list': 'ordered'}, { 'list': 'bullet' }],
          [{ 'script': 'sub'}, { 'script': 'super' }],      # superscript/subscript
          [{ 'indent': '-1'}, { 'indent': '+1' }],          # outdent/indent
          [{ 'direction': 'rtl' }],                         # text direction

          [{ 'size': ['small', false, 'large', 'huge'] }],  # custom dropdown
          [{ 'header': [1, 2, 3, 4, 5, 6, false] }],

          [{ 'color': [] }, { 'background': [] }],          # dropdown with defaults from theme
          [{ 'font': [] }],
          [{ 'align': [] }],

          ['clean']                                         # remove formatting button
        ]
      end

      def toolbar
        [
          [{ 'header': [1, 2, 3, 4, false] }],
          ['bold', 'italic', 'underline'],        # toggled buttons
          ['code-block', 'image', 'link', 'video'],
          [{ 'list': 'ordered'}, { 'list': 'bullet' }],
          [{ 'align': [] }],
          ['clean']                                         # remove formatting button
        ]
      end

    end
  end
end
