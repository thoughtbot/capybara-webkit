#include "WindowFocus.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "CommandFactory.h"
#include "WebPageManager.h"
#include "ErrorMessage.h"

WindowFocus::WindowFocus(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void WindowFocus::start() {
  focusWindow(arguments()[0]);
}

void WindowFocus::windowNotFound() {
  finish(false, new ErrorMessage("Unable to locate window."));
}

void WindowFocus::success(WebPage *page) {
  page->setFocus();
  finish(true);
}

void WindowFocus::focusWindow(QString selector) {
  foreach(WebPage *page, manager()->pages()) {
    if (page->matchesWindowSelector(selector)) {
      success(page);
      return;
    }
  }

  windowNotFound();
}
