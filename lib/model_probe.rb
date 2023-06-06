# frozen_string_literal: true

require "erb"
require "rainbow"
require_relative "model_probe/version"
require_relative "model_probe/railtie" if defined?(Rails)
require_relative "model_probe/probes"

module ModelProbe
  include Probes

  # Prints a stub that can be used for a test fixture
  def print_fixture
    template = erb_template("model_probe/templates/fixture.yml.erb")
    puts template.result_with_hash(name: name, fixture_columns: fixture_columns)
    nil
  end

  # Prints a new model definition based on the database schema
  def print_model
    template = erb_template("model_probe/templates/model.rb.erb")
    puts template.result_with_hash(
      name: name,
      superclass_name: superclass.name,
      primary_key_columns: primary_key_columns,
      foreign_key_columns: foreign_key_columns,
      relation_columns: relation_columns,
      required_columns: required_columns,
      limit_columns: limit_columns,
      validation_columns: validation_columns
    )
    nil
  end

  private

  def erb_template(relative_path)
    template_path = File.expand_path(relative_path, __dir__)
    template_text = File.read(template_path)
    # trim_mode doesn't seem to work regardless of how it's passed with Ruby 2.7.5
    ERB.new template_text, trim_mode: "-"
  end
end
