EffectiveBootstrap.setup do |config|
  # Replaces rails_ujs data-confirm with a custom inline implementation.
  # You will need to recompile assets (or "rm -rf tmp/") if you change this.
  config.use_custom_data_confirm = true
end
