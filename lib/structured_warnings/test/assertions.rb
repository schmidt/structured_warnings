module StructuredWarnings
  # This module ecapsulates all extensions to support <code>test/unit</code>.
  module Test
    module Assertions
      # Asserts that no warning was emmitted. It may be restricted to a certain
      # subtree of warnings.
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
      def assert_no_warn(warning = Warning)
        w = StructuredWarnings::Test::Warner.new
        StructuredWarnings::with_warner(w) do 
          yield
        end
        assert !w.warned?(warning), "#{warning} has been emitted."
      end

      # Asserts that a warning was emmitted. It may be restricted to a certain
      # subtree of warnings.
      #
      #   def foo
      #     warn DeprecatedMethodWarning, "used foo, use bar instead"
      #     bar
      #   end
      #
      #   assert_warn(DeprecatedMethodWarning) { foo } # passes
      #   assert_warn(DeprecationWarning) { foo }      # passes
      #   assert_warn() { foo }                        # passes
      #
      #   assert_warn(StandardWarning) { foo }         # fails
      #
      def assert_warn(warning = Warning)
        w = StructuredWarnings::Test::Warner.new
        StructuredWarnings::with_warner(w) do 
          yield
        end
        assert w.warned?(warning), "#{warning} has not been emitted."
      end
    end
  end
end
