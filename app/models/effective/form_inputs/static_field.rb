module Effective
  module FormInputs
    class StaticField < Effective::FormInput

      def input_html_options
        { class: 'form-control-plaintext', readonly: false }
      end

      def feedback_options
        false
      end

      def build_input(&block)
        content = block_given? ? capture(&block) : (options[:input].delete(:value) || value)
        content_tag(:p, content, options[:input].except(:readonly, :required, :value).merge(id: tag_id))
      end

    end
  end
end
