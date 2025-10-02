require_relative "../../test_helper"

module ModelProbe
  module Probes
    module Metadata
      class ModelProbeTest < Minitest::Test
        def setup
          # Reset memoized var between test runs to avoid flaky tests
          DummyUser.instance_variable_set(:@ddl, nil)
        end

        def test_rescues_from_a_command_error
          database = DummyUser.connection_db_config.database

          DummyUser.connection.stub(:adapter_name, "PostgreSQL") do
            actual = DummyUser.ddl
            assert_match(/The database #{database} does not exist/, actual)
          end
        end

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
