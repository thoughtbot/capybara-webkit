#include "Command.h"
#include "WebPage.h"

Command::Command(WebPage *page, QObject *parent) : QObject(parent) {
  m_page = page;
}

void Command::start(QStringList &arguments) {
  Q_UNUSED(arguments);
}

WebPage *Command::page() {
  return m_page;
}

