module Effective
  module FormInputs
    class UrlField < Effective::FormInput

      def input_html_options
        { class: 'form-control', placeholder: 'https://www.example.com', id: tag_id }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('link'), class: 'input-group-text') }
      end

      # This has gotta be a valid pattern
      def validated?(name)
        true
      end

    end
  end
end
