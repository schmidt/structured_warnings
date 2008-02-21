module StructuredWarnings
  module Test
    module Assertions
      def assert_no_warn(warning = Warning)
        w = StructuredWarnings::Test::Warner.new
        Dynamic.let(:warner => w) do
          yield
        end
        assert !w.warned?(warning), "#{warning} has been emitted."
      end

      def assert_warn(warning = Warning)
        w = StructuredWarnings::Test::Warner.new
        Dynamic.let(:warner => w) do
          yield
        end
        assert w.warned?(warning), "#{warning} has not been emitted."
      end
    end
  end
end

