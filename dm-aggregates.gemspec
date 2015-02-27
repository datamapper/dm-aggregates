# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dm-aggregates/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = [ 'Emmanuel Gomez' ]
  gem.email         = [ "emmanuel.gomez@gmail.com" ]
  gem.summary       = "DataMapper plugin providing support for aggregates on collections"
  gem.description   = gem.summary
  gem.homepage      = "http://datamapper.org"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.rdoc]

  gem.name          = "dm-aggregates"
  gem.require_paths = [ "lib" ]
  gem.version       = DataMapper::Aggregates::VERSION

  gem.add_runtime_dependency('dm-core', '~> 1.2')

  gem.add_development_dependency('rake',  '~> 10.0')
  gem.add_development_dependency('rspec', '~> 3.0')
end
