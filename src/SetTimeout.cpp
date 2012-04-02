#include "SetTimeout.h"
#include "WebPage.h"

SetTimeout::SetTimeout(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void SetTimeout::start() {
  QString timeoutString = arguments()[0];
  bool ok;
  int timeout = timeoutString.toInt(&ok);

  if (ok) {
  	page()->setTimeout(timeout);
  	emit finished(new Response(true));
  } else {
  	emit finished(new Response(false, "Invalid value for timeout"));
  }
}
