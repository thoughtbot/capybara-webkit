#include "WindowFocus.h"
#include "Command.h"
#include "WebPage.h"
#include "CommandFactory.h"
#include "WebPageManager.h"

WindowFocus::WindowFocus(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void WindowFocus::start() {
  focusWindow(arguments()[0]);
}

void WindowFocus::windowNotFound() {
  emit finished(new Response(false, QString("Unable to locate window. ")));
}

void WindowFocus::success(WebPage *page) {
  ((CommandFactory *) parent())->m_manager->setCurrentPage(page);
  emit finished(new Response(true));
}

void WindowFocus::focusWindow(QString selector) {
  QListIterator<WebPage *> pageIterator =
    ((CommandFactory *) parent())->m_manager->iterator();

  while (pageIterator.hasNext()) {
    WebPage *page = pageIterator.next();

    if (page->matchesWindowSelector(selector)) {
      success(page);
      return;
    }
  }

  windowNotFound();
}
