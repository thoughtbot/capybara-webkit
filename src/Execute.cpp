#include "Execute.h"
#include "WebPage.h"
#include "WebPageManager.h"

Execute::Execute(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Execute::start() {
  QString script = arguments()[0] + QString("; 'success'");
  QVariant result = page()->currentFrame()->evaluateJavaScript(script);
  if (result.isValid()) {
    emit finished(new Response(true));
  } else {
    emit finished(new Response(false, QString("Javascript failed to execute")));
  }
}

