module StructuredWarnings
  # This module ecapsulates all extensions to support <code>test/unit</code>.
  module Test
    module Assertions
      # :call-seq:
      #   assert_no_warn(message = nil) {|| ...}
      #   assert_no_warn(warning_class, message) {|| ...}
      #   assert_no_warn(warning_instance) {|| ...}
      #
      # Asserts that the given warning was not emmitted. It may be restricted
      # to a certain subtree of warnings and/or message.
      #
      #   def foo
      #     warn DeprecatedMethodWarning, "used foo, use bar instead"
      #     bar
      #   end
      #
      #   assert_no_warn(StandardWarning) { foo }    # passes
      #
      #   assert_no_warn(DeprecationWarning) { foo } # fails
      #   assert_no_warn() { foo }                   # fails
      #
      # See assert_warn for more examples.
      def assert_no_warn(*args)
        warning, message = parse_arguments(args)

        w = StructuredWarnings::Test::Warner.new
        StructuredWarnings::with_warner(w) do 
          yield
        end
        assert !w.warned?(warning, message), "#{warning} has been emitted."
      end

      # :call-seq:
      #   assert_warn(message = nil) {|| ...}
      #   assert_warn(warning_class, message) {|| ...}
      #   assert_warn(warning_instance) {|| ...}
      #
      # Asserts that the given warning was emmitted. It may be restricted to a
      # certain subtree of warnings and/or message.
      #
      #   def foo
      #     warn DeprecatedMethodWarning, "used foo, use bar instead"
      #     bar
      #   end
      #
      #   # passes
      #   assert_warn(DeprecatedMethodWarning) { foo }      
      #   assert_warn(DeprecationWarning) { foo }           
      #   assert_warn() { foo }                             
      #   assert_warn(Warning, "used foo, use bar instead") { foo }
      #   assert_warn(Warning, /use bar/) { foo }
      #   assert_warn(Warning.new("used foo, use bar instead")) { foo }
      #
      #   # fails
      #   assert_warn(StandardWarning) { foo }
      #   assert_warn(Warning, /deprecated/) { foo }
      #   assert_warn(Warning.new) { foo }
      #
      def assert_warn(*args)
        warning, message = parse_arguments(args)

        w = StructuredWarnings::Test::Warner.new
        StructuredWarnings::with_warner(w) do 
          yield
        end
        assert w.warned?(warning, message), "#{warning} has not been emitted."
      end

    private
      def parse_arguments(args)
        first = args.shift
        if first.is_a? Class and first <= Warning
          warning = first
          message = args.shift

        elsif first.is_a? Warning
          warning = first.class
          message = first.message

        elsif first.is_a? String
          warning = StandardWarning
          message = first

        else
          warning = Warning
          message = nil
        end

        unless args.empty?
          raise ArgumentError, 
                "wrong number of arguments (#{args.size + 2} for 2)" 
        end

        return warning, message
      end
    end
  end
end
