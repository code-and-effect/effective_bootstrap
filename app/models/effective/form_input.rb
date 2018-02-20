module Effective
  class FormInput
    attr_accessor :name, :options

    BLANK = ''.html_safe

    delegate :object, :label, to: :@builder
    delegate :capture, :content_tag, :link_to, :icon, to: :@template

    # So this takes in the options for an entire form group.
    def initialize(name, options, builder:, html_options: nil)
      @builder = builder
      @template = builder.template

      @name = name
      @options = extract_options!(options, html_options: html_options)
      apply_input_options!
    end

    def input_group_options
      { input_group: { class: 'input-group' }, prepend: false, append: false }
    end

    def input_html_options
      { class: 'form-control' }
    end

    def input_js_options
      {}
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

    def feedback_options
      case layout
      when :inline
        false
      else
        { valid: { class: 'valid-feedback' }, invalid: { class: 'invalid-feedback' } }
      end
    end

    def hint_options
      case layout
      when :inline
        { tag: :small, class: 'text-muted', id: "#{tag_id}_hint" }
      else
        { tag: :small, class: 'form-text text-muted', id: "#{tag_id}_hint" }
      end
    end

    def wrapper_options
      case layout
      when :horizontal
        { class: 'form-group row' }
      else
        { class: 'form-group' }
      end
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
        build_wrapper do
          (build_label.presence || content_tag(:div, '', class: 'col-sm-2')) +
          content_tag(:div, build_content(&block), class: 'col-sm-10')
        end
      else # Vertical
        build_wrapper { build_content(&block) }
      end.html_safe
    end

    def build_wrapper(&block)
      content_tag(:div, yield, options[:wrapper])
    end

    def build_content(&block)
      return build_input_group_content(&block) if input_group?

      if layout == :horizontal
        build_input(&block) + build_feedback + build_hint
      else
        build_label + build_input(&block) + build_feedback + build_hint
      end
    end

    def build_input_group_content(&block)
      if layout == :horizontal
        build_input_group { build_input(&block) } + build_hint
      else
        build_label + build_input_group { build_input(&block) } + build_hint
      end
    end

    def build_input_group(&block) # Includes input and feedback
      content_tag(:div, '', options[:input_group][:input_group]) do # Twice here, kind of weird.
        [
          (content_tag(:div, options[:input_group][:prepend], class: 'input-group-prepend') if options[:input_group][:prepend]),
          build_input(&block),
          (content_tag(:div, options[:input_group][:append], class: 'input-group-append') if options[:input_group][:append]),
          build_feedback
        ].compact.join.html_safe
      end
    end

    def build_label
      return BLANK if options[:label] == false
      return BLANK if name.kind_of?(NilClass)

      text = (options[:label].delete(:text) || (object.class.human_attribute_name(name) if object) || BLANK).html_safe

      if options[:input][:id]
        options[:label][:for] = options[:input][:id]
      end

      label(name, text, options[:label])
    end

    def build_input(&block)
      capture(&block)
    end

    def build_hint
      return BLANK unless options[:hint] && options[:hint][:text]

      tag = options[:hint].delete(:tag)
      text = options[:hint].delete(:text).html_safe

      content_tag(tag, text, options[:hint])
    end

    def build_feedback
      return BLANK if options[:feedback] == false

      invalid = object.errors[name].to_sentence.presence if object.respond_to?(:errors)
      invalid ||= options[:feedback][:invalid].delete(:text)
      invalid ||= [("can't be blank" if options[:input][:required]), ('must be valid' if validated?(name))].compact.join(' and ')
      invalid ||= 'is invalid'

      valid = options[:feedback][:valid].delete(:text) || "Look's good!"

      content_tag(:div, invalid, options[:feedback][:invalid]) +
      content_tag(:div, valid, options[:feedback][:valid])

      # Server side
      # if has_error?(name) && options[:feedback][:invalid]
      #   content_tag(:div, object.errors[name].to_sentence, options[:feedback][:invalid])
      # elsif options[:feedback][:valid]
      #   content_tag(:div, 'Looks good!', options[:feedback][:valid])
      # end
    end

    def has_error?(name = nil)
      return false unless object.respond_to?(:errors)
      name ? object.errors[name].present? : object.errors.present?
    end

    def required?(name)
      return false unless object && name

      obj = (object.class == Class) ? object : object.class
      return false unless obj.respond_to?(:validators_on)

      obj.validators_on(name).any? { |v| v.kind_of?(ActiveRecord::Validations::PresenceValidator) }
    end

    def validated?(name)
      return false unless object && name

      obj = (object.class == Class) ? object : object.class
      return false unless obj.respond_to?(:validators_on)

      obj.validators_on(name).any? { |v| !v.kind_of?(ActiveRecord::Validations::PresenceValidator) }
    end

    def input_group?
      (options[:input_group][:append] || options[:input_group][:prepend]).present?
    end

    # Used for passwords and to not apply server side feedback
    def reset_feedback?
      return @reset_feedback unless @reset_feedback.nil?
      @reset_feedback = options[:feedback].present? && (options[:feedback].delete(:reset) == true)
    end

    def value
      object.public_send(name) if object.respond_to?(name)
    end

    private

    # Here we split them into { wrapper: {}, label: {}, hint: {}, input: {} }
    # And make sure to keep any additional options on the input: {}
    def extract_options!(options, html_options: nil)
      options.symbolize_keys!
      html_options.symbolize_keys! if html_options

      # effective_bootstrap specific options
      layout = options.delete(:layout) # Symbol
      wrapper = options.delete(:wrapper) # Hash
      input_group = { append: options.delete(:append), prepend: options.delete(:prepend), input_group: options.delete(:input_group) }.compact

      feedback = options.delete(:feedback) # Hash
      label = options.delete(:label) # String or Hash
      hint = options.delete(:hint) # String or Hash

      input_html = options.delete(:input_html) || {} # Hash
      input_js = options.delete(:input_js) || {} # Hash

      # Every other option goes to input
      @options = input = (html_options || options)

      # Merge all the default objects, and intialize everything
      wrapper = merge_defaults!(wrapper, wrapper_options)
      input_group = merge_defaults!(input_group, input_group_options)
      feedback = merge_defaults!(feedback, feedback_options)

      label = merge_defaults!(label, label_options)
      hint = merge_defaults!(hint, hint_options)

      # Merge input_html: {}, defaults, and add all class: keys together
      input.merge!(input_html.except(:class))
      merge_defaults!(input, input_html_options.except(:class))
      input[:class] = [input[:class], input_html[:class], input_html_options[:class]].compact.join(' ')

      merge_defaults!(input_js, input_js_options)

      if input_js.present?
        merge_defaults!(input_js, input_js_options_method_name)
        input['data-input-js-options'] = JSON.generate(input_js)
      end

      { layout: layout, wrapper: wrapper, input_group: input_group, label: label, hint: hint, input: input, feedback: feedback }
    end

    def apply_input_options!
      # Server side validation
      if has_error?
        if has_error?(name)
          options[:input][:class] = [options[:input][:class], 'is-invalid'].compact.join(' ')
        elsif reset_feedback?
          # Nothing
        else
          options[:input][:class] = [options[:input][:class], 'is-valid'].compact.join(' ')
        end
      end

      if required?(name) && (options[:input].delete(:required) != false)
        options[:input][:required] = 'required'
      end

      if options[:input][:readonly]
        options[:input][:readonly] = 'readonly'
        options[:input][:class] = options[:input][:class].to_s.sub('form-control', 'form-control-plaintext')
      end

      if options[:hint] && options[:hint][:text] && options[:hint][:id]
        options[:input].reverse_merge!('aria-describedby': options[:hint][:id])
      end
    end

    def merge_defaults!(obj, defaults)
      defaults = {} if defaults.nil?

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

    def layout
      options[:layout] || @builder.layout
    end

    # https://github.com/rails/rails/blob/master/actionview/lib/action_view/helpers/tags/base.rb#L120
    # Not 100% sure best way to generate this
    def tag_id(index = nil)
      case
      when @builder.object_name.empty?
        sanitized_method_name.dup
      when index
        "#{sanitized_object_name}_#{index}_#{sanitized_method_name}"
      else
        "#{sanitized_object_name}_#{sanitized_method_name}"
      end
    end

    def sanitized_object_name
      @builder.object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    end

    def sanitized_method_name
      name.to_s.sub(/\?$/, "")
    end

    def input_js_options_method_name
      { method_name: "effective_#{self.class.name.split('::').last.underscore.chomp('_field')}" }
    end

  end
end
