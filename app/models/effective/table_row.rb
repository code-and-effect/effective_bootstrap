# frozen_string_literal: true

module Effective
  class TableRow
    attr_accessor :name, :options, :builder, :template

    delegate :object, to: :builder
    delegate :capture, :content_tag, :image_tag, :link_to, :mail_to, :icon, to: :@template

    # So this takes in the options for an entire form group.
    def initialize(name, options, builder:)
      @builder = builder
      @template = builder.template

      @name = name
      @options = options
    end

    def controller_namespace
      Effective::Resource.new(template.controller.controller_path).namespace
    end

    # Intended for override
    def content
      value
    end

    # Render method
    def to_html(&block)
      content_tag(:tr, class: "effective-table-summary-#{label_content.parameterize}") do
        content_tag(:th, label_content) + content_tag(:td, content.presence || '-')
      end
    end

    def label_content
      hint = self.hint
      (hint.present? ? "#{label}#{hint}" : label).html_safe
    end

    # Humanized label or the label from form
    def label
      text = options[:label] || builder.human_attribute_name(name)
      prefix = builder.options[:prefix]

      [*prefix, text].join(': ')
    end

    def hint
      text = options[:hint]
      return if text.blank?

      content_tag(:div) do
        content_tag(:small, text.html_safe, class: 'text-muted')
      end
    end

    # Value from resource
    def value
      options[:value] || builder.value(name)
    end

  end
end
