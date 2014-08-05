# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cartone/version'

Gem::Specification.new do |spec|
  spec.name          = "cartone"
  spec.version       = Cartone::VERSION
  spec.authors       = ["encrypt"]
  spec.email         = ["encrypt94@gmail.com"]
  spec.summary       = %q{I need a home}
  spec.description   = %q{I _really_ need a home}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*']
  spec.executables   = ['cartone-crawler']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6.2.1"
  spec.add_dependency "chronic", "~> 0.10.2"
  spec.add_dependency 'elasticsearch', '~> 1.0.4'
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
