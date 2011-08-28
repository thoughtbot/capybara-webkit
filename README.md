capybara-webkit
===============

A [capybara](https://github.com/jnicklas/capybara) driver that uses [WebKit](http://webkit.org) via [QtWebKit](http://doc.qt.nokia.com/4.7/qtwebkit.html).

Dependent on Qt
---------------

capybara-webkit depends on a WebKit implementation from Qt, a cross-platform
development toolkit. You'll need to download the Qt libraries to build and
install the gem.

OS X Lion 10.7:

Install Qt via [homebrew](http://mxcl.github.com/homebrew/) (NOTE: can take more than an hour) using:

    brew install qt --build-from-source

OS X < 10.7:

Download the [non-debug Cocoa package](http://qt.nokia.com/downloads/qt-for-open-source-cpp-development-on-mac-os-x) (the smaller of the two downloads).

Ubuntu:

    apt-get install libqt4-dev

Fedora:

    yum install qt-webkit-devel

Gentoo Linux:

    emerge x11-libs/qt-webkit

Other Linux distributions:

[Download this package](http://qt.nokia.com/downloads/linux-x11-cpp).

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

Tag scenarios with @javascript to run them using a headless WebKit browser.

Contributing
------------

See the CONTRIBUTING document.

About
-----

The capybara WebKit driver was written by Joe Ferris, Tristan Dunn, and Jason Morrison from [thoughtbot, inc](http://thoughtbot.com/community).

Code for rendering the current webpage to a PNG is borrowed from Phantom.js' implementation.

![thoughtbot](http://thoughtbot.com/images/tm/logo.png)

The names and logos for thoughtbot are trademarks of thoughtbot, inc.

Notes
-----

capybara-webkit will listen on port 8200. This may conflict with other services.

License
-------

capybara-webkit is Copyright (c) 2011 thoughtbot, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.
