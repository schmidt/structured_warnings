# StructuredWarnings

> **Disclaimer:** This is an experimental reimplementation of structured
> warnings, based on Ruby 2.4's new warning module. This is not yet ready for
> prime time.

This is an implementation of Daniel Berger's [proposal of structured warnings
for Ruby](https://web.archive.org/web/20140328021259/http://www.oreillynet.com/ruby/blog/2008/02/structured_warnings_now.html).
They provide dynamic suppression and activation, as well as, an inheritance
hierarchy to model their relations. This library preserves the old `warn`
signature, but additionally allows a `raise`-like use.

For more information on the usage and benefits of this library have a look at
the inspiring article at O'Reilly.

[www.oreillynet.com/ruby/blog/2008/02/structured\_warnings\_now.html](https://web.archive.org/web/20140328021259/http://www.oreillynet.com/ruby/blog/2008/02/structured_warnings_now.html)
(link to web archive - O'Reilly took it down)



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'structured_warnings'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install structured_warnings


## Compatibility

`structured\_warnings` aims to work with all Ruby interpreters.

Please let me know, of any other compatibilities or file a bug for any
incompatibilities.


### Known Issues

Although the library transparently coorperates with Ruby's built-in
<code>Kernel#warn</code>, it may not override +rb_warn+ which is used internally to emit
"method redefined", "void context", and "parenthesis" warnings. They may not be
manipulated by structured_warnings.


## Usage

To get you started - here is a short example

In order to use `structured\_warnings` in library code, use the following code.

```ruby
# in lib/...
require 'structured_warnings'

class Foo
  def old_method
    warn DeprecatedMethodWarning, 'This method is deprecated. Use new_method instead'
    # Do stuff
  end
end

# in test/...
require 'test/unit'
require 'structured_warnings'

class FooTests < Test::Unit::TestCase
  def setup
    @foo = Foo.new
  end

  def test_old_method_emits_deprecation_warning
    assert_warn(DeprecatedMethodWarning){ @foo.old_method }
  end
end
```

`DeprecatedMethodWarning` is only one of multiple predefined warning types. You
may add your own types by subclassing Warning if you like.

Client code of your library will look as follows:

```ruby
require "foo"

foo = Foo.new
foo.old_method # => will print
               # ... `old_method' : This method is deprecated. Use new_method instead (DeprecatedMethodWarning)
```

But the main difference to the standard warning concept shipped with ruby, is
that the client is able to selectively disable certain warnings s/he is aware of
and not willing to fix.

```ruby
DeprecatedMethodWarning.disable # Globally disable warnings about deprecated methods!

foo.old_method # => will print nothing

DeprecatedMethodWarning.enable # Reenable warnings again.
```

And there is an even more powerful option for your clients, the can selectively
disable warnings in a dynamic block scope.

```ruby
# Don't bug me about deprecated method warnings within this block, I know
# what I'm doing.
#
DeprecatedMethodWarning.disable do
  foo.old_method
end
```

These settings are scoped to the local thread (and all threads spawned in the
block scope) and automatically reset after the block.


## Detailed Documentation

Have closer look at the RDoc of `StructuredWarnings::Kernel`, `Warning` and
`Warning::ClassMethods`.

Part of this library is a set of different warnings:

* `Warning`
  * `StandardWarning`
  * `DeprecationWarning`
    * `DeprecatedMethodWarning`
    * `DeprecatedSignatureWarning`

You are encourage to use your own subclasses of `Warning` to give as much
feedback to your users as possible.


## Resources

* [Inspiring article](https://web.archive.org/web/20140328021259/http://www.oreillynet.com/ruby/blog/2008/02/structured_warnings_now.html)
* [Implementation Highlights](http://www.nach-vorne.de/2008/2/22/structured_warnings-highlights)
* [Project's website](https://github.com/schmidt/structured_warnings/)
* [API doc](http://rdoc.info/projects/schmidt/structured_warnings)
* [Build status](https://travis-ci.org/schmidt/structured_warnings)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
[github,com/schmidt/structured\_warnings](https://github.com/schmidt/structured_warnings).


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).