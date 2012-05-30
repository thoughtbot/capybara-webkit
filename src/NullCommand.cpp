#include "NullCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"

NullCommand::NullCommand(WebPageManager *manager, QStringList &arguments, QObject *parent) : Command(manager, arguments, parent) {}

void NullCommand::start() {
  QString failure = QString("[Capybara WebKit] Unknown command: ") + arguments()[0] + "\n";
  emit finished(new Response(false, failure));
}

