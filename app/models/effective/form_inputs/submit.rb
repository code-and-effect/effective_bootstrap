module Effective
  module FormInputs
    class Submit < Effective::FormInput

      def input_html_options
        { class: 'btn btn-primary' }
      end

      def to_html(&block)
        capture(&block)
      end

    end
  end
end
