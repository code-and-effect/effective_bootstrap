module Effective
  module FormInputs
    class FileField < Effective::FormInput

      def build_input(&block)
        build_attachments + build_uploads + super
      end

      def input_html_options
        { class: 'form-control-file', multiple: multiple?, direct_upload: true, 'data-progress-template': progress_template }
      end

      def multiple?
        name.to_s.pluralize == name.to_s
      end

      def build_attachments
        return ''.html_safe unless object.respond_to?(name) && object.send(name).respond_to?(:attached?) && object.send(name).attached?

        attachments = object.send(name).respond_to?(:length) ? object.send(name) : [object.send(name)]

        content_tag(:div, attachments.map { |attachment| build_attachment(attachment) }.join.html_safe, class: 'attachments row')
      end

      def build_attachment(attachment)
        url = @template.url_for(attachment)

        content_tag(:div, class: 'col-3') do
          content_tag(:div, class: 'card mb-3') do
            if attachment.image?
              content_tag(:img, '', class: 'card-img-top', src: url, alt: attachment.filename.to_s) +
              content_tag(:div, class: 'card-body') do
                link_to(attachment.filename, url, class: 'card-link')
              end
            else
              content_tag(:div, class: 'card-body') do
                content_tag(:p, link_to(attachment.filename, url, class: 'card-link'), class: 'card-text') +
                content_tag(:p, class: 'card-text') do
                  (attachment.content_type + '<br>' + @template.number_to_human_size(attachment.byte_size)).html_safe
                end
              end

            end.html_safe
          end
        end

      end

      def build_uploads
        content_tag(:div, '', class: 'uploads')
      end

      def progress_template
        content_tag(:div, class: 'direct-upload direct-upload--pending', 'data-direct-upload-id': '$ID$') do
          content_tag(:div, '', class: 'direct-upload__progress', style: 'width: 0%') +
          content_tag(:span, '$FILENAME$', class: 'direct-upload__filename')
        end
      end

    end
  end
end
