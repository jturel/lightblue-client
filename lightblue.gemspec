# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lightblue/version'

Gem::Specification.new do |spec|
  spec.name          = 'lightblue'
  spec.version       = Lightblue::VERSION
  spec.authors       = ['Jonathon Turel', 'Davis Wahl']
  spec.summary       = 'Ruby client for the lightblue platform'
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.9.1'
  spec.add_runtime_dependency 'json-schema'
  spec.add_runtime_dependency 'diffy'
  spec.add_runtime_dependency 'ast'

  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'minitest', '~> 5.4'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-yard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'guard-rubocop'
end
