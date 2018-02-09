module EffectiveBootstrap
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Creates an EffectiveBootstrap initializer in your application.'

      source_root File.expand_path('../../templates', __FILE__)

      def copy_initializer
        template ('../' * 3) + 'config/effective_bootstrap.rb', 'config/initializers/effective_bootstrap.rb'
      end

    end
  end
end
