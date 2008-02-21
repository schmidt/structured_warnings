$:.unshift File.dirname(__FILE__)
require "structured_warnings/dynamic"
require "structured_warnings/kernel"
require "structured_warnings/warner"
require "structured_warnings/warning"

module StructuredWarnings
  def self.init
    Object.send(:include, Kernel)
    unless Dynamic.variables.include?(:disabled_warnings)
      Dynamic[:disabled_warnings] = []
      Dynamic[:warner] = StructuredWarnings::Warner.new
    end
    init_test if defined? ::Test
  end

  def self.init_test
    require "structured_warnings/test.rb"
    ::Test::Unit::TestCase.send(:include, StructuredWarnings::Test::Assertions)
  end
end

StructuredWarnings.init
