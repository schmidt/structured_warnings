class Warning
  attr_accessor :message

  def initialize(message)
    self.message = message
  end

  module ClassMethods
    def active?
      disabled_warnings.all? {|w| !(w >= self)}
    end

    def disable
      if block_given?
        Dynamic.let(:disabled_warnings => disabled_warnings | [self]) do
          yield
        end
      else
        self.disabled_warnings |= [self]
      end
    end

    def enable
      if block_given?
        Dynamic.let(:disabled_warnings => disabled_warnings - [self]) do
          yield
        end
      else
        self.disabled_warnings -= [self]
      end
    end

  protected
    def disabled_warnings
      Dynamic[:disabled_warnings]
    end
    def disabled_warnings=(new)
      Dynamic[:disabled_warnings] = new
    end
  end

  extend ClassMethods
end

class DeprecationWarning < Warning; end
class DeprecatedMethodWarning < DeprecationWarning; end
class DeprecatedSignatureWarning < DeprecationWarning; end
