module Effective
  module FormInputs
    class NumberField < Effective::FormInput
      # This has gotta be a valid pattern
      def validated?(name)
        true
      end
    end
  end
end
