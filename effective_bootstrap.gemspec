$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'effective_bootstrap/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'effective_bootstrap'
  s.version     = EffectiveBootstrap::VERSION
  s.email       = ['info@codeandeffect.com']
  s.authors     = ['Code and Effect']
  s.homepage    = 'https://github.com/code-and-effect/effective_bootstrap'
  s.summary     = 'Everything you need to get set up with bootstrap 4.'
  s.description = 'Everything you need to get set up with bootstrap 4.'
  s.licenses    = ['MIT']

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'README.md']

  s.add_dependency 'rails', '>= 4.0.0'
  s.add_dependency 'bootstrap', '>= 4.0.0'
  s.add_dependency 'inline_svg'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'sass-rails'
end
