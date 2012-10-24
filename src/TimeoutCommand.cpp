#include "TimeoutCommand.h"
#include "Command.h"
#include "WebPageManager.h"
#include "WebPage.h"
#include <QTimer>

TimeoutCommand::TimeoutCommand(Command *command, WebPageManager *manager, QObject *parent) : Command(parent) {
  m_command = command;
  m_manager = manager;
  m_timer = new QTimer(this);
  m_timer->setSingleShot(true);
  connect(m_timer, SIGNAL(timeout()), this, SLOT(commandTimeout()));
  connect(m_manager, SIGNAL(loadStarted()), this, SLOT(pageLoadingFromCommand()));
}

void TimeoutCommand::start() {
  if (m_manager->isLoading()) {
    connect(m_manager, SIGNAL(pageFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
    startTimeout();
  } else {
    startCommand();
  }
}

void TimeoutCommand::startCommand() {
  connect(m_command, SIGNAL(finished(Response *)), this, SLOT(commandFinished(Response *)));
  m_command->start();
}

void TimeoutCommand::startTimeout() {
  int timeout = m_manager->getTimeout();
  if (timeout > 0) {
    m_timer->start(timeout * 1000);
  }
}

void TimeoutCommand::pendingLoadFinished(bool success) {
  if (success) {
    startCommand();
  } else {
    emit finished(new Response(false, m_manager->currentPage()->failureString()));
  }
}

void TimeoutCommand::pageLoadingFromCommand() {
  startTimeout();
}

void TimeoutCommand::commandTimeout() {
  m_manager->currentPage()->triggerAction(QWebPage::Stop);
  m_command->deleteLater();
  emit finished(new Response(false, QString("timeout")));
}

void TimeoutCommand::commandFinished(Response *response) {
  m_command->deleteLater();
  emit finished(response);
}

