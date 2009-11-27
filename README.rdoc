= Structured warnings 

Have closer look at StructuredWarnings::Kernel, Warning and 
Warning::ClassMethods.

Part of this library is a set of different warnings:

* Warning
  * StandardWarning
  * DeprecationWarning
    * DeprecatedMethodWarning
    * DeprecatedSignatureWarning

You are encourage to use your own subclasses of Warning to give as much feedback
to your users as possible.

Also see the projects website on http://rug-b.rubyforge.org/structured_warnings
and the inspiring article at 
http://www.oreillynet.com/ruby/blog/2008/02/structured_warnings_now.html.
