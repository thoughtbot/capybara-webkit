#include "Visit.h"
#include "Command.h"
#include "WebPage.h"

Visit::Visit(WebPage *page, QObject *parent) : Command(page, parent) {
  connect(page, SIGNAL(loadFinished(bool)), this, SLOT(loadFinished(bool)));
}

void Visit::start(QStringList &arguments) {
  QUrl requestedUrl = QUrl(arguments[0]);
  QNetworkRequest req;
  req.setUrl(requestedUrl);
  if(requestedUrl.hasFragment()) {
    // workaround for https://bugs.webkit.org/show_bug.cgi?id=32723
    req.setUrl(QUrl(requestedUrl));
  }
  page()->currentFrame()->load(req);
}

void Visit::loadFinished(bool success) {
  QString message;
  if (!success)
    message = page()->failureString();

  emit finished(new Response(success, message));
}
