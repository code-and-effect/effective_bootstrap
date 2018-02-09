module Effective
  module FormInputs
    module TextField

      def text_field(name, options = {})
        form_group_builder(name, options) { super }
      end

    end
  end
end
