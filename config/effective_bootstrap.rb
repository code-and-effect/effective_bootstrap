EffectiveBootstrap.setup do |config|
  # Replaces rails_ujs data-confirm with a custom inline implementation.
  # You will need to recompile assets (or "rm -rf tmp/") if you change this.
  config.use_custom_data_confirm = true

  # Adds a before_action to ApplicationController
  # To save and restore the active bootstrap tabs
  config.save_tabs = true

  # Adds benchmark stats to each of the = tab helpers
  config.benchmarks = false
end
