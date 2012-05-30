capybara-webkit
===============

A [capybara](https://github.com/jnicklas/capybara) driver that uses [WebKit](http://webkit.org) via [QtWebKit](http://doc.qt.nokia.com/4.7/qtwebkit.html).

Qt Dependency and Installation Issues
-------------

capybara-webkit depends on a WebKit implementation from Qt, a cross-platform
development toolkit. You'll need to download the Qt libraries to build and
install the gem. You can find instructions for downloading and installing QT on
the [capybara-webkit wiki](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit)

Windows Support
---------------

Currently 32bit Windows will compile Capybara-webkit. Support for Windows is provided by the open source community and Windows related issues should be posted to the [mailing list](http://groups.google.com/group/capybara-webkit)

Reporting Issues
----------------

Without access to your application code we can't easily debug most crashes or
generic failures, so we've included a debug version of the driver that prints a
log of what happened during each test. Before filing a crash bug, please see
[Reporting Crashes](https://github.com/thoughtbot/capybara-webkit/wiki/Reporting-Crashes).
You're much more likely to get a fix if you follow those instructions.

If you are having compiling issues please check out the
[capybara-webkit wiki](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).
If you don't have any luck there, please post to the
[mailing list](http://groups.google.com/group/capybara-webkit). Please don't
open a Github issue for a system-specific compiler issue.

CI
--

If you're like us, you'll be using capybara-webkit on CI.

On Linux platforms, capybara-webkit requires an X server to run, although it doesn't create any visible windows. Xvfb works fine for this. You can setup Xvfb yourself and set a DISPLAY variable, or try out the [headless gem](https://github.com/leonid-shevtsov/headless).

Usage
-----

Add the capybara-webkit gem to your Gemfile:

    gem "capybara-webkit"

Set your Capybara Javascript driver to webkit:

    Capybara.javascript_driver = :webkit

In cucumber, tag scenarios with @javascript to run them using a headless WebKit browser.

In RSpec, use the :js => true flag.

Take note of the transactional fixtures section of the [capybara README](https://github.com/jnicklas/capybara/blob/master/README.md).

If you're using capybara-webkit with Sinatra, don't forget to set

    Capybara.app = MySinatraApp.new

Non-Standard Driver Methods
---------------------------

capybara-webkit supports a few methods that are not part of the standard capybara API. You can access these by calling `driver` on the capybara session. When using the DSL, that will look like `page.driver.method_name`.

**console_messages**: returns an array of messages printed using console.log

    # In Javascript:
    console.log("hello")
    # In Ruby:
    page.driver.console_messages
    => {:source=>"http://example.com", :line_number=>1, :message=>"hello"}

**error_messages**: returns an array of Javascript errors that occurred

    page.driver.error_messages
    => {:source=>"http://example.com", :line_number=>1, :message=>"SyntaxError: Parse error"}

**resize_window**: change the viewport size to the given width and height

    page.driver.resize_window(500, 300)
    page.driver.evaluate_script("window.innerWidth")
    => 500

**render**: render a screenshot of the current view (requires [mini_magick](https://github.com/probablycorey/mini_magick) and [ImageMagick](http://www.imagemagick.org))

    page.driver.render "tmp/screenshot.png"

**cookies**: allows read-only access of cookies for the current session

    page.driver.cookies["alpha"]
    => "abc"

Contributing
------------

See the CONTRIBUTING document.

About
-----

The capybara WebKit driver is maintained by Joe Ferris and Matt Mongeau. It was written by [thoughtbot, inc](http://thoughtbot.com/community) with the help of numerous [contributions from the open source community](https://github.com/thoughtbot/capybara-webkit/contributors).

Code for rendering the current webpage to a PNG is borrowed from Phantom.js' implementation.

![thoughtbot](http://thoughtbot.com/images/tm/logo.png)

The names and logos for thoughtbot are trademarks of thoughtbot, inc.

License
-------

capybara-webkit is Copyright (c) 2011 thoughtbot, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.
