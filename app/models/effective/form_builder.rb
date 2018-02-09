module Effective
  class FormBuilder < ActionView::Helpers::FormBuilder

    LAYOUTS = [:vertical, :horizontal, :inline]

    include Effective::FormInputs::TextField

    attr_reader :layout

    delegate :content_tag, :capture, :concat, to: :@template

    def initialize(object_name, object, template, options)
      @layout = options[:layout] || LAYOUTS.first
      super
    end

    def form_group(*args, &block)
      options = args.extract_options!
      name = args.first

      (options[:wrapper] ||= {})[:class] = ['form-group', options[:wrapper][:class]].compact.join(' ')

      content_tag(:div, options[:wrapper]) do
        "#{build_label(name,options)}#{build_input(name,options,&block)}#{build_hint(name,options)}".html_safe
      end
    end

    protected

    # = f.text_field :title, hint: 'booyah', class: 'yes', placeholder: "okay", data: { 'something' => 'okay', 'another' => 'yep' }, female: 'yes', label: { female: 'yes'}

    def form_group_builder(name, options, html_options = nil)
      options.symbolize_keys!
      html_options.symbolize_keys! if html_options

      # effective_bootstrap specific options
      layout = options.delete(:layout) # Symbol
      wrapper = options.delete(:wrapper) # Hash
      label = options.delete(:label) # String or Hash
      hint = options.delete(:hint) # String or Hash
      input_html = options.delete(:input_html) # Hash
      input_js = options.delete(:input_js) # Hash

      # Every other option goes to input
      input = html_options || options

      # Merge in any custom input_html and initialize input_js
      input.merge!(input_html) if input_html
      #input.merge!(input_js) if input_js TODO

      form_group_options = { layout: layout, wrapper: wrapper, label: label, input: input, hint: hint }

      form_group(name, form_group_options) { yield }
    end

    private

    def build_label(name, options)
      case options[:label]
      when false
        return nil
      when nil, true
        text = nil
        opts = { }
      when String
        text = options[:label]
        opts = { }
      when Hash
        text = options[:label][:text]
        opts = options[:label].except(:text)
      end

      text ||= object.class.human_attribute_name(name)
      opts[:for] = options[:id] if options[:id]

      label(name, text, opts)
    end

    def build_input(name, options, &block)
      options[:input][:class] = ['form-control', options[:input][:class], ('is-invalid' if has_error?(name))].compact.join(' ')

      capture(&block)
    end

    def build_hint(name, options)
      case options[:hint]
      when false, nil
        return nil
      when String
        text = options[:hint]
        opts = { }
      when Hash
        text = options[:hint][:text]
        opts = options[:hint].except(:text)
      end

      opts[:class] ||= 'form-text text-muted'

      content_tag(:small, text, opts)
    end

    def has_error?(name)
      object.respond_to?(:errors) && !(name.nil? || object.errors[name].empty?)
    end

    def is_required?(obj, attribute)
      return false unless obj and attribute

      target = (obj.class == Class) ? obj : obj.class

      validators = Array((target.validators_on(attribute).map(&:class) if target.respond_to?(:validators_on)))

      validators.include?(ActiveModel::Validations::PresenceValidator)
    end


  end
end
