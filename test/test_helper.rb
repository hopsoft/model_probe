# frozen_string_literal: true

require "minitest/autorun"

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require "pry"

require "model_probe"

# Test support files
require_relative "support/dummy_models"
