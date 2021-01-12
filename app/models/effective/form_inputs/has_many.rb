module Effective
  module FormInputs
    class HasMany < Effective::FormInput
      BLANK = ''.html_safe

      def to_html(&block)
        content_tag(:div, options[:input]) do
          has_many_fields_for(block) + has_many_links_for(block)
        end
      end

      def input_html_options
        { class: 'form-has-many mb-4' }
      end

      def input_js_options
        { sortable: true }
      end

      def collection
        Array(options[:input][:collection] || object.send(name))
      end

      # cards: true
      def display
        @display ||= (options[:input].delete(:cards) ? :cards : :rows)
      end

      # add: false
      def add?
        return @add unless @add.nil?

        @add ||= begin
          add = options[:input].delete(:add)
          add.nil? ? true : add
        end
      end

      # remove: false
      def remove?
        return @remove unless @remove.nil?

        @remove ||= begin
          remove = options[:input].delete(:remove)

          if remove != nil
            remove
          else
            opts = (object.class.nested_attributes_options[name] || {})
            opts[:update_only] != true && opts[:allow_destroy] != false
          end
        end
      end

      # reorder: true
      def reorder?
        return @reorder unless @reorder.nil?

        @reorder ||= begin
          reorder = options[:input].delete(:reorder)

          if reorder != nil
            reorder
          else
            build_resource().class.columns_hash['position']&.type == :integer
          end
        end
      end

      private

      def has_many_fields_for(block)
        collection.map { |resource| render_resource(resource, block) }.join.html_safe
      end

      def has_many_links_for(block)
        return BLANK unless add? || reorder?

        content_tag(:div, class: 'has-many-links text-center mt-2') do
          [(link_to_add(block) if add?), (link_to_reorder(block) if reorder?)].compact.join(' ').html_safe
        end
      end

      def render_resource(resource, block)
        remove = BLANK

        content = @builder.fields_for(name, resource) do |form|
          fields = block.call(form)

          remove += form.super_hidden_field(:_destroy) if remove? && resource.persisted?
          remove += form.super_hidden_field(:position) if reorder? && !fields.include?('][position]')

          fields
        end

        remove += link_to_remove(resource) if remove?

        content_tag(:div, render_fields(content, remove), class: 'has-many-fields')
      end

      def render_fields(content, remove)
        case display
        when :rows
          content_tag(:div, class: 'form-row') do
            (reorder? ? content_tag(:div, has_many_move, class: 'col-auto') : BLANK) +
            content_tag(:div, content, class: 'col mr-auto') +
            content_tag(:div, remove, class: 'col-auto')
          end
        when :cards
          raise('unsupported')
        else
          content + remove
        end
      end

      def render_template(block)
        resource = build_resource()
        index = object.send(name).index(resource)

        html = render_resource(resource, block)
        html.gsub!("#{name}_attributes][#{index}]", "#{name}_attributes][HASMANYINDEX]")
        html.gsub!("#{name}_attributes_#{index}_", "#{name}_attributes_HASMANYINDEX_")

        html.html_safe
      end

      def link_to_add(block)
        content_tag(
          :button,
          icon('plus-circle') + 'Add Another',
          class: 'has-many-add btn btn-secondary',
          title: 'Add Another',
          data: {
            'effective-form-has-many-add': true,
            'effective-form-has-many-template': render_template(block)
          }
        )
      end

      def link_to_reorder(block)
        content_tag(
          :button,
          icon('list') + 'Reorder',
          class: 'has-many-reorder btn btn-secondary',
          title: 'Reorder',
          data: {
            'effective-form-has-many-reorder': true,
          }
        )
      end

      def link_to_remove(resource)
        content_tag(
          :button,
          icon('trash-2') + 'Remove',
          class: 'has-many-remove btn btn-danger',
          title: 'Remove',
          data: {
            'confirm': "Remove #{resource}?",
            'effective-form-has-many-remove': true,
          }
        )
      end

      def has_many_move
        @has_many_move ||= content_tag(:span, icon('move'), class: 'has-many-move')
      end

      def build_resource
        @build_resource ||= object.send(name).build().tap { |resource| object.send(name).delete(resource) }
      end

    end
  end
end
