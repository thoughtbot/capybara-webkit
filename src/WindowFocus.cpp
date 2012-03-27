#include "WindowFocus.h"
#include "Command.h"
#include "WebPage.h"
#include "WebPageManager.h"

WindowFocus::WindowFocus(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void WindowFocus::start() {
  WebPageManager *manager = WebPageManager::getInstance();

  switch(arguments().length()) {
    case 1:
      emit windowChanged(manager->last());
      success();
      break;
    default:
      emit windowChanged(manager->first());
      success();
  }
}

void WindowFocus::windowNotFound() {
  emit finished(new Response(false, QString("Unable to locate window. ")));
}

void WindowFocus::success() {
  emit finished(new Response(true));
}
