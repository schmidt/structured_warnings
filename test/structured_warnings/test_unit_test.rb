require 'test_helper'

class StructuredWarnings::TestUnitTest < Test::Unit::TestCase
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
