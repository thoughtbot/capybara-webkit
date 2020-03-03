capybara-webkit
===============

**Development has been suspended** on this project because QtWebKit was
deprecated in favor of QtWebEngine, which is not a suitable replacement for our
purposes.

We instead recommend using the [Selenium] or [Apparition] drivers.

[Selenium]: https://github.com/teamcapybara/capybara#selenium
[Apparition]: https://github.com/twalpole/apparition

Qt Dependency and Installation Issues
-------------------------------------

capybara-webkit depends on a WebKit implementation from Qt, a cross-platform
development toolkit. You'll need to download the Qt libraries to build and
install the gem. You can find instructions for downloading and installing Qt on
the
[capybara-webkit wiki](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).
capybara-webkit requires Qt version 4.8 or greater.

CI
--

If you're like us, you'll be using capybara-webkit on CI.

On Linux platforms, capybara-webkit requires an X server to run, although it doesn't create any visible windows. Xvfb works fine for this. You can setup Xvfb yourself and set a DISPLAY variable, try out the [headless gem](https://github.com/leonid-shevtsov/headless), or use the xvfb-run utility as follows:

```
xvfb-run -a bundle exec rspec
```

This automatically sets up a virtual X server on a free server number.

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

Configuration
-------------

You can configure global options using `Capybara::Webkit.configure`:

``` ruby
Capybara::Webkit.configure do |config|
  # Enable debug mode. Prints a log of everything the driver is doing.
  config.debug = true

  # By default, requests to outside domains (anything besides localhost) will
  # result in a warning. Several methods allow you to change this behavior.

  # Silently return an empty 200 response for any requests to unknown URLs.
  config.block_unknown_urls

  # Allow pages to make requests to any URL without issuing a warning.
  config.allow_unknown_urls

  # Allow a specific domain without issuing a warning.
  config.allow_url("example.com")

  # Allow a specific URL and path without issuing a warning.
  config.allow_url("example.com/some/path")

  # Wildcards are allowed in URL expressions.
  config.allow_url("*.example.com")

  # Silently return an empty 200 response for any requests to the given URL.
  config.block_url("example.com")

  # Timeout if requests take longer than 5 seconds
  config.timeout = 5

  # Don't raise errors when SSL certificates can't be validated
  config.ignore_ssl_errors

  # Don't load images
  config.skip_image_loading

  # Use a proxy
  config.use_proxy(
    host: "example.com",
    port: 1234,
    user: "proxy",
    pass: "secret"
  )

  # Raise JavaScript errors as exceptions
  config.raise_javascript_errors = true
end
```

These options will take effect for all future sessions and only need to be set
once. It's recommended that you configure these in your `spec_helper.rb` or
`test_helper.rb` rather than a `before` or `setup` block.

Offline Application Cache
-------------------------

The offline application cache needs a directory to write to for the cached files. Capybara-webkit
will look at if the working directory has a tmp directory and when it exists offline application
cache will be enabled.

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

**cookies**: allows read-only access of cookies for the current session

```ruby
page.driver.cookies["alpha"]
=> "abc"
```

**header**: set the given HTTP header for subsequent requests

```ruby
page.driver.header 'Referer', 'https://www.thoughtbot.com'
```


[CONTRIBUTING]: CONTRIBUTING.md

License
-------

capybara-webkit is Copyright (c) 2010-2015 thoughtbot, inc. It is free software,
and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

About
-----

Thank you, [contributors]!

[contributors]: https://github.com/thoughtbot/capybara-webkit/graphs/contributors

Code for rendering the current webpage to a PNG is borrowed from Phantom.js'
implementation.

![thoughtbot](http://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg)

capybara-webkit is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community]
or [hire us][hire] to help build your product.

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
