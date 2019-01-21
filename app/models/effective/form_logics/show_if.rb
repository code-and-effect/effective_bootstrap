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
        { name: tag_name(args.first), value: args.second.to_s }
      end

      def validate!(args)
        raise 'expected two arguments' unless args.length == 2
        raise "expected object to respond to #{args.first}" unless object.respond_to?(args.first)
      end

      def show?
        (object.send(args.first) == args.second) || (object.send(args.first).to_s == args.second.to_s)
      end

    end
  end
end
