# frozen_string_literal: true

module Effective
  module TableRows
    class ArticleEditor < Effective::TableRow

      def content
        return unless value.present?

        value_to_s = value.to_s

        if value_to_s.include?('</')
          value_to_s.html_safe
        else
          template.simple_format(value_to_s)
        end
      end

      # Humanized label or the label from form
      def label
        text = options[:label] || EffectiveResources.et(builder.object, name).sub(/^Rich text /, '').capitalize
        prefix = builder.options[:prefix]

        [*prefix, text].join(': ')
      end

    end
  end
end
