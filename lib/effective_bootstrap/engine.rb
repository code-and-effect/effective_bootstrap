module EffectiveBootstrap
  class Engine < ::Rails::Engine
    engine_name 'effective_bootstrap'

    # Set up our default configuration options.
    initializer 'effective_bootstrap.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_bootstrap.rb")
    end

    initializer 'effective_bootstrap.assets' do |app|
      app.config.assets.precompile += [
        'effective_bootstrap_manifest.js',
        'effective_bootstrap_article_editor.css',
        'icons/*'
      ]
    end

    initializer 'effective_bootstrap.action_text' do |app|
      if defined?(ActionText)
        ActionText::ContentHelper.allowed_attributes << 'style'
      end
    end

    # Adds a before_action to application controller
    initializer 'effective_bootstrap.action_controller' do |app|
      if EffectiveBootstrap.save_tabs
        app.config.to_prepare do
          ApplicationController.send(:include, EffectiveBootstrap::SaveTabs)
        end
      end
    end

  end
end
