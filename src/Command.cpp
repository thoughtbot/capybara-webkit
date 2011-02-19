#include "Command.h"
#include "WebPage.h"

Command::Command(WebPage *page, QObject *parent) : QObject(parent) {
  m_page = page;
}

void Command::receivedArgument(const char *argument) {
  Q_UNUSED(argument);
}

void Command::start() {
}

WebPage *Command::page() {
  return m_page;
}

