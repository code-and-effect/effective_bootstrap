# frozen_string_literal: true

module Effective
  module FormInputs
    class RichTextArea < Effective::FormInput

      def input_html_options
        { class: 'form-control effective_rich_text_area trix-content', id: tag_id }
      end

    end
  end
end
