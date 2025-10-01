require_relative "test_helper"

module ModelProbe
  class ModelProbeTest < Minitest::Test
    def test_ultimate_question_is_known
      answer = 42
      assert_equal 42, answer

      skip "TODO: Replace this with real tests"
      question = nil
      refute_nil question, "Expected to know the Ultimate Question but it's still missing!"
    end
  end
end
