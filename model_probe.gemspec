# frozen_string_literal: true

require "model_probe/version"

Gem::Specification.new do |s|
  s.name = "model_probe"
  s.version = ModelProbe::VERSION
  s.authors = ["Nathan Hopkins"]
  s.email = ["natehop@gmail.com"]
  s.summary = "ActiveRecord schema visualization and model organization made easy"
  s.homepage = "http://hopsoft.github.com/model_probe/"

  s.files = Dir["lib/**/*rb", "lib/tasks/*rake", "[A-Z]*"]

  s.add_development_dependency "magic_frozen_string_literal"
  s.add_development_dependency "standardrb"
end
