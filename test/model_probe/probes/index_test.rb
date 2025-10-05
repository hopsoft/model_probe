# frozen_string_literal: true

require_relative "../../test_helper"

module ModelProbe
  module Probes
    module Indexes
      class LowerCaseIndexTest < Minitest::Test
        def test_index_listed_in_output
          assert_output(/index_dummy_users_on_email/) { DummyUser.probe_indexes }
        end

        def test_index_columns_in_output
          assert_output(/[email]/) { DummyUser.probe_indexes }
        end
      end
    end
  end
end
