module Effective
  module FormLogics
    class ShowIf < Effective::FormLogic

      def to_html(&block)
        content_tag(:div, options.merge(input_js_options), &block)
      end

      def options
        { style: ('display: none;' unless show?) }
      end

      def logic_options
        { name: tag_name(args.first), value: args.second }
      end

      def validate!(args)
        raise 'expected two arguments' unless args.length == 2
        raise "expected object to respond to #{args.first}" unless object.respond_to?(args.first)
      end

      def show?
        object.send(args.first) == args.second
      end

    end
  end
end
