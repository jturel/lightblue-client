# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'lightblue/version'


Gem::Specification.new do |spec|
  spec.name          = 'lightblue'
  spec.version       = Lightblue::VERSION
  spec.email         = ['jturel@redhat.com', 'dwahl@redhat.com']
  spec.authors       = ['Jonathon Turel', 'Davis Wahl']
  spec.summary       = %q{Ruby client for the lightblue platform}
  spec.description   = %q{See summary}
  spec.homepage      = 'http://lightblue.io'
  spec.license       = 'MIT'
  spec.files         = Dir.glob("{lib}/**/*") + %w(LICENSE.txt README.md)
  #`git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']


  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rspec', '~> 3.3', '>= 3.3.0'
  spec.add_development_dependency 'pry', '~> 0.10.1'

  spec.add_development_dependency 'rake', '~> 10.0'
end
