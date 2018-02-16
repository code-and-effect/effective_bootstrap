module Effective
  module FormInputs
    class ErrorField < Effective::FormInput

      def input_html_options
        { class: 'alert alert-danger' }
      end

      def to_html(&block)
        return nil unless has_error?(name)

        case layout
        when :horizontal
          build_wrapper do
            content_tag(:div, '', class: 'col-sm-2') + content_tag(:div, build_error_content, class: 'col-sm-10')
          end
        else
          content_tag(:div, build_error_content, class: 'form-group')
        end
      end

      def build_error_content
        include_name = include_name?

        content = (
          if name.blank?
            object.errors.full_messages.to_sentence
          elsif include_name?
            object.errors.full_messages_for(name).to_sentence
          else
            object.errors.messages[name].to_sentence
          end
        )

        content_tag(:div, content, options[:input])
      end

      private

      def include_name?
        return @include_name unless @include_name.nil?
        @include_name = options[:input].key?(:include_name) ? options[:input].delete(:include_name) : true
      end

    end
  end
end
