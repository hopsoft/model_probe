# frozen_string_literal: true

require_relative "../../test_helper"

module ModelProbe
  module Probes
    module Indexes
      class LowerCaseIndexTest < Minitest::Test
        def setup
          DummyUser.connection.execute <<-SQL
            CREATE INDEX index_users_on_lower_address_city ON dummy_users (lower(address_city));
          SQL
        end

        def teardown
          DummyUser.connection.execute <<-SQL
            DROP INDEX IF EXISTS index_users_on_lower_address_city;
          SQL
        end

        def test_handles_lower_case_text_index
          assert_output(/index_users_on_lower_address_city/) { DummyUser.probe_indexes }
        end
      end
    end
  end
end
