#include "Visit.h"
#include "Command.h"
#include "WebPage.h"

Visit::Visit(WebPage *page, QObject *parent) : Command(page, parent) {
  connect(page, SIGNAL(pageFinished(bool)), this, SLOT(loadFinished(bool)));
}

void Visit::start(QStringList &arguments) {
  QUrl requestedUrl = QUrl(arguments[0]);
  page()->currentFrame()->setUrl(QUrl(requestedUrl));
  if(requestedUrl.hasFragment()) {
    // workaround for https://bugs.webkit.org/show_bug.cgi?id=32723
    page()->currentFrame()->setUrl(QUrl(requestedUrl));
  }
}

void Visit::loadFinished(bool success) {
  QString message;
  if (!success)
    message = page()->failureString();

  disconnect(page(), SIGNAL(pageFinished(bool)), this, SLOT(loadFinished(bool)));
  emit finished(new Response(success, message));
}
