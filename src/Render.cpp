#include "Render.h"
#include "WebPage.h"

Render::Render(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Render::start(QStringList &arguments) {
  QStringList functionArguments(arguments);
  QString imagePath = functionArguments.takeFirst();
  int     width     = functionArguments.takeFirst().toInt();
  int     height    = functionArguments.takeFirst().toInt();

  QSize size(width, height);
  page()->setViewportSize(size);

  bool result = page()->render( imagePath );

  emit finished(new Response(result));
}
