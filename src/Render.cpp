#include "Render.h"
#include "WebPage.h"
#include "WebPageManager.h"

Render::Render(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Render::start() {
  QString imagePath = arguments()[0];
  int width = arguments()[1].toInt();
  int height = arguments()[2].toInt();

  QSize size(width, height);

  bool result = page()->render( imagePath, size );

  finish(result);
}
