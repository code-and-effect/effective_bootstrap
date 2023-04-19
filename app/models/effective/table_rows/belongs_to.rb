# frozen_string_literal: true

module Effective
  module TableRows
    class BelongsTo < Effective::TableRow

      def content
        if value.present?
          content_tag(:div) { link_to_edit || link_to_show || value.to_s }
        end
      end

      private

      def effective_resource
        @effective_resource ||= Effective::Resource.new(value, namespace: controller_namespace)
      end

      def link_to_edit
        return unless EffectiveResources.authorized?(template, :edit, value)

        path = effective_resource.action_path(:edit, value)
        return unless path.present?

        link_to(value.to_s, path, title: value.to_s, target: '_blank')
      end

      def link_to_show
        return unless EffectiveResources.authorized?(template, :show, value)

        path = effective_resource.action_path(:show, value)
        return unless path.present?

        link_to(value.to_s, path, title: value.to_s, target: '_blank')
      end

    end
  end
end
