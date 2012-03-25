#include "Render.h"
#include "WebPage.h"

Render::Render(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void Render::start() {
  if (arguments().size() != 3) {
    emit finished(new Response(false, "Render expects 3 parameters"));
    return;
  }

  QString imagePath = arguments()[0];
  int width = arguments()[1].toInt();
  int height = arguments()[2].toInt();

  QSize size(width, height);
  page()->setViewportSize(size);

  bool result = page()->render( imagePath );

  emit finished(new Response(result));
}
