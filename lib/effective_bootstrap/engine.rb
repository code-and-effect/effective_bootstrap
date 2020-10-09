module EffectiveBootstrap
  class Engine < ::Rails::Engine
    engine_name 'effective_bootstrap'

    # Set up our default configuration options.
    initializer 'effective_bootstrap.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_bootstrap.rb")
    end

    initializer 'effective_bootstrap.assets' do |app|
      app.config.assets.precompile += ['effective_bootstrap_manifest.js', 'icons/*']
    end

  end
end
