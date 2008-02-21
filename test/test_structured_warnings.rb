require File.dirname(__FILE__) + '/test_helper.rb'

class Foo
  def old_method
    warn DeprecatedMethodWarning, 
         'This method is deprecated. Use new_method instead'
  end
end

class TestStructuredWarnings < Test::Unit::TestCase
  def test_warn
    assert_warn(DeprecatedMethodWarning) do 
      Foo.new.old_method
    end
  end

  def test_disable_warning_blockwise
    assert_no_warn(DeprecatedMethodWarning) do
      DeprecatedMethodWarning.disable do
        Foo.new.old_method
      end
    end
  end

  def test_disable_warning_globally
    assert_no_warn(DeprecatedMethodWarning) do
      DeprecatedMethodWarning.disable
      Foo.new.old_method
      DeprecatedMethodWarning.enable
    end
  end

  def test_last_but_not_least
    assert_warn(DeprecatedMethodWarning) do
      DeprecatedMethodWarning.disable do
        DeprecatedMethodWarning.enable do
          Foo.new.old_method
        end
      end
    end
  end

  def test_warnings_have_an_inheritance_relation
    assert_no_warn(DeprecatedMethodWarning) do
      DeprecationWarning.disable do
        Foo.new.old_method
      end
    end
    assert_warn(DeprecationWarning) do
      Foo.new.old_method
    end
  end

  def test_warn_writes_to_stderr
    require "stringio"
    old_stderr = $stderr
    $stderr = io = ::StringIO.new
    Foo.new.old_method
    $stderr = old_stderr
    io.rewind
    assert io.length > 0
  end

  def test_warning_is_default_warning
    assert_warn(Warning) do
      warn "my warning"
    end
  end

  def test_passing_a_warning_instance_works_as_well
    assert_warn(Warning) do
      warn Warning.new("my warning")
    end
  end

  def test_passing_anything_but_a_subclass_or_instance_of_warning_will_work
    assert_warn(Warning) do
      warn nil
    end
  end

  def test_warnings_may_not_be_disabled_twice
    assert [Warning], Warning.disable
    assert [Warning], Warning.disable
    assert [], Warning.enable
  end
end
