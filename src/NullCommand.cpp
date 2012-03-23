#include "NullCommand.h"
#include "WebPage.h"

NullCommand::NullCommand(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {}

void NullCommand::start() {
  QString failure = QString("[Capybara WebKit] Unknown command: ") + arguments()[0] + "\n";
  emit finished(new Response(false, failure));
}

