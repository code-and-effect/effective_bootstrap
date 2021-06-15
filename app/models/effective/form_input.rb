# frozen_string_literal: true

module Effective
  class FormInput
    attr_accessor :name, :options

    BLANK = ''.html_safe
    EMPTY_HASH = {}

    EXCLUSIVE_CLASS_PREFIXES = [] # None
    EXCLUSIVE_CLASS_SUFFIXES = ['-primary', '-secondary', '-success', '-danger', '-warning', '-info', '-light', '-dark', '-link']

    DEFAULT_INPUT_GROUP_OPTIONS = { input_group: { class: 'input-group' }, prepend: false, append: false }

    HORIZONTAL_LABEL_OPTIONS = { class: 'col-sm-2 col-form-label'}
    INLINE_LABEL_OPTIONS = { class: 'sr-only' }

    DEFAULT_FEEDBACK_OPTIONS = { valid: { class: 'valid-feedback' }, invalid: { class: 'invalid-feedback' } }

    HORIZONTAL_WRAPPER_OPTIONS = { class: 'form-group row' }
    VERTICAL_WRAPPER_OPTIONS = { class: 'form-group' }

    delegate :object, to: :@builder
    delegate :capture, :content_tag, :image_tag, :link_to, :icon, :asset_path, to: :@template

    # So this takes in the options for an entire form group.
    def initialize(name, options, builder:, html_options: nil)
      @builder = builder
      @template = builder.template

      @name = name
      @options = extract_options!(options, html_options: html_options)
      apply_input_options!
    end

    def input_group_options
      DEFAULT_INPUT_GROUP_OPTIONS
    end

    def input_html_options
      { class: 'form-control', id: tag_id }
    end

    def input_js_options
      EMPTY_HASH
    end

    def label_options
      case layout
      when :horizontal
        HORIZONTAL_LABEL_OPTIONS
      when :inline
        INLINE_LABEL_OPTIONS
      else
        EMPTY_HASH
      end
    end

    def feedback_options
      case layout
      when :inline
        false
      else
        DEFAULT_FEEDBACK_OPTIONS
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
        HORIZONTAL_WRAPPER_OPTIONS
      else
        VERTICAL_WRAPPER_OPTIONS
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
          (options[:input_group][:prepend] if options[:input_group][:prepend]),
          build_input(&block),
          (options[:input_group][:append] if options[:input_group][:append]),
          build_feedback
        ].compact.join.html_safe
      end
    end

    def build_label
      return BLANK if options[:label] == false
      return BLANK if name.kind_of?(NilClass)

      text = options[:label].delete(:text)
      name_to_s = name.to_s

      text ||= (
        if object && name_to_s.ends_with?('_id')
          object.class.human_attribute_name(name_to_s.chomp('_id'))
        elsif object && name_to_s.ends_with?('_ids')
          object.class.human_attribute_name(name_to_s.chomp('_ids').pluralize)
        elsif object
          object.class.human_attribute_name(name)
        else
          BLANK
        end
      )

      if options[:input][:id]
        options[:label][:for] = options[:input][:id]
      end

      @builder.label(name, text.html_safe, options[:label])
    end

    def build_input(&block)
      capture(&block)
    end

    def build_hint
      return BLANK unless options[:hint] && options[:hint][:text]

      tag = options[:hint].delete(:tag)
      text = options[:hint].delete(:text)

      content_tag(tag, text.html_safe, options[:hint])
    end

    def build_feedback
      return BLANK if options[:feedback] == false

      invalid = object.errors[name].to_sentence.presence if object.respond_to?(:errors)
      invalid ||= options[:feedback][:invalid].delete(:text).presence
      invalid ||= [("Can't be blank" if options[:input][:required]), ('must be valid' if validated?(name))].tap(&:compact!).join(' and ').presence
      invalid ||= "Can't be blank or is invalid"

      content_tag(:div, invalid.html_safe, options[:feedback][:invalid])
    end

    def has_error?(name = nil)
      return false unless object.respond_to?(:errors)

      if name
        object.errors[name].present? || (parent_object && parent_object.errors[name].present?)
      else
        object.errors.present? || parent_object&.errors&.present?
      end
    end

    def required?(name)
      return false unless object && name

      obj = (object.class == Class) ? object : object.class
      return false unless obj.respond_to?(:validators_on)

      if name.to_s.ends_with?('_id')
        return required_presence?(obj, name) || required_presence?(obj, name[0...-3])
      end

      required_presence?(obj, name)
    end

    def required_presence?(obj, name)
      obj.validators_on(name).any? do |v|
        (
          v.kind_of?(ActiveRecord::Validations::PresenceValidator) ||
          v.kind_of?(ActiveModel::Validations::AcceptanceValidator)
        ) && required_options?(v.options)
      end
    end

    def required_options?(opts)
      return true unless (opts.key?(:if) || opts.key?(:unless))

      if opts[:if].respond_to?(:call)
        return object.instance_exec(&opts[:if])
      end

      if opts[:if].kind_of?(Symbol)
        return object.send(opts[:if])
      end

      if opts.key?(:if)
        return opts[:if]
      end

      if opts[:unless].respond_to?(:call)
        return !object.instance_exec(&opts[:unless])
      end

      if opts[:unless].kind_of?(Symbol)
        return !object.send(opts[:unless])
      end

      if opts.key?(:unless)
        return !opts[:unless]
      end

      false
    end

    def validated?(name)
      return false unless object && name

      obj = (object.class == Class) ? object : object.class
      return false unless obj.respond_to?(:validators_on)

      obj.validators_on(name).any? do |v|
        !(v.kind_of?(ActiveRecord::Validations::PresenceValidator) || v.kind_of?(ActiveModel::Validations::AcceptanceValidator))
      end
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
      @_value ||= (options.delete(:value) || options[:input]&.delete(:value))
      @_value ||= (object.public_send(name) if object.respond_to?(name))
    end

    def unique_id(item = nil)
      if item && item.respond_to?(value_method)
        item_value = (item.send(value_method).to_s.parameterize.presence rescue nil)
      end

      [tag_id, item_value, object_id].tap(&:compact!).join('_')
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
      input_group = { append: options.delete(:append), prepend: options.delete(:prepend), input_group: options.delete(:input_group) }.tap(&:compact!)

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

      merge_defaults!(input.merge!(input_html), input_html_options)
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
          options[:input][:class] = (options[:input][:class] ? "#{options[:input][:class]} is-invalid" : 'is-invalid')
        elsif reset_feedback?
          # Nothing
        else
          options[:input][:class] = (options[:input][:class] ? "#{options[:input][:class]} is-valid" : 'is-valid')
        end
      end

      if required?(name) && (options[:input].delete(:required) != false)
        options[:input][:required] = 'required'
      end

      if readonly?
        options[:input][:readonly] = 'readonly'

        unless options[:input][:class].to_s.include?('form-control-plaintext')
          options[:input][:class] = (options[:input][:class] || '').sub('form-control', 'form-control-plaintext')
        end
      end

      if disabled?
        options[:input][:disabled] = 'disabled'
      end

      if options[:hint] && options[:hint][:text] && options[:hint][:id]
        options[:input].reverse_merge!('aria-describedby': options[:hint][:id])
      end
    end

    def merge_defaults!(obj, defaults)
      defaults = EMPTY_HASH if defaults.nil?

      case obj
      when false
        false
      when nil, true
        defaults.dup
      when String
        defaults.merge(text: obj)
      when Hash
        html_classes = ((obj[:class] || '').split(' ') + (defaults[:class] || '').split(' ')).uniq

        # Try to smart merge bootstrap classes
        if (exclusive = html_classes.select { |c| c.include?('-') }).length > 1
          EXCLUSIVE_CLASS_PREFIXES.each do |prefix|
            prefixed = exclusive.select { |c| c.start_with?(prefix) }
            prefixed[1..-1].each { |c| html_classes.delete(c) } if prefixed.length > 1
          end

          suffixed = exclusive.select { |c| EXCLUSIVE_CLASS_SUFFIXES.any? { |suffix| c.end_with?(suffix) } }
          suffixed[1..-1].each { |c| html_classes.delete(c) } if suffixed.length > 1
        end

        obj[:class] = html_classes.join(' ') if html_classes.present?
        obj.reverse_merge!(defaults)
        obj
      else
        defaults.merge(text: obj.to_s)
      end
    end

    def layout
      options[:layout] || @builder.layout
    end

    def form_readonly?
      @builder.readonly
    end

    def readonly?
      options.dig(:input, :readonly).present? || form_readonly?
    end

    def disabled?
      options.dig(:input, :disabled).present? || form_disabled?
    end

    def form_disabled?
      @builder.disabled
    end

    def form_remote?
      @builder.remote
    end

    def parent_object
      @builder.options[:parent_builder]&.object
    end

    # https://github.com/rails/rails/blob/master/actionview/lib/action_view/helpers/tags/base.rb#L120
    def tag_id(index = nil)
      id = case
      when @builder.object_name.empty?
        sanitized_method_name.dup
      when index
        "#{sanitized_object_name}_#{index}_#{sanitized_method_name}"
      else
        "#{sanitized_object_name}_#{sanitized_method_name}"
      end.downcase.parameterize

      @builder.options[:unique_ids] ? "#{id}_#{@builder.options[:unique_id]}" : id
    end

    def sanitized_object_name
      @sanitized_object_name ||= @builder.object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    end

    def sanitized_method_name
      @sanitized_method_name ||= name.to_s.sub(/\?$/, "")
    end

    def input_js_options_method_name
      { method_name: "effective_#{self.class.name.split('::').last.underscore.chomp('_field')}" }
    end

  end
end
