require 'test/unit'
require 'structured_warnings'

class Foo
  def old_method
    warn DeprecatedMethodWarning,
         'This method is deprecated. Use new_method instead'
  end
end

class Bar
  attr_reader :args

  def warn(*args)
    @args = args
  end

  def method_using_incompatible_warn_api
    warn :deprecated, 'explanation'
  end
end

class StructuredWarningsTest < Test::Unit::TestCase
  def test_fork_in_thread
    Thread.new do
      fork do
        begin
          DeprecatedMethodWarning.disable do
            Foo.new.old_method
          end
        rescue
          puts "\n#{$!.class.name}: #{$!.message}"
          puts $!.backtrace.join("\n")
          exit 1
        end
      end
    end.join
    Process.wait
    assert($?.success?, 'Forked subprocess failed')
  end

  def test_warn
    assert_warn(DeprecatedMethodWarning) do
      Foo.new.old_method
    end
  end

  def test_warn_using_incompatible_warn_api
    bar = Bar.new

    assert_no_warn do
      bar.method_using_incompatible_warn_api
    end

    assert_equal :deprecated,   bar.args.first
    assert_equal "explanation", bar.args.last
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

  def test_passing_an_additional_message_to_assert_no_warn
    assert_no_warn(Warning, "with message") do
      warn Warning, "with another message"
    end
  end

  def test_passing_an_additional_message_to_assert_warn
    assert_warn(Warning, "with message") do
      warn Warning, "with message"
    end
  end

  def test_passing_a_warning_instance_to_assert_warn
    assert_warn(Warning.new("with message")) do
      warn Warning, "with message"
    end
  end

  def test_passing_a_warning_instance_to_assert_no_warn
    assert_no_warn(Warning.new("with message")) do
      warn DeprecationWarning, "with another message"
    end
    assert_no_warn(Warning.new) do
      warn Warning, "with message"
    end
  end

  def test_passing_a_regexp_as_message_to_assert_warn
    assert_warn(Warning, /message/) do
      warn DeprecationWarning, "with another message"
    end
  end

  def test_passing_a_regexp_as_message_to_no_assert_warn
    assert_no_warn(Warning, /message/) do
      warn DeprecationWarning
    end
  end

  def test_passing_a_message_only_to_assert_warn
    assert_warn("I told you so") do
      warn "I told you so"
    end
  end

  def test_warnings_may_not_be_disabled_twice
    assert_equal [Warning], Warning.disable
    assert_equal [Warning], Warning.disable
    assert_equal [], Warning.enable
  end
end
