# frozen_string_literal: true

module Effective
  class TableBuilder
    FILTER_PARAMETERS = [:password, :password_confirmation, :status_steps, :wizard_steps, :token, :created_at, :updated_at]

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
      build_resource_rows if rows.blank? && !block_given?

      only = Array(options[:only])
      except = Array(options[:except])
      filtered = filter_parameters

      content = rows.merge(content_fors)
      content = content.slice(*only) if only.present?
      content = content.except(*except) if except.present?
      content = content.except(*filtered) if filtered.present?

      content_tag(:table, class: options.fetch(:class, 'table table-striped table-hover')) do
        content_tag(:tbody, content.values.join.html_safe)
      end
    end

    def capture(&block)
      begin
        template.instance_variable_set(:@_effective_table_builder, self)
        template.capture(self, &block)
      ensure
        template.instance_variable_set(:@_effective_table_builder, nil)
      end
    end

    def build_resource_rows
      Effective::Resource.new(object).resource_attributes.each do |name, options|
        case options.first
        when :belongs_to
          belongs_to(name)
        when :effective_address
          effective_address(name)
        when :boolean
          boolean_row(name)
        when :integer
          name.to_s.end_with?('price') ? price_field(name) : text_field(name)
        when :string
          name.to_s.include?('email') ? email_field(name) : text_field(name)
        when :text
          text_area(name)
        else default_row(name)
        end
      end
    end

    def filter_parameters
      FILTER_PARAMETERS + Array(object.class.try(:filter_parameters)) + Array(Rails.application.config.filter_parameters)
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
      rows[name] = if [true, false].include?(value(name))
        TableRows::Boolean.new(name, options, builder: self).to_html
      else
        TableRows::Collection.new(name, collection, options, builder: self).to_html
      end
    end
    alias_method :select, :collection_row
    alias_method :checks, :collection_row
    alias_method :radios, :collection_row

    def belongs_to(name, options = {})
      rows[name] = TableRows::BelongsTo.new(name, options, builder: self).to_html
    end

    def date_field(name, options = {})
      rows[name] = TableRows::DateField.new(name, options, builder: self).to_html
    end

    def datetime_field(name, options = {})
      rows[name] = TableRows::DatetimeField.new(name, options, builder: self).to_html
    end

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

    def effective_address(name, options = {})
      rows[name] = TableRows::EffectiveAddress.new(name, options, builder: self).to_html
    end

    def percent_field(name, options = {})
      rows[name] = TableRows::PercentField.new(name, options, builder: self).to_html
    end

    def tel_field(name, options = {})
      rows[name] = TableRows::PhoneField.new(name, options, builder: self).to_html
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

    def static_field(name, options = {}, &block)
      rows[name] = (value(name).is_a?(ActiveRecord::Base)) ? belongs_to(name, options) : default_row(name, options)
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
      value(name).each_with_index do |object, index|
        builder = TableBuilder.new(object, template, options.merge(prefix: human_attribute_name(name).singularize + " ##{index+1}"))
        builder.render(&block)
        builder.rows.each { |child, content| rows["#{name}_#{child}_#{index}".to_sym] = content }
      end
    end

    def fields_for(name, object, options = {}, &block)
      builder = TableBuilder.new(object, template, options.merge(prefix: human_attribute_name(name)))
      builder.render(&block)
      builder.rows.each { |child, content| rows["#{name}_#{child}".to_sym] = content }
    end
    alias_method :effective_fields_for, :fields_for

  end
end
