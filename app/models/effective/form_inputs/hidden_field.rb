module Effective
  module FormInputs
    class HiddenField < Effective::FormInput

      def to_html(&block)
        @builder.super_hidden_field(name, options[:input].except(:class, :required))
      end

    end
  end
end
