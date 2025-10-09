# frozen_string_literal: true

require_relative "../../test_helper"

if defined?(DummyUserMysql)
  module ModelProbe
    module Probes
      class MysqlTest < Minitest::Test
        def setup
          @model = DummyUserMysql
        end

        def test_probe_outputs_metadata
          assert_output(/DummyUserMysql/) { @model.probe }
          assert_output(/Database engine/) { @model.probe }
          assert_output(/Mysql2/) { @model.probe }
        end

        def test_probe_outputs_ddl
          assert_output(/DDL/) { @model.probe }
          assert_output(/CREATE TABLE/i) { @model.probe }
          assert_output(/varchar/i) { @model.probe } # MySQL-specific type format
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
          assert_includes fixture, "user_mysql_fixture:"
          assert_includes fixture, "email: string"
          assert_includes fixture, "name: string"
        end
      end
    end
  end
end
