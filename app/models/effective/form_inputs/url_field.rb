# frozen_string_literal: true

module Effective
  module FormInputs
    class UrlField < Effective::FormInput

      def input_html_options
        {
          class: 'form-control effective_url',
          placeholder: 'https://www.example.com',
          id: tag_id,
          pattern: '(http:\/|https:\/)?\/[^\/+].+',
          type: 'text'
        }
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
