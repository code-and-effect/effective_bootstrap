module Effective
  class FormLogic
    attr_accessor :args, :options

    delegate :object, to: :@builder
    delegate :capture, :content_tag, :link_to, :icon, to: :@template

    # So this takes in the options for an entire form group.
    def initialize(*args, builder:)
      @builder = builder
      @template = builder.template
      @options ||= {}

      validate!(args)
      @args = args
    end

    def validate!(args)
      raise 'expected one or more argument' if args.blank?
    end

    # https://github.com/rails/rails/blob/master/actionview/lib/action_view/helpers/tags/base.rb#L108
    def tag_name(name, multiple = false, index = nil)
      sanitized_method_name = name.to_s.sub(/\?$/, "")

      case
      when @builder.object_name.empty?
        "#{sanitized_method_name}#{multiple ? "[]" : ""}"
      when index
        "#{@builder.object_name}[#{index}][#{sanitized_method_name}]#{multiple ? "[]" : ""}"
      else
        "#{@builder.object_name}[#{sanitized_method_name}]#{multiple ? "[]" : ""}"
      end
    end

    def input_js_options
      { 'data-input-js-options' => JSON.generate({method_name: input_js_options_method_name}.merge!(logic_options)) }
    end

    def input_js_options_method_name
      "effective_#{self.class.name.split('::').last.underscore}"
    end

  end
end
