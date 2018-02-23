module Effective
  module FormInputs
    class Save < Effective::FormInput

      def to_html(&block)
        content_tag(:button, name, options[:input])
      end

      def input_html_options
        { class: 'btn btn-primary', type: 'submit', name: 'commit', value: name }
      end

    end
  end
end
