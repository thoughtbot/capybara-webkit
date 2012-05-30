#include "Find.h"
#include "Command.h"
#include "WebPage.h"
#include "WebPageManager.h"

Find::Find(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void Find::start() {
  QString message;
  QVariant result = page()->invokeCapybaraFunction("find", arguments());

  if (result.isValid()) {
    message = result.toString();
    emit finished(new Response(true, message));
  } else {
    emit finished(new Response(false, QString("Invalid XPath expression")));
  }
}

