module Effective
  module FormLogics
    class HideIf < Effective::FormLogic

      def to_html(&block)
        content_tag(:div, options.merge(input_js_options), &block)
      end

      def options
        { style: ('display: none;' if hide?) }
      end

      def logic_options
        { name: tag_name(args.first), value: args.second }
      end

      def validate!(args)
        raise 'expected two arguments' unless args.length == 2
        raise "expected object to respond to #{args.first}" unless object.respond_to?(args.first)
      end

      def hide?
        object.send(args.first) == args.second
      end

    end
  end
end
