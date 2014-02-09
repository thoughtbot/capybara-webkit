capybara-webkit
===============

[![Build Status](https://secure.travis-ci.org/thoughtbot/capybara-webkit.png?branch=master)](https://travis-ci.org/thoughtbot/capybara-webkit)
[![Code Climate](https://codeclimate.com/github/thoughtbot/capybara-webkit.png)](https://codeclimate.com/github/thoughtbot/capybara-webkit)

A [capybara](https://github.com/jnicklas/capybara) driver that uses [WebKit](http://webkit.org) via [QtWebKit](http://trac.webkit.org/wiki/QtWebKit).

Qt Dependency and Installation Issues
-------------------------------------

capybara-webkit depends on a WebKit implementation from Qt, a cross-platform
development toolkit. You'll need to download the Qt libraries to build and
install the gem. You can find instructions for downloading and installing QT on
the
[capybara-webkit wiki](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).
capybara-webkit requires Qt version 4.8.

Windows Support
---------------

Currently 32-bit Windows will compile capybara-webkit. Support for Windows is
provided by the open source community and Windows related issues should be
posted to [Stack Overflow].

[Stack Overflow]: http://stackoverflow.com/questions/tagged/capybara-webkit

Reporting Issues
----------------

Without access to your application code we can't easily debug most crashes or
generic failures, so we've included a debug version of the driver that prints a
log of what happened during each test. Before filing a crash bug, please see
[Reporting Crashes]. You're much more likely to get a fix if you follow those
instructions.

If you're having trouble compiling or installing, please check out the [wiki].
If you don't have any luck there, please post to [Stack Overflow]. Please don't
open a Github issue for a system-specific compiler issue.

[Reporting Crashes]: https://github.com/thoughtbot/capybara-webkit/wiki/Reporting-Crashes
[capybara-webkit wiki]: https://github.com/thoughtbot/capybara-webkit/wiki
[Stack Overflow]: http://stackoverflow.com/questions/tagged/capybara-webkit

CI
--

If you're like us, you'll be using capybara-webkit on CI.

On Linux platforms, capybara-webkit requires an X server to run, although it doesn't create any visible windows. Xvfb works fine for this. You can setup Xvfb yourself and set a DISPLAY variable, or try out the [headless gem](https://github.com/leonid-shevtsov/headless).

Usage
-----

Add the capybara-webkit gem to your Gemfile:

```ruby
gem "capybara-webkit"
```

Set your Capybara Javascript driver to webkit:

```ruby
Capybara.javascript_driver = :webkit
```

In cucumber, tag scenarios with @javascript to run them using a headless WebKit browser.

In RSpec, use the `:js => true` flag. See the [capybara documentation](http://rubydoc.info/gems/capybara#Using_Capybara_with_RSpec) for more information about using capybara with RSpec.

Take note of the transactional fixtures section of the [capybara README](https://github.com/jnicklas/capybara/blob/master/README.md).

If you're using capybara-webkit with Sinatra, don't forget to set

```ruby
Capybara.app = MySinatraApp.new
```

Non-Standard Driver Methods
---------------------------

capybara-webkit supports a few methods that are not part of the standard capybara API. You can access these by calling `driver` on the capybara session. When using the DSL, that will look like `page.driver.method_name`.

**console_messages**: returns an array of messages printed using console.log

```js
// In Javascript:
console.log("hello")
```

```ruby
# In Ruby:
page.driver.console_messages
=> [{:source=>"http://example.com", :line_number=>1, :message=>"hello"}]
```

**error_messages**: returns an array of Javascript errors that occurred

```ruby
page.driver.error_messages
=> [{:source=>"http://example.com", :line_number=>1, :message=>"SyntaxError: Parse error"}]
```

**alert_messages, confirm_messages, prompt_messages**: returns arrays of Javascript dialog messages for each dialog type

```js
// In Javascript:
alert("HI");
confirm("Ok?");
prompt("Number?", "42");
```

```ruby
# In Ruby:
page.driver.alert_messages
=> ["Hi"]
page.driver.confirm_messages
=> ["Ok?"]
page.driver.prompt_messages
=> ["Number?"]
```

**resize_window**: change the viewport size to the given width and height

```ruby
page.driver.resize_window(500, 300)
page.driver.evaluate_script("window.innerWidth")
=> 500
```

**cookies**: allows read-only access of cookies for the current session

```ruby
page.driver.cookies["alpha"]
=> "abc"
```

**accept_js_confirms!**: accept any Javascript confirm that is triggered by the page's Javascript

```js
// In Javascript:
if (confirm("Ok?"))
  console.log("Hi");
else
  console.log("Bye");
```

```ruby
# In Ruby:
page.driver.accept_js_confirms!
visit "/"
page.driver.console_messages.first[:message]
=> "Hi"
```

**dismiss_js_confirms!**: dismiss any Javascript confirm that is triggered by the page's Javascript

```js
// In Javascript:
if (confirm("Ok?"))
  console.log("Hi");
else
  console.log("Bye");
```

```ruby
# In Ruby:
page.driver.dismiss_js_confirms!
visit "/"
page.driver.console_messages.first[:message]
=> "Bye"
```

**accept_js_prompts!**: accept any Javascript prompt that is triggered by the page's Javascript

```js
// In Javascript:
var a = prompt("Number?", "0")
console.log(a);
```

```ruby
# In Ruby:
page.driver.accept_js_prompts!
visit "/"
page.driver.console_messages.first[:message]
=> "0"
```

**dismiss_js_prompts!**: dismiss any Javascript prompt that is triggered by the page's Javascript

```js
// In Javascript:
var a = prompt("Number?", "0")
if (a != null)
  console.log(a);
else
  console.log("you said no"));
```

```ruby
# In Ruby:
page.driver.dismiss_js_prompts!
visit "/"
page.driver.console_messages.first[:message]
=> "you said no"
```

**js_prompt_input=(value)**: set the text to use if a Javascript prompt is encountered and accepted

```js
// In Javascript:
var a = prompt("Number?", "0")
console.log(a);
```

```ruby
# In Ruby:
page.driver.js_prompt_input = "42"
page.driver.accept_js_prompts!
visit "/"
page.driver.console_messages.first[:message]
=> "42"
```

**header**: set the given HTTP header for subsequent requests

```ruby
page.driver.header 'Referer', 'https://www.thoughtbot.com'
```

Contributing
------------

See the CONTRIBUTING document.

About
-----

The capybara WebKit driver is maintained by Joe Ferris and Matt Horan. It was written by [thoughtbot, inc](http://thoughtbot.com/community) with the help of numerous [contributions from the open source community](https://github.com/thoughtbot/capybara-webkit/contributors).

Code for rendering the current webpage to a PNG is borrowed from Phantom.js' implementation.

![thoughtbot](http://thoughtbot.com/images/tm/logo.png)

The names and logos for thoughtbot are trademarks of thoughtbot, inc.

License
-------

capybara-webkit is Copyright (c) 2010-2013 thoughtbot, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.
