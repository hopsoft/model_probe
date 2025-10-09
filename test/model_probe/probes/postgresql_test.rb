# frozen_string_literal: true

require_relative "../../test_helper"

if defined?(DummyUserPostgres)
  module ModelProbe
    module Probes
      class PostgresqlTest < Minitest::Test
        def setup
          @model = DummyUserPostgres
        end

        def test_probe_outputs_metadata
          assert_output(/DummyUserPostgres/) { @model.probe }
          assert_output(/Database engine/) { @model.probe }
          assert_output(/PostgreSQL/) { @model.probe }
        end

        def test_probe_outputs_ddl
          assert_output(/DDL/) { @model.probe }
          assert_output(/CREATE TABLE/i) { @model.probe }
          assert_output(/character varying/i) { @model.probe } # PostgreSQL-specific type
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
          assert_includes fixture, "user_postgres_fixture:"
          assert_includes fixture, "email: string"
          assert_includes fixture, "name: string"
        end
      end
    end
  end
end
