require 'test_helper'

class StructuredWarnings::KernelTest < Test::Unit::TestCase
  def test_warn_delegates_to_warning_warn
    called = false

    Warning.stub :warn, -> (*) { called = true } do
      warn ''
    end

    assert_equal true, called
  end
end
