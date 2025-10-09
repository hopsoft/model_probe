# frozen_string_literal: true

require_relative "../../test_helper"

module ModelProbe
  module Probes
    class SqliteTest < Minitest::Test
      def setup
        @model = DummyUser
      end

      def test_probe_outputs_metadata
        assert_output(/DummyUser/) { @model.probe }
        assert_output(/Database engine/) { @model.probe }
        assert_output(/SQLite/) { @model.probe }
      end

      def test_probe_outputs_columns
        assert_output(/Columns/) { @model.probe }
        assert_output(/name/) { @model.probe }
        assert_output(/email/) { @model.probe }
      end

      def test_probe_outputs_indexes
        assert_output(/Indexes/) { @model.probe }
        assert_output(/index_dummy_users_on_email/) { @model.probe }
      end

      def test_generates_fixture
        fixture = @model.generate_fixture
        assert_includes fixture, "user_fixture:"
        assert_includes fixture, "email: string"
        assert_includes fixture, "name: string"
      end

      def test_outputs_fixture_to_stdout
        assert_output(/user_fixture/) { @model.print_fixture }
      end
    end
  end
end
