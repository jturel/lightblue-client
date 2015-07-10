# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lightblue/client'

Gem::Specification.new do |spec|
  spec.name          = 'lightblue-client'
  spec.version       = Lightblue::Client::VERSION
  spec.authors       = ['Jonathon Turel']
  spec.summary       = %q{Ruby client for the lightblue platform}
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.9.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'

  spec.add_development_dependency 'rake', '~> 10.0'
end
