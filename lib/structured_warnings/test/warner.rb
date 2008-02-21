module StructuredWarnings
  module Test
    class Warner < StructuredWarnings::Warner
      def format(warning, message, call_stack)
        given_warnings << warning 
        nil
      end

      def warned?(warning)
        given_warnings.any? {|w| (w <= warning)}
      end

      def given_warnings
        @given_warnings ||= []
      end
    end
  end
end
