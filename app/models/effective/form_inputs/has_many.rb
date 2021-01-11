module Effective
  module FormInputs
    class HasMany < Effective::FormInput

      def to_html(&block)
        content_tag(:div, options[:input]) do
          has_many_fields_for(block) + link_to_add(block)
        end
      end

      def input_html_options
        { class: 'form-has-many' }
      end

      private

      def has_many_fields_for(block)
        object.send(name).map { |resource| render_resource(resource, block) }.join.html_safe
      end

      def render_resource(resource, block)
        destroy = ''.html_safe

        fields = @builder.fields_for(name, resource) do |form|
          destroy = form.super_hidden_field(:_destroy) if resource.persisted?
          block.call(form)
        end

        content_tag(:div, class: 'has-many-fields') do
          fields + destroy + link_to_remove(resource)
        end
      end

      def render_template(block)
        resource = object.send(name).new
        index = object.send(name).index(resource)

        html = render_resource(resource, block)
        html.gsub!("#{name}_attributes][#{index}]", "#{name}_attributes][HASMANYINDEX]")
        html.gsub!("#{name}_attributes_#{index}_", "#{name}_attributes_HASMANYINDEX_")

        html.html_safe
      end

      def link_to_add(block)
        title = 'Add Another'

        button = content_tag(
          :button,
          icon('plus-circle') + title,
          href: '#',
          class: 'btn btn-secondary',
          title: title,
          data: {
            'effective-form-has-many-add': true,
            'effective-form-has-many-template': render_template(block)
          }
        )

        content_tag(:div, button, class: 'has-many-links')
      end

      def link_to_remove(resource)
        title = 'Remove'

        button = content_tag(
          :button,
          icon('trash-2') + title,
          href: '#',
          class: 'btn btn-danger',
          title: title,
          data: {
            'confirm': "Remove #{resource}?",
            'effective-form-has-many-remove': true,
          }
        )
      end
    end
  end
end
