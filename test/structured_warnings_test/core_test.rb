require 'test_helper'

class StructuredWarningsTest::CoreTest < Minitest::Test
  def test_warning_is_a_module
    assert_equal Module, Warning.class
  end

  def test_warning_has_warn_instance_method
    assert_equal [:warn], Warning.instance_methods(false)
  end

  def test_warn_delegates_to_warning_warn
    called = false

    Warning.stub :warn, -> (*) { called = true } do
      warn ''
    end

    assert_equal true, called
  end
end
