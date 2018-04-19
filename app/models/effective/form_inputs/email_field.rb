module Effective
  module FormInputs
    class EmailField < Effective::FormInput

      def input_html_options
        { class: 'form-control', placeholder: 'someone@example.com' }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, icon('at-sign'), class: 'input-group-text') }
      end

      # This has gotta be a valid pattern
      def validated?(name)
        true
      end

    end
  end
end
