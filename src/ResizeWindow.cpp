#include "ResizeWindow.h"
#include "WebPage.h"

ResizeWindow::ResizeWindow(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void ResizeWindow::start() {
  int     width     = arguments()[0].toInt();
  int     height    = arguments()[1].toInt();

  QSize size(width, height);
  page()->setViewportSize(size);

  emit finished(new Response(true));
}

