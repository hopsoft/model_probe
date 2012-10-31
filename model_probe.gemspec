# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_probe/version'

Gem::Specification.new do |gem|
  gem.name          = "model_probe"
  gem.version       = ModelProbe::VERSION
  gem.authors       = ["Nathan Hopkins"]
  gem.email         = ["natehop@gmail.com"]
  gem.description   = "Provides a detailed view of the underlying schema that backs an ActiveModel."
  gem.summary       = "Schema introspection for ActiveModel."
  gem.homepage      = "http://hopsoft.github.com/model_probe/"

  gem.files         = `git ls-files`.split($/)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  # gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
