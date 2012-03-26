#include "WindowFocus.h"
#include "Command.h"
#include "WebPage.h"
#include "WebPageManager.h"

WindowFocus::WindowFocus(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void WindowFocus::start() {
  WebPage *webPage = WebPageManager::getInstance()->last();
  if (webPage) {
    emit windowChanged(webPage);
    success();
  } else {
    windowNotFound();
  }
}

void WindowFocus::windowNotFound() {
  emit finished(new Response(false, QString("Unable to locate window. ")));
}

void WindowFocus::success() {
  emit finished(new Response(true));
}
