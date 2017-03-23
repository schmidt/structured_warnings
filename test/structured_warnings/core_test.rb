require 'test_helper'

class StructuredWarnings::CoreTest < Test::Unit::TestCase
  def test_warning_is_a_module
    assert_equal Module, Warning.class
  end

  def test_warning_has_warn_instance_method
    assert_equal [:warn], Warning.instance_methods(false)
  end
end
