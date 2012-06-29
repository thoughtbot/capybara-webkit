#include "Command.h"
#include "WebPage.h"
#include "WebPageManager.h"

Command::Command(WebPageManager *manager, QStringList &arguments, QObject *parent) : QObject(parent) {
  m_manager = manager;
  m_arguments = arguments;
}

void Command::start() {
}

QString Command::toString() const {
  return metaObject()->className();
}

WebPage *Command::page() const {
  return m_manager->currentPage();
}

const QStringList &Command::arguments() const {
  return m_arguments;
}

WebPageManager *Command::manager() const {
  return m_manager;
}
