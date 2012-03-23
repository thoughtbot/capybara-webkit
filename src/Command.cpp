#include "Command.h"
#include "WebPage.h"

Command::Command(WebPage *page, QStringList &arguments, QObject *parent) : QObject(parent) {
  m_page = page;
  m_arguments = arguments;
}

void Command::start() {
}

WebPage *Command::page() {
  return m_page;
}

QStringList &Command::arguments() {
  return m_arguments;
}

