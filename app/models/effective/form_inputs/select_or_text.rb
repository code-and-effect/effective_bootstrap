module Effective
  module FormInputs
    class SelectOrText < Effective::FormInput
      attr_accessor :name_text
      attr_accessor :select_collection
      attr_accessor :select_options
      attr_accessor :text_options

      VISIBLE = {}
      HIDDEN = { wrapper: { style: 'display: none;' } }

      def initialize(name, options, builder:)
        @name_text = options.delete(:name_text) || raise('Please include a text method name')
        @select_collection = options.delete(:collection) || raise('Please include a collection')

        @select_options = { placeholder: 'Please choose, or...', required: false }
          .merge(options[:select] || options.presence || {})

        @text_options = { placeholder: 'Enter freeform', required: false }
          .merge(options[:text] || options[:text_field] || options.presence || {})

        @email_field = options.fetch(:email, name_text.to_s.include?('email'))

        super
      end

      def to_html(&block)
        content_tag(:div, class: 'effective-select-or-text') do
          if select?
            @builder.send(email_field? ? :email_field : :text_field, name_text, text_options) +
            @builder.select(name, select_collection, select_options)
          else
            @builder.select(name, select_collection, select_options) +
            @builder.send(email_field? ? :email_field : :text_field, name_text, text_options)
          end +
          link_to(icon('rotate-ccw'), '#', class: 'effective-select-or-text-switch', title: 'Switch between choice and freeform', 'data-effective-select-or-text': true)
        end
      end

      def select?
        return true if object.errors[name].present?
        return false if object.errors[name_text].present?

        value = object.send(name)

        return true if (value.present? && select_collection.include?(value))
        return true if (value.to_i > 0 && select_collection.find { |obj| obj.respond_to?(:id) && obj.id == value.to_i })

        return true if value.blank? && object.send(name_text).blank?
      end

      def text?
        !select?
      end

      def email_field?
        @email_field
      end

      def select_options
        @select_options.merge(select? ? VISIBLE : HIDDEN)
      end

      def text_options
        @text_options.merge(text? ? VISIBLE : HIDDEN)
      end

    end
  end
end
