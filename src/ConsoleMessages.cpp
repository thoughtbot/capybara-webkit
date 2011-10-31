#include "ConsoleMessages.h"
#include "WebPage.h"

ConsoleMessages::ConsoleMessages(WebPage *page, QObject *parent) : Command(page, parent) {
}

void ConsoleMessages::start(QStringList &arguments) {
  Q_UNUSED(arguments);
  emit finished(new Response(true, page()->consoleMessages()));
}

