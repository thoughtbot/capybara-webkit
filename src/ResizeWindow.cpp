#include "ResizeWindow.h"
#include "WebPage.h"
#include "WebPageManager.h"

ResizeWindow::ResizeWindow(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void ResizeWindow::start() {
  int     width     = arguments()[0].toInt();
  int     height    = arguments()[1].toInt();

  QSize size(width, height);
  page()->setViewportSize(size);

  emit finished(new Response(true));
}

