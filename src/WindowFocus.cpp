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
  QListIterator<WebPage *> pageIterator = manager()->iterator();

  while (pageIterator.hasNext()) {
    WebPage *page = pageIterator.next();

    if (page->matchesWindowSelector(selector)) {
      success(page);
      return;
    }
  }

  windowNotFound();
}
