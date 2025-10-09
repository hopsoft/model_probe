# frozen_string_literal: true

require_relative "test_helper"

module ModelProbe
  class ModelProbeTest < Minitest::Test
    def test_generates_a_fixture
      fixture = DummyUser.generate_fixture
      assert_includes fixture, "user_fixture:"
      assert_includes fixture, "email: string"
      assert_includes fixture, "name: string"
    end

    def test_outputs_fixture_to_stdout
      assert_output(/user_fixture/) { DummyUser.print_fixture }
    end
  end
end