module Effective
  module FormInputs
    class Delete < Submit

      def build_input(&block)
        tags = [
          icon('check', style: 'display: none;'),
          icon('x', style: 'display: none;'),
          icon('spinner'),
          (block_given? ? capture(&block) : content_tag(:a, name, options[:input]))
        ]

        (left? ? tags.reverse.join : tags.join).html_safe
      end

      def input_html_options
        { class: 'btn btn-warning', data: { method: :delete, remote: true, confirm: "Really delete<br>#{object}?".html_safe } }
      end

      def border?
        false
      end

    end
  end
end
