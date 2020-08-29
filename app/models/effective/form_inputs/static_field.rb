module Effective
  module FormInputs
    class StaticField < Effective::FormInput

      def input_html_options
        { class: 'form-control-plaintext', readonly: false, id: tag_id }
      end

      def feedback_options
        false
      end

      def build_input(&block)
        content = if block_given?
          capture(&block)
        elsif resource_path
          link_to(value, resource_path, title: value.to_s)
        else
          value
        end

        content_tag(:p, content, options[:input].except(:readonly, :required).merge(id: tag_id))
      end

      def resource_path
        # I don't want to hardcode effective_resources as a dependency of this gem. But it's so useful...
        return false unless defined?(EffectiveResources)

        return false unless value.kind_of?(ActiveRecord::Base)

        @_resource_path ||= (
          Effective::Resource.new(value, namespace: @template.controller_path.split('/').first).action_path(:edit) ||
          Effective::Resource.new(@template.controller_path).action_path(:edit, value) ||
          Effective::Resource.new(value, namespace: @template.controller_path.split('/').first).action_path(:show) ||
          Effective::Resource.new(@template.controller_path).action_path(:show, value)
        )
      end

    end
  end
end
