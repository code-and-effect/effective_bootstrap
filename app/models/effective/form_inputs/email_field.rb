module Effective
  module FormInputs
    class EmailField < Effective::FormInput

      def input_html_options
        { class: 'form-control', placeholder: 'someone@example.com' }
      end

    end
  end
end
