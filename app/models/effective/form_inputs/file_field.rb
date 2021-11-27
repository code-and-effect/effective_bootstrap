# frozen_string_literal: true

module Effective
  module FormInputs
    class FileField < Effective::FormInput

      def build_input(&block)
        case attachments_style
        when :card
          build_existing_attachments + build_attachments + build_uploads + super
        when :table, :ck_assets
          super + build_existing_attachments + build_uploads + build_attachments
        else
          raise('unsupported attachments_style, try :card or :table')
        end
      end

      def input_html_options
        {
          id: tag_id,
          class: 'form-control form-control-file btn-outline-secondary',
          multiple: multiple?,
          direct_upload: true,
          'data-progress-template': progress_template,
          'data-click-submit': (true if click_submit?),
        }.compact
      end

      def multiple?
        name.to_s.pluralize == name.to_s
      end

      def required_presence?(obj, name)
        super(obj, name) && Array(object.public_send(name)).length == 0
      end

      def build_existing_attachments
        return ''.html_safe unless multiple?

        attachments = object.send(name)

        attachments.map.with_index do |attachment, index|
          @builder.hidden_field(name, multiple: true, id: (tag_id + "_#{index}"), value: attachment.signed_id)
        end.join.html_safe
      end

      def build_attachments
        return ''.html_safe unless object.respond_to?(name) && object.send(name).respond_to?(:attached?) && object.send(name).attached?

        attachments = object.send(name).respond_to?(:length) ? object.send(name) : [object.send(name)]

        case attachments_style
        when :card
          build_card_attachments(attachments)
        when :table, :ck_assets
          build_table_attachments(attachments)
        else
          raise('unsupported attachments_style, try :card or :table')
        end
      end

      def build_table_attachments(attachments)
        content_tag(:table, class: 'table table-hover effective_file_attachments') do
          content_tag(:thead) do
            content_tag(:tr) do
              content_tag(:th, 'Image') +
              content_tag(:th, 'Title') +
              content_tag(:th, 'Size') +
              content_tag(:th, '')
            end
          end +
          content_tag(:tbody) do
            attachments.map { |attachment| content_tag(:tr, build_table_attachment(attachment)) }.join.html_safe
          end
        end
      end

      def build_table_attachment(attachment)
        url = (@template.url_for(attachment) rescue false)
        url ||= (Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true) rescue false)

        return unless url

        image_tag = content_tag(:img, '', class: '', src: url, alt: attachment.filename.to_s) if attachment.image?
        link_tag = link_to(attachment.filename, url)
        size_tag = (attachment.content_type + '<br>' + @template.number_to_human_size(attachment.byte_size)).html_safe

        content_tag(:td, image_tag) +
        content_tag(:td, link_tag) +
        content_tag(:td, size_tag) +

        content_tag(:td) do
          if attachments_style == :ck_assets
            link_to('Attach', url, class: 'btn btn-primary', 'data-insert-ck-asset': true, alt: attachment.filename.to_s)
          end
        end
      end

      def build_card_attachments(attachments)
        content_tag(:div, attachments.map { |attachment| build_card_attachment(attachment) }.join.html_safe, class: 'effective_file_attachments row')
      end

      def build_card_attachment(attachment)
        url = (@template.url_for(attachment) rescue false)
        url ||= (Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true) rescue false)

        return unless url

        content_tag(:div, class: 'col') do
          content_tag(:div, class: 'card mb-3') do
            if attachment.image?
              content_tag(:div, class: 'card-body') do
                image_tag(url, alt: attachment.filename.to_s, class: 'img-fluid') +
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

      def click_submit?
        return @click_submit unless @click_submit.nil?
        @click_submit ||= (options.delete(:click_submit) || false)
      end

      def attachments_style
        @attachments_style ||= (options[:input].delete(:attachments_style) || options[:input].delete(:attachment_style) || :card)
      end

    end
  end
end
