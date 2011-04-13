#include "Execute.h"
#include "WebPage.h"

Execute::Execute(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Execute::start(QStringList &arguments) {
  QString script = arguments[0] + QString("; 'success'");
  QVariant result = page()->mainFrame()->evaluateJavaScript(script);
  QString response;
  if (result.isValid()) {
    emit finished(true, response);
  } else {
    response = "Javascript failed to execute";
    emit finished(false, response);
  }
}

