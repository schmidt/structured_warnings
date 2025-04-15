require 'test_helper'
require 'stringio'

class StructuredWarningsTest < Test::Unit::TestCase
  class Foo
    def method_using_structured_warning_style_api
      warn StructuredWarnings::DeprecatedMethodWarning,
           'This method is deprecated. Use new_method instead'
    end

    def method_using_uplevel
      warn "BigDecimal.new is deprecated; use BigDecimal() method instead.", uplevel: 1
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

  def opening_quote
    if RUBY_VERSION < '3.4'
      '`'
    else
      "'"
    end
  end

  def classname_in_message
    if RUBY_VERSION < '3.4'
      ''
    else
      'StructuredWarningsTest#'
    end
  end

  def test_fork_in_thread
    return unless supports_fork?

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

  def test_warn_using_uplevel
    foo = Foo.new

    assert_warn(StructuredWarnings::StandardWarning) do
      foo.method_using_uplevel
    end
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
    stderr = $stderr

    $stderr = io = ::StringIO.new
    Foo.new.method_using_structured_warning_style_api
    io.rewind
    assert io.length > 0
  ensure
    $stderr = stderr
  end

  def test_base_is_default_warning
    assert_warn(StructuredWarnings::Base) do
      warn "my warning"
    end
  end

  def test_builtin_warnings
    with_verbose_warnings do
      assert_warn(StructuredWarnings::BuiltInWarning, /method redefined; discarding old name/) do
        class << Object.new
          attr_accessor :name

          def name
            @name.to_s.downcase
          end
        end
      end
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

  def test_formatting_of_warn
    actual_warning = capture_strderr do
      warn 'do not blink'
    end

    expected_warning =
      "#{__FILE__}:#{__LINE__ - 4}:" +
      "in #{opening_quote}block in #{classname_in_message}test_formatting_of_warn': " +
      "do not blink " +
      "(StructuredWarnings::StandardWarning)\n"

    assert_equal expected_warning, actual_warning
  end

  def test_formatting_of_warn_with_uplevel
    code_emitting_warn = proc do
      warn 'do not blink', uplevel: 1
    end

    actual_warning = capture_strderr do
      code_emitting_warn.call
    end

    expected_warning =
      "#{__FILE__}:#{__LINE__ - 4}:" +
      "in #{opening_quote}block in #{classname_in_message}test_formatting_of_warn_with_uplevel': " +
      "do not blink " +
      "(StructuredWarnings::StandardWarning)\n"

    assert_equal expected_warning, actual_warning
  end

  def test_formatting_of_builtin_warn
    actual_warning = capture_strderr do
      class << Object.new
        attr_accessor :name

        def name
          @name.to_s.downcase
        end
      end
    end

    expected_warning =
      "#{__FILE__}:#{__LINE__ - 7}:" +
      "in #{opening_quote}singleton class': " +
      "method redefined; discarding old name " +
      "(StructuredWarnings::BuiltInWarning)\n"

    assert_equal expected_warning, actual_warning
  end

  def test_formatting_of_manual_warn
    actual_warning = capture_strderr do
      Warning.warn("This is a test warning.")
    end

    expected_warning =
      "#{__FILE__}:#{__LINE__ - 4}:" +
      "in #{opening_quote}block in #{classname_in_message}test_formatting_of_manual_warn': " +
      "This is a test warning. " +
      "(StructuredWarnings::BuiltInWarning)\n"

    assert_equal expected_warning, actual_warning
  end

  protected

  def supports_fork?
    return false unless Process.respond_to? :fork
    fork { Kernel.exit! }
    Process.wait

    true
  rescue NotImplementedError
    false
  end

  def with_verbose_warnings
    verbose, $VERBOSE = $VERBOSE, true

    yield
  ensure
    $VERBOSE = verbose
  end

  def capture_strderr(&block)
    stderr = $stderr

    $stderr = io = ::StringIO.new

    with_verbose_warnings(&block)

    io.rewind
    io.read
  ensure
    $stderr = stderr
  end
end
