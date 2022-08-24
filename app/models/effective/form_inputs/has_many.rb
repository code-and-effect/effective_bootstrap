# frozen_string_literal: true

module Effective
  module FormInputs
    class HasMany < Effective::FormInput
      BLANK = ''.html_safe

      def to_html(&block)
        object.send(name).build() if build? && collection.blank?

        errors = (@builder.error(name) if errors?) || BLANK
        can_remove_method

        errors + content_tag(:div, options[:input].except(:collection)) do
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

      # cards: false
      def display
        @display ||= (options[:input].delete(:cards) ? :cards : :rows)
      end

      # build: true
      def build?
        return @build unless @build.nil?

        @build ||= begin
          build = options[:input].delete(:build)
          build.nil? ? true : build
        end
      end

      # add: true
      def add?
        return @add unless @add.nil?

        @add ||= begin
          add = options[:input].delete(:add)
          add.nil? ? true : add
        end
      end

      # insert: false
      def insert
        return @insert unless @insert.nil?

        @insert ||= begin
          insert = options[:input].delete(:insert)
          insert.nil? ? false : insert
        end
      end

      def insert?
        !!insert
      end

      # errors: true
      def errors?
        return @errors unless @errors.nil?

        @errors ||= begin
          errors = options[:input].delete(:errors)
          errors.nil? ? true : errors
        end
      end

      # remove: true
      def remove
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

      def remove?
        !!remove
      end

      def can_remove_method
        return @can_remove_method unless @can_remove_method.nil?
        @can_remove_method = (options[:input].delete(:can_remove_method) || false)
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

        content_tag(:div, class: 'has-many-links mt-2') do
          [*(link_to_add(block) if add?), *(link_to_reorder(block) if reorder?)].join(' ').html_safe
        end
      end

      def render_resource(resource, block)
        remove = BLANK
        reorder = BLANK
        insert = BLANK
        can_remove = (can_remove_method.blank? || !!resource.send(can_remove_method))

        content = @builder.fields_for(name, resource) do |form|
          fields = block.call(form)

          remove += form.super_hidden_field(:_destroy) if remove? && can_remove && resource.persisted?
          reorder += form.super_hidden_field(:position) if reorder? && !fields.include?('][position]')

          fields
        end

        if remove?
          remove += (can_remove || resource.new_record?) ? link_to_remove(resource) : disabled_link_to_remove(resource)
        end

        if insert?
          insert = render_insert() if add? && reorder?
        end

        content_tag(:div, insert + render_fields(content, remove + reorder), class: 'has-many-fields')
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
          content_tag(:div, class: 'form-row mb-3') do
            (reorder? ? content_tag(:div, has_many_move, class: 'col-auto') : BLANK) +
            content_tag(:div, content, class: 'col mr-auto') do
              content_tag(:div, class: 'card') do
                content_tag(:div, class: 'card-body') do
                  content_tag(:div, remove, class: 'd-flex justify-content-end') + content
                end
              end
            end
          end
        else
          content + remove
        end
      end

      def render_insert()
        content_tag(:div, link_to_insert(), class: 'has-many-actions')
      end

      def render_template(block)
        resource = build_resource()
        index = collection.length

        html = render_resource(resource, block)

        unless html.include?("#{name}_attributes][#{index}]")
          raise('unexpected index. unable to render resource template.')
        end

        html.gsub!("#{name}_attributes][#{index}]", "#{name}_attributes][HASMANYINDEX]")
        html.gsub!("#{name}_attributes_#{index}_", "#{name}_attributes_HASMANYINDEX_")

        Base64.encode64(html)
      end

      def link_to_add(block)
        content_tag(
          :button,
          icon('plus-circle') + 'Add Another',
          class: 'has-many-add btn btn-sm btn-secondary',
          title: 'Add Another',
          data: {
            'effective-form-has-many-add': true,
            'effective-form-has-many-template': render_template(block)
          }
        )
      end

      # f.has_many :things, insert: { label: (icon('plus-circle') + 'Insert Article') }
      # f.has_many :things, insert: (icon('plus-circle') + 'Insert Article')
      def link_to_insert
        tag = (insert[:tag] if insert.kind_of?(Hash))
        title = (insert[:title] || insert[:label] if insert.kind_of?(Hash))
        html_class = (insert[:class] if insert.kind_of?(Hash))

        label = (insert[:label] if insert.kind_of?(Hash))
        label = insert if insert.kind_of?(String)

        content_tag(
          (tag || :button),
          (label || (icon('plus-circle') + 'Insert Another')),
          class: 'has-many-insert ' + (html_class || 'btn btn-sm btn-secondary'),
          title: (title || 'Insert Another'),
          data: {
            'effective-form-has-many-insert': true,
          }
        )
      end

      def link_to_reorder(block)
        content_tag(
          :button,
          icon('reorder') + 'Reorder',
          class: 'has-many-reorder btn btn-secondary',
          title: 'Reorder',
          data: {
            'effective-form-has-many-reorder': true,
          }
        )
      end

      def link_to_remove(resource)
        tag = (remove[:tag] if remove.kind_of?(Hash))
        title = (remove[:title] || remove[:label] if remove.kind_of?(Hash))
        html_class = (remove[:class] if remove.kind_of?(Hash))

        label = (remove[:label] if remove.kind_of?(Hash))
        label = remove if remove.kind_of?(String)

        content_tag(
          (tag || :button),
          (label || (icon('trash-2') + 'Remove')),
          class: 'has-many-remove ' + (html_class || 'btn btn-sm btn-danger'),
          title: (title || 'Remove'),
          data: {
            'confirm': "Remove #{resource}?",
            'effective-form-has-many-remove': true,
          }
        )
      end

      def disabled_link_to_remove(resource)
        content_tag(
          :button,
          icon('trash-2'),
          class: 'has-many-remove-disabled btn btn-sm btn-danger',
          title: 'Remove',
          data: {
            'effective-form-has-many-remove-disabled': true,
          }
        )
      end

      def has_many_move
        @has_many_move ||= content_tag(:span, icon('grip-lines'), class: 'has-many-move')
      end

      def build_resource
        # Using .new() here seems like it should work but it doesn't. It changes the index
        @build_resource ||= object.send(name).build().tap do |resource|
          object.send(name).delete(resource)
        end
      end

    end
  end
end
