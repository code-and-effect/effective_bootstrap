# frozen_string_literal: true

module EffectiveTableBuilderHelper

  def effective_table_with(resource, options = {}, &block)
    builder = Effective::TableBuilder.new(resource, self, options)
    builder.render(&block)
  end

end
