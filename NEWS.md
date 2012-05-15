New for 0.12.0:
* Better windows support
* Support for localStorage
* Added support for oninput event
* Added resize_window method
* Server binds on LocalHost to prevent having to add firewall exceptions
* Reuse NetworkAccessManager to prevent "too many open files" errors
* Response messages are stored as QByteArray to prevent truncating content
* Browser no longer tries to read empty responses (Fixes jruby issues).
* Server will timeout if it can not start

New for 0.11.0:

* Allow interaction with invisible elements
* Use Timeout from stdlib since Capybara.timeout is being removed

New for 0.10.1:

* LANG environment variable is set to en_US.UTF-8 in order to avoid string encoding issues from qmake.
* pro, find_command, and CommandFactory are more structured.
* Changed wiki link and directing platform specific issues to the google group.
* Pass proper keycode value for keypress events.

New for 0.10.0:

* current_url now more closely matches the behavior of Selenium
* custom MAKE, QMAKE, and SPEC options can be set from the environment
* BUG: Selected attribute is no longer removed when selecting/deselecting. Only the property is changed.

New for 0.9.0:

* Raise an error when an invisible element receives #click.
* Raise ElementNotDisplayedError for #drag_to and #select_option when element is invisible.
* Trigger mousedown and mouseup events.
* Model mouse events more closely to the browser.
* Try to detech when a command starts a page load and wait for it to finish
