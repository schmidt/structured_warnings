begin
  require 'structured_warnings'
  puts '+ structured warnings'
rescue LoadError
  puts '- structured warnings'
end
puts

class A
  def foo
    bar
    baz
    bazzy
  end

  def bar
    warn 'This is not fine', uplevel: 1
    self
  end

  def baz
    warn 'Baz is not fine either'
    self
  end

  def bazzy
    Object.new.instance_variable_get(:@ivar)
  end
end

A.new.foo
