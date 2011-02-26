#include "Execute.h"
#include "WebPage.h"

Execute::Execute(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Execute::start(QStringList &arguments) {
  QVariant result = page()->mainFrame()->evaluateJavaScript(arguments[0]);
  QString response;
  if (result.isValid()) {
    emit finished(true, response);
  } else {
    response = "Javascript failed to execute";
    emit finished(false, response);
  }
}

