#include "WindowFocus.h"
#include "Command.h"
#include "WebPage.h"
#include "CommandFactory.h"
#include "WebPageManager.h"

WindowFocus::WindowFocus(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void WindowFocus::start() {
  focusWindow(arguments()[0]);
}

void WindowFocus::windowNotFound() {
  emit finished(new Response(false, QString("Unable to locate window. ")));
}

void WindowFocus::success(WebPage *page) {
  page->setFocus();
  emit finished(new Response(true));
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
