#include "ConsoleMessages.h"
#include "WebPage.h"

ConsoleMessages::ConsoleMessages(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

void ConsoleMessages::start() {
  emit finished(new Response(true, page()->consoleMessages()));
}

