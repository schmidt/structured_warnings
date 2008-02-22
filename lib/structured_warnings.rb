$:.unshift File.dirname(__FILE__)

require "structured_warnings/dynamic"
require "structured_warnings/kernel"
require "structured_warnings/warner"
require "structured_warnings/warning"


module StructuredWarnings
  # On initialization self.init is called. When a test module is defined, it
  # is a assumed, that <code>test/unit</code> is used and the warn assertions 
  # are added to Test::Unit::TestCase. If you <code>require "test/unit"</code> 
  # after +structured_warnings+ you have to call #StructuredWarnings::init_test 
  # manually.
  module ClassMethods
    # Executes a block using the given warner. This may be used to suppress
    # warnings to stdout, but fetch them and redirect them to somewhere else.
    #
    # This behaviour is used in the StructuredWarnings::Assertions
    def with_warner(warner)
      Dynamic.let(:warner => warner) do
        yield
      end
    end

    # Gives access to the currently used warner. Default is an instance of
    # StructuredWarnings::Warner
    def warner
      Dynamic[:warner]
    end

    #:stopdoc:
    # Sets a new warner 
    def warner=(new_warner)
      Dynamic[:warner] = new_warner
    end

    # returns an Array of all currently disabled warnings.
    #
    # *Note*: Everyday users are supposed to use the methods in 
    # Warning::ClassMethods
    def disabled_warnings
      Dynamic[:disabled_warnings]
    end

    # sets an array of all currently disabled warnings. It is expected that this
    # array consists only of the Warning class and its subclasses.
    #
    # *Note*: Everyday users are supposed to use the methods in 
    # Warning::ClassMethods
    def disabled_warnings=(new_disabled_warnings)
      Dynamic[:disabled_warnings] = new_disabled_warnings
    end

    # Executes a block with the given set of disabled instances.
    #
    # *Note*: Everyday users are supposed to use the methods in 
    # Warning::ClassMethods
    def with_disabled_warnings(disabled_warnings)
      Dynamic.let(:disabled_warnings => disabled_warnings) do
        yield
      end
    end
    #:startdoc:

  protected
    # Initializes the StructuredWarnings library. Includes the Kernel extensions
    # into Object, sets the initial set of disabled_warnings (none) and 
    # initializes the warner to an instance of StructuredWarnings::Warner
    def init
      unless Object < StructuredWarnings::Kernel
        Object.class_eval { include StructuredWarnings::Kernel }
        StructuredWarnings::disabled_warnings = []
        StructuredWarnings::warner = StructuredWarnings::Warner.new
      end
      init_test if defined? ::Test
    end

    # Initializes the StructuredWarnings test extensions - namely adds 
    # StructuredWarnings::Test::Assertions to Test::Unit::TestCase
    def init_test
      require "structured_warnings/test.rb"
      ::Test::Unit::TestCase.class_eval do
        include StructuredWarnings::Test::Assertions
      end
    rescue NameError
    end
  end
  extend ClassMethods

  init
end
