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

    # Intended for override
    def content
      value
    end

    # Render method
    def to_html(&block)
      content_tag(:tr) do
        content_tag(:td, label) + content_tag(:td, content)
      end
    end

    # Humanized label or the label from form
    def label
      text = options[:label] || builder.human_attribute_name(name)
      prefix = builder.options[:prefix]

      [*prefix, text].join(': ')
    end

    # Value from resource
    def value
      options[:value] || builder.value(name)
    end

  end
end
