# frozen_string_literal: true

module EffectiveTableBuilderHelper

  def effective_table_with(resource, options = {}, &block)
    raise('expected resource to respond to attributes') unless resource.respond_to?(:attributes)

    begin
      @_effective_table_builder = Effective::TableBuilder.new(resource, self, options)
      @_effective_table_builder.render(&block)
    ensure
      @_effective_table_builder = nil
    end

  end
end
