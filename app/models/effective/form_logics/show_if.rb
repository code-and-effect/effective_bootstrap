# frozen_string_literal: true

module Effective
  module FormLogics
    class ShowIf < Effective::FormLogic

      def to_html(&block)
        disabled_was = @builder.disabled

        @builder.disabled = true unless show?

        content = content_tag(:div, options.merge(input_js_options), &block)

        @builder.disabled = disabled_was

        content
      end

      def options
        { style: ('display: none;' unless show?) }
      end

      def logic_options
        { name: tag_name(args.first), value: args.second.to_s, needDisable: !show? }.merge(input_logic_options)
      end

      def input_logic_options
        args.third.kind_of?(Hash) ? args.third : {}
      end

      def validate!(args)
        return if args.third.kind_of?(Hash) && args.third[:validate] == false
        raise "expected object to respond to #{args.first}" unless object.respond_to?(args.first)
      end

      def show?
        (object.try(args.first) == args.second) || (object.try(args.first).to_s == args.second.to_s)
      end

    end
  end
end
