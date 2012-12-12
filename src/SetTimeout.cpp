#include "SetTimeout.h"
#include "WebPageManager.h"

SetTimeout::SetTimeout(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void SetTimeout::start() {
  QString timeoutString = arguments()[0];
  bool ok;
  int timeout = timeoutString.toInt(&ok);

  if (ok) {
    manager()->setTimeout(timeout);
    emitFinished(true);
  } else {
    emitFinished(false, QString("Invalid value for timeout"));
  }
}

