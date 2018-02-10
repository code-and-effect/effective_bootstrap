module Effective
  class FormInput
    attr_accessor :name, :options

    delegate :object, :layout, :label, to: :@builder
    delegate :capture, :content_tag, :link_to, to: :@template

    # So this takes in the options for an entire form group.
    def initialize(name, options, builder:, html_options: nil)
      @builder = builder
      @template = builder.template

      @name = name
      @options = extract_options!(options, html_options)
    end

    def wrapper_options
      case layout
      when :horizontal
        { class: 'form-group row' }
      when :inline
        false
      else
        { class: 'form-group' }
      end
    end

    def label_options
      case layout
      when :horizontal
        { class: 'col-sm-2 col-form-label'}
      when :inline
        { class: 'sr-only' }
      else
        { }
      end
    end

    def label_position
      :before
    end

    def hint_options
      { tag: :small, class: 'form-text text-muted' }
    end

    def input_html_options
      { class: 'form-control' }
    end

    def input_js_options
      {}
    end

    def to_html(&block)
      wrap(&block)
    end

    protected

    def wrap(&block)
      case layout
      when :inline
        build_content(&block)
      when :horizontal
        build_wrapper { build_label + content_tag(:div, build_content(&block), class: 'col-sm-10') }
      else # Vertical
        build_wrapper { build_content(&block) }
      end.html_safe
    end

    def build_wrapper(&block)
      content_tag(:div, yield, options[:wrapper])
    end

    def build_content(&block)
      if layout == :horizontal
        build_input(&block) + build_hint + build_feedback
      elsif label_position == :before
        build_label + build_input(&block) + build_hint + build_feedback
      else
        build_input(&block) + build_label + build_hint + build_feedback
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
      if has_error?
        options[:input][:class] = [options[:input][:class], (has_error?(name) ? 'is-invalid' : 'is-valid')].compact.join(' ')
      end

      if is_required?(name)
        options[:input].reverse_merge!(required: 'required')
      end

      capture(&block)
    end

    def build_hint
      return '' unless options[:hint] && options[:hint][:text]

      tag = options[:hint].delete(:tag)
      text = options[:hint].delete(:text).html_safe

      content_tag(tag, text, options[:hint])
    end

    def build_feedback
      return '' unless has_error?
      return '' if layout == :inline

      if has_error?(name)
        content_tag(:div, object.errors[name].to_sentence, class: 'invalid-feedback')
      else
        content_tag(:div, 'Looks good!', class: 'valid-feedback')
      end
    end

    def has_error?(name = nil)
      return false unless object.respond_to?(:errors)
      name ? object.errors[name].present? : object.errors.present?
    end

    def is_required?(name)
      return false unless object && name

      target = (object.class == Class) ? object : object.class
      return false unless target.respond_to?(:validators_on)

      target.validators_on(name).any? { |v| v.kind_of?(ActiveRecord::Validations::PresenceValidator) }
    end

    private

    # Here we split them into { layout: :vertical, wrapper: {}, label: {}, hint: {}, input: {} }
    # And make sure to keep any additional options on the input: {}
    def extract_options!(options, html_options = nil)
      options.symbolize_keys!
      html_options.symbolize_keys! if html_options

      # effective_bootstrap specific options
      wrapper = options.delete(:wrapper) # Hash
      label = options.delete(:label) # String or Hash
      hint = options.delete(:hint) # String or Hash
      input_html = options.delete(:input_html) || {} # Hash
      input_js = options.delete(:input_js) || {} # Hash

      # Every other option goes to input
      @options = input = (html_options || options)

      # Merge all the default objects, and intialize everything
      wrapper = merge_defaults!(wrapper, wrapper_options)
      label = merge_defaults!(label, label_options)
      hint = merge_defaults!(hint, hint_options)

      # Merge input_html: {}, defaults, and add all class: keys together
      input.merge!(input_html.except(:class))
      merge_defaults!(input, input_html_options.except(:class))
      input[:class] = [input[:class], input_html[:class], input_html_options[:class]].compact.join(' ')

      merge_defaults!(input_js, input_js_options)
      input['data-input-js-options'] = JSON.generate(input_js) if input_js.present?

      { wrapper: wrapper, label: label, hint: hint, input: input }
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
