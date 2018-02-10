module Effective
  class FormInput
    attr_accessor :name, :options

    delegate :object, :label, to: :@builder
    delegate :capture, :content_tag, :link_to, to: :@template

    # So this takes in the options for an entire form group.
    def initialize(name, options, builder:, html_options: nil)
      @builder = builder
      @template = builder.template

      @name = name
      @options = extract_options!(options, html_options)
    end

    def wrapper_options
      { class: 'form-group'}
    end

    def label_options
      { }  # Before or after input in the markup
    end

    def label_position
      :before
    end

    def hint_options
      { class: 'form-text text-muted' }
    end

    def input_html_options
      { class: 'form-control' }
    end

    def input_js_options
      {}
    end

    def to_html(&block)
      form_group(&block)
    end

    protected

    def form_group(&block)
      content_tag(:div, options[:wrapper]) do
        label = build_label
        input = build_input(&block)
        hint = build_hint

        if label_position == :before
          (label + input + hint).html_safe
        else
          (input + label + hint).html_safe
        end

      end
    end

    def build_label
      return '' if options[:label] == false

      text = (options[:label].delete(:text) || object.class.human_attribute_name(name)).html_safe

      if options[:input][:id]
        options[:label][:for] = options[:input][:id]
      end

      label(name, text, options[:label])
    end

    def build_input(&block)
      if has_error?(name)
        options[:input][:class] = [options[:input][:class], 'is-invalid'].compact.join(' ')
      end

      capture(&block)
    end

    def build_hint
      return '' unless options[:hint] && options[:hint][:text]

      text = options[:hint].delete(:text).html_safe

      content_tag(:small, text, options[:hint])
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

    private

    # Here we split them into { layout: :vertical, wrapper: {}, label: {}, hint: {}, input: {} }
    # And make sure to keep any additional options on the input: {}
    def extract_options!(options, html_options = nil)
      options.symbolize_keys!
      html_options.symbolize_keys! if html_options

      # effective_bootstrap specific options
      layout = options.delete(:layout) # Symbol
      wrapper = options.delete(:wrapper) # Hash
      label = options.delete(:label) # String or Hash
      hint = options.delete(:hint) # String or Hash
      input_html = options.delete(:input_html) || {} # Hash
      input_js = options.delete(:input_js) || {} # Hash

      # Every other option goes to input
      @options = input = (html_options || options)

      # Merge all the default objects, and intialize everything
      layout ||= :vertical
      wrapper = merge_defaults!(wrapper, wrapper_options)
      label = merge_defaults!(label, label_options)
      hint = merge_defaults!(hint, hint_options)

      # Merge input_html: {}, defaults, and add all class: keys together
      input.merge!(input_html.except(:class))
      merge_defaults!(input, input_html_options.except(:class))
      input[:class] = [input[:class], input_html[:class], input_html_options[:class]].compact.join(' ')

      merge_defaults!(input_js, input_js_options)
      input['data-input-js-options'] = JSON.generate(input_js) if input_js.present?

      { layout: layout, wrapper: wrapper, label: label, hint: hint, input: input }
    end

    def merge_defaults!(obj, defaults)
      defaults ||= {}

      case obj
      when false
        false
      when nil, true
        defaults
      when String
        defaults.merge(text: obj)
      when Hash
        obj.reverse_merge!(defaults)
      else
        raise 'unexpected object'
      end
    end

  end
end
