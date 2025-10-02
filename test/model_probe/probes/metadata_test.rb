# frozen_string_literal: true

require_relative "../../test_helper"

module ModelProbe
  module Probes
    module Metadata
      class DDLTest < Minitest::Test
        def setup
          # Reset memoized var between test runs to avoid flaky tests
          DummyUser.instance_variable_set(:@ddl, nil)
        end

        def test_return_a_friendly_message_when_database_does_not_exist
          database = DummyUser.connection_db_config.database

          DummyUser.connection.stub(:adapter_name, "PostgreSQL") do
            actual = DummyUser.ddl
            assert_equal("The database #{database} does not exist", actual)
          end
        end

        def test_return_a_friendly_message_when_command_is_not_found
          custom_error_msg = "The command returned non-zero exit status:"
          subshell_error_msg = "sh: 1: pg_dump: command not found"

          DummyUser.connection.stub(:adapter_name, "PostgreSQL") do
            DummyUser.stub(:run_command, ->(*) { raise "#{custom_error_msg} #{subshell_error_msg}" }) do
              actual = DummyUser.ddl
              assert_equal("The binary was not found in the $PATH", actual)
            end
          end
        end
      end

      class RunCommandTest < Minitest::Test
        def test_returns_the_command_output
          actual = DummyUser.run_command("echo", "hello")
          assert_equal("hello\n", actual)
        end

        def test_raises_a_runtime_error_when_command_does_not_found
          assert_raises(RuntimeError) { DummyUser.run_command("fake_cmd", nil) }
        end

        def test_returns_a_custom_error_message_with_command_error
          custom_error_msg = "The command returned non-zero exit status:"

          error = assert_raises(RuntimeError) { DummyUser.run_command("fake_cmd", nil) }
          assert_match(/^#{custom_error_msg}.*?not found/, error.message)
        end
      end
    end
  end
end
