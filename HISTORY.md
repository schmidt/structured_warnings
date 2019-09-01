## 0.4.0 2019-09-02

* Major changes
  * Support for uplevel parameter introduced in Ruby 2.5
* Incompatible changes
  * White space fixes for default warner output. If you have parsed the output
    manually or written your own warners, you'll need to double check the
    expected results.

## 0.3.0 2017-03-23

* Major changes
  * Add Ruby 2.4 compatibility
  * Support built-in warnings in Ruby 2.4 with `StructuredWarnings::BuiltInWarning`
* Incompatible changes
  * Drop Ruby 1.x compatibility
  * Changed most of the public class names

## 0.2.0 2015-01-15

* Merging pull requests #4, and #5
  * Fixes to dynamic.rb to support forking from non-main thread
  * Improve compatibility with other libs overriding Kernel#warn
* Testing on latest Ruby VMs (Ruby 2 variants, JRuby and Rubinius)

## 0.1.4 2013-01-23

* Reorganized Rakefile and tasks, removed Jeweler dependency.
* Updated tests, fixed circular dependency error.
* Removed version.yml.

## 0.1.3 2009-11-28

* major enhancements
  * improved API of `assert_warn` and `assert_no_warn`

## 0.1.2 2009-11-27

* major enhancements
  * moved to gemcutter
* minor enhancements
  * removed all old cruft

## 0.1.1 2008-02-22

* 1 major enhancement:
  * Fully documented library
* 1 minor fix
  * Warnings can no longer be disabled twice

## 0.1.0 2008-02-21

* 1 major enhancement:
  * Initial release
  * No documentation yet
