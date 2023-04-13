# frozen_string_literal: true

module Effective
  class TableBuilder

    attr_accessor :object, :template, :options

    # A Hash of :first_name => "<tr><td>First Name</td><td>Bob</td></tr>"
    attr_accessor :rows
    attr_accessor :content_fors

    delegate :content_tag, to: :template

    def initialize(object, template, options = {}, &block)
      raise('resource must be an ActiveRecord::Base') unless object.is_a?(ActiveRecord::Base)

      @object = object
      @template = template
      @options = options

      @rows = {}
      @content_fors = {}
    end

    def render(&block)
      # This runs the form partial over this table builder
      capture(&block) if block_given?

      # Build from the resource if we didn't do anything in the block
      build_resource_rows if rows.blank?

      only = Array(options[:only])
      except = Array(options[:except])

      content = rows.merge(content_fors)
      content = content.slice(*only) if only.present?
      content = content.except(*except) if except.present?

      content_tag(:table, class: options.fetch(:class, 'table table-striped table-hover')) do
        content_tag(:tbody, content.values.join.html_safe)
      end
    end

    def capture(&block)
      template.capture(self, &block)
    end

    def build_resource_rows
      Effective::Resource.new(object).attributes.each do |name, options|
        case options.first
        when :boolean then boolean_row(name)
        when :text then text_area(name)
        else default_row(name)
        end
      end
    end

    def human_attribute_name(name)
      if object.respond_to?(:human_attribute_name)
        object.human_attribute_name(name)
      else
        (name.to_s.split('.').last.to_s.titleize || '')
      end
    end

    def value(name)
      object.send(name)
    end

    # Call default_row for any form field
    def method_missing(method, *args, **kwargs, &block)
      default_row(args[0], **kwargs, &block)
    end

    # Assign the <tr><td>...</td></tr> to the @rows Hash
    def default_row(name, options = {}, &block)
      rows[name] = TableRow.new(name, options, builder: self).to_html
    end

    def boolean_row(name, options = {})
      rows[name] = TableRows::Boolean.new(name, options, builder: self).to_html
    end
    alias_method :check_box, :boolean_row

    def collection_row(name, collection, options = {}, &block)
      rows[name] = TableRows::Collection.new(name, collection, options, builder: self).to_html
    end
    alias_method :select, :collection_row
    alias_method :checks, :collection_row
    alias_method :radios, :collection_row

    def email_field(name, options = {})
      rows[name] = TableRows::EmailField.new(name, options, builder: self).to_html
    end
    alias_method :email_cc_field, :email_field

    def file_field(name, options = {})
      rows[name] = TableRows::FileField.new(name, options, builder: self).to_html
    end

    def form_group(name = nil, options = {}, &block)
      # Nothing to do
    end

    def hidden_field(name = nil, options = {})
      # Nothing to do
    end

    def search_field(name, options = {})
      # Nothing to do
    end

    def password_field(name, options = {})
      # Nothing to do
    end

    def percent_field(name, options = {})
      rows[name] = TableRows::PercentField.new(name, options, builder: self).to_html
    end

    def price_field(name, options = {})
      rows[name] = TableRows::PriceField.new(name, options, builder: self).to_html
    end

    def save(name, options = {})
      # Nothing to do
    end

    def submit(name, options = {}, &block)
      # Nothing to do
    end

    def text_area(name, options = {})
      rows[name] = TableRows::TextArea.new(name, options, builder: self).to_html
    end

    def url_field(name, options = {})
      rows[name] = TableRows::UrlField.new(name, options, builder: self).to_html
    end

    def content_for(name, options = {}, &block)
      content_fors[name] = TableRows::ContentFor.new(name, options, builder: self).to_html(&block)
    end

    # Logics
    def hide_if(name, selected, &block)
      template.capture(self, &block) unless value(name) == selected
    end

    def show_if(name, selected, &block)
      template.capture(self, &block) if value(name) == selected
    end

    def show_if_any(name, options, &block)
      template.capture(self, &block) if Array(options).include?(value(name))
    end

    # Has Many
    def has_many(name, collection = nil, options = {}, &block)
      raise('unsupported')
    end

  end
end
