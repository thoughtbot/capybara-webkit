#include "Command.h"
#include "WebPage.h"
#include "WebPageManager.h"

Command::Command(WebPageManager *manager, QStringList &arguments, QObject *parent) : QObject(parent) {
  m_manager = manager;
  m_arguments = arguments;
}

void Command::start() {
}

WebPage *Command::page() {
  return m_manager->currentPage();
}

QStringList &Command::arguments() {
  return m_arguments;
}

WebPageManager *Command::manager() {
  return m_manager;
}

