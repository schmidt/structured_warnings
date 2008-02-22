require "structured_warnings"
require "structured_warnings/test/warner.rb"
require "structured_warnings/test/assertions.rb"

Test::Unit::TestCase.class_eval do
  include StructuredWarnings::Test::Assertions
end
