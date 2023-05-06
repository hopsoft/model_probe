# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "model_probe/version"

Gem::Specification.new do |gem|
  gem.name = "model_probe"
  gem.version = ModelProbe::VERSION
  gem.authors = ["Nathan Hopkins"]
  gem.email = ["natehop@gmail.com"]
  gem.summary = "Schema introspection for ActiveModel"
  gem.homepage = "http://hopsoft.github.com/model_probe/"

  gem.files = Dir["lib/**/*rb", "lib/tasks/*rake", "[A-Z]*"]

  gem.add_development_dependency "magic_frozen_string_literal"
  gem.add_development_dependency "standardrb"
end
