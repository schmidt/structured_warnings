require 'structured_warnings/test_unit/warner'
require 'structured_warnings/test_unit/assertions'

Test::Unit::TestCase.class_eval do
  include StructuredWarnings::TestUnit::Assertions
end
