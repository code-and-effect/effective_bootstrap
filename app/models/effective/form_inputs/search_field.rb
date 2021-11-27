# frozen_string_literal: true

module Effective
  module FormInputs
    class SearchField < Effective::FormInput

      def input_html_options
        { class: 'form-control', placeholder: 'Search...' }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('search'), class: 'input-group-text') }
      end

    end
  end
end
