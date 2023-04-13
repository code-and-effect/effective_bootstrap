# frozen_string_literal: true

module EffectiveTableBuilderHelper

  def effective_table_with(resource, options = {}, &block)
    raise('expected resource to respond to attributes') unless resource.respond_to?(:attributes)
    Effective::TableBuilder.new(resource, self, options, &block).render
  end

end
