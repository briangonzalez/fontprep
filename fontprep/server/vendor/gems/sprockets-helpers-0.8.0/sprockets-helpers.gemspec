# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'sprockets/helpers/version'

Gem::Specification.new do |s|
  s.name        = 'sprockets-helpers'
  s.version     = Sprockets::Helpers::VERSION
  s.authors     = ['Pete Browne']
  s.email       = ['me@petebrowne.com']
  s.homepage    = 'https://github.com/petebrowne/sprockets-helpers'
  s.summary     = 'Asset path helpers for Sprockets 2.x applications'
  s.description = 'Asset path helpers for Sprockets 2.x applications'

  s.rubyforge_project = 'sprockets-helpers'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split('\n').map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency             'sprockets',      '~> 2.0'
  s.add_development_dependency 'appraisal',      '~> 0.4'
  s.add_development_dependency 'rspec',          '~> 2.6'
  s.add_development_dependency 'test-construct', '~> 1.2'
  s.add_development_dependency 'rake'
end
