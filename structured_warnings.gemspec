lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'structured_warnings/version'

Gem::Specification.new do |spec|
  spec.name          = 'structured_warnings'
  spec.version       = StructuredWarnings::VERSION
  spec.authors       = ['Gregor Schmidt']
  spec.email         = ['schmidt@nach-vorne.eu']


  spec.summary       = 'Provides structured warnings for Ruby, using an exception-like interface and hierarchy'
  spec.description   = "This is an implementation of Daniel Berger's proposal of structured warnings for Ruby."
  spec.homepage      = 'http://github.com/schmidt/structured_warnings'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z -- README.md lib`.split("\x0")

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
