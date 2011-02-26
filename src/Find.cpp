#include "Find.h"
#include "Command.h"
#include "WebPage.h"

Find::Find(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Find::start(QStringList &arguments) {
  QString response;
  QVariant result = page()->invokeCapybaraFunction("find", arguments);

  if (result.isValid()) {
    response = result.toString();
    emit finished(true, response);
  } else {
    response = "Invalid XPath expression";
    emit finished(false, response);
  }
}

