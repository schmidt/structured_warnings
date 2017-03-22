require 'test_helper'

class StructuredWarningsTest < Test::Unit::TestCase
  class Foo
    def method_using_structured_warning_style_api
      warn StructuredWarnings::DeprecatedMethodWarning,
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

  def test_fork_in_thread
    return unless supports_fork

    Thread.new do
      fork do
        begin
          StructuredWarnings::DeprecatedMethodWarning.disable do
            Foo.new.method_using_structured_warning_style_api
          end
        rescue
          puts
          puts $!
          puts $@
          exit 1
        end
      end
    end.join

    Process.wait

    assert($?.success?, 'Forked subprocess failed')
  end

  def test_warn_using_structured_warning_style_api
    assert_warn(StructuredWarnings::DeprecatedMethodWarning) do
      Foo.new.method_using_structured_warning_style_api
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
    assert_no_warn(StructuredWarnings::DeprecatedMethodWarning) do
      StructuredWarnings::DeprecatedMethodWarning.disable do
        Foo.new.method_using_structured_warning_style_api
      end
    end
  end

  def test_disable_warning_globally
    assert_no_warn(StructuredWarnings::DeprecatedMethodWarning) do
      StructuredWarnings::DeprecatedMethodWarning.disable
      Foo.new.method_using_structured_warning_style_api
      StructuredWarnings::DeprecatedMethodWarning.enable
    end
  end

  def test_last_but_not_least
    assert_warn(StructuredWarnings::DeprecatedMethodWarning) do
      StructuredWarnings::DeprecatedMethodWarning.disable do
        StructuredWarnings::DeprecatedMethodWarning.enable do
          Foo.new.method_using_structured_warning_style_api
        end
      end
    end
  end

  def test_warnings_have_an_inheritance_relation
    assert_no_warn(StructuredWarnings::DeprecatedMethodWarning) do
      StructuredWarnings::DeprecationWarning.disable do
        Foo.new.method_using_structured_warning_style_api
      end
    end
    assert_warn(StructuredWarnings::DeprecationWarning) do
      Foo.new.method_using_structured_warning_style_api
    end
  end

  def test_warn_writes_to_stderr
    require "stringio"
    old_stderr = $stderr
    $stderr = io = ::StringIO.new
    Foo.new.method_using_structured_warning_style_api
    $stderr = old_stderr
    io.rewind
    assert io.length > 0
  end

  def test_warning_is_default_warning
    assert_warn(StructuredWarnings::Base) do
      warn "my warning"
    end
  end

  def test_passing_a_warning_instance_works_as_well
    assert_warn(StructuredWarnings::Base) do
      warn StructuredWarnings::Base.new("my warning")
    end
  end

  def test_passing_anything_but_a_subclass_or_instance_of_warning_will_work
    assert_warn(StructuredWarnings::Base) do
      warn nil
    end
  end

  def test_passing_an_additional_message_to_assert_no_warn
    assert_no_warn(StructuredWarnings::Base, "with message") do
      warn StructuredWarnings::Base, "with another message"
    end
  end

  def test_passing_an_additional_message_to_assert_warn
    assert_warn(StructuredWarnings::Base, "with message") do
      warn StructuredWarnings::Base, "with message"
    end
  end

  def test_passing_a_warning_instance_to_assert_warn
    assert_warn(StructuredWarnings::Base.new("with message")) do
      warn StructuredWarnings::Base, "with message"
    end
  end

  def test_passing_a_warning_instance_to_assert_no_warn
    assert_no_warn(StructuredWarnings::Base.new("with message")) do
      warn StructuredWarnings::DeprecationWarning, "with another message"
    end
    assert_no_warn(StructuredWarnings::Base.new) do
      warn StructuredWarnings::Base, "with message"
    end
  end

  def test_passing_a_regexp_as_message_to_assert_warn
    assert_warn(StructuredWarnings::Base, /message/) do
      warn StructuredWarnings::DeprecationWarning, "with another message"
    end
  end

  def test_passing_a_regexp_as_message_to_no_assert_warn
    assert_no_warn(StructuredWarnings::Base, /message/) do
      warn StructuredWarnings::DeprecationWarning
    end
  end

  def test_passing_a_message_only_to_assert_warn
    assert_warn("I told you so") do
      warn "I told you so"
    end
  end

  def test_warnings_may_not_be_disabled_twice
    assert_equal [StructuredWarnings::Base], StructuredWarnings::Base.disable
    assert_equal [StructuredWarnings::Base], StructuredWarnings::Base.disable
    assert_equal [], StructuredWarnings::Base.enable
  end

  protected

  def supports_fork
    return false unless Process.respond_to? :fork
    fork { Kernel.exit! }
    Process.wait

    true
  rescue NotImplementedError
    false
  end
end
