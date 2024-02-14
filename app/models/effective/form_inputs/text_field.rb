# frozen_string_literal: true

module Effective
  module FormInputs
    class TextField < Effective::FormInput

      def input_html_options
        { class: 'form-control', maxlength: 250, id: tag_id }
      end

    end
  end
end
