#include "Find.h"
#include "Command.h"
#include "WebPage.h"

Find::Find(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Find::start(QStringList &arguments) {
  QString message;
  QVariant result = page()->invokeCapybaraFunction("find", arguments);

  if (result.isValid()) {
    message = result.toString();
    emit finished(new Response(true, message));
  } else {
    emit finished(new Response(false, "Invalid XPath expression"));
  }
}

