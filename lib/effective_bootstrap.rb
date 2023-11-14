require 'inline_svg'
require 'effective_resources'
require 'effective_bootstrap/engine'
require 'effective_bootstrap/version'

module EffectiveBootstrap

  def self.config_keys
    [:use_custom_data_confirm, :save_tabs, :benchmarks]
  end

  include EffectiveGem

  def self.boolean_collection
    [['Yes', true], ['No', false]]
  end

end
