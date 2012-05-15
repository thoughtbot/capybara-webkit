#include "Reset.h"
#include "WebPage.h"
#include "WebPageManager.h"

Reset::Reset(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {
}

void Reset::start() {
  page()->triggerAction(QWebPage::Stop);

  manager()->reset();

  emit finished(new Response(true));
}

