#include "NullCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"

NullCommand::NullCommand(QString name, QObject *parent) : Command(parent) {
  m_name = name;
}

void NullCommand::start() {
  QString failure = QString("[Capybara WebKit] Unknown command: ") + m_name + "\n";
  emit finished(new Response(false, failure));
}

