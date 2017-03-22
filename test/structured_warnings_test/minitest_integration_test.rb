require 'test_helper'

class StructuredWarningsTest::MinitestIntegrationTest < Minitest::Test
  def test_assert_warn
    assert_warn(StructuredWarnings::Base, 'message') do
      warn 'message'
    end
  end

  def test_assert_no_warn
    assert_no_warn(StructuredWarnings::DeprecationWarning) do
      warn 'message'
    end
  end
end
