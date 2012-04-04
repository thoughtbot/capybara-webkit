#include "Connection.h"
#include "WebPage.h"
#include "CommandParser.h"
#include "CommandFactory.h"
#include "PageLoadingCommand.h"
#include "Command.h"

#include <QTcpSocket>
#include <QTimer>
#include <iostream> 

Connection::Connection(QTcpSocket *socket, WebPage *page, QObject *parent) :
    QObject(parent) {
  m_socket = socket;
  m_page = page;
  m_commandFactory = new CommandFactory(page, this);
  m_commandParser = new CommandParser(socket, m_commandFactory, this);
  m_pageSuccess = true;
  m_commandWaiting = false;
  m_commandTimedOut = false;

  m_timer = new QTimer(this);
  m_timer->setSingleShot(true);
  connect(m_timer, SIGNAL(timeout()), this, SLOT(pageLoadTimeout()));

  connect(m_socket, SIGNAL(readyRead()), m_commandParser, SLOT(checkNext()));
  connect(m_commandParser, SIGNAL(commandReady(Command *)), this, SLOT(commandReady(Command *)));
  connect(m_page, SIGNAL(loadStarted()), this, SLOT(pageLoadStarted()));
  connect(m_page, SIGNAL(pageFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
}

void Connection::commandReady(Command *command) {
  m_queuedCommand = command;
  if (m_page->isLoading())
    m_commandWaiting = true;
  else
    startCommand();
}

void Connection::startCommand() {
  m_commandWaiting = false;
  if (m_pageSuccess) {
    m_runningCommand = new PageLoadingCommand(m_queuedCommand, m_page, this);
    connect(m_runningCommand, SIGNAL(finished(Response *)), this, SLOT(finishCommand(Response *)));
    m_runningCommand->start();
  } else if (m_commandTimedOut) {
    writeCommandTimeout();
  } else {
    writePageLoadFailure();
  }
}

void Connection::pageLoadStarted() {
  int timeout = m_page->getTimeout();
  if (timeout > 0) {
    m_timer->start(timeout * 1000);
  }
}

void Connection::pendingLoadFinished(bool success) {
  m_timer->stop();
  m_pageSuccess = success;
  if (m_commandWaiting)
    startCommand();
  else if (m_commandTimedOut)
    writeCommandTimeout();
}

void Connection::pageLoadTimeout() {
  m_commandTimedOut = true;

  if (m_runningCommand) {
    disconnect(m_runningCommand, SIGNAL(finished(Response *)), this, SLOT(finishCommand(Response *)));
    m_runningCommand->deleteLater();
    m_runningCommand = NULL;
  }

  m_page->triggerAction(QWebPage::Stop);
}

void Connection::finishCommand(Response *response) {
  if (m_runningCommand) {
    m_runningCommand->deleteLater();
    m_runningCommand = NULL;
  }
  writeResponse(response);
}

void Connection::writeResponse(Response *response) {
  m_pageSuccess = true;
  m_commandTimedOut = false;

  if (response->isSuccess())
    m_socket->write("ok\n");
  else
    m_socket->write("failure\n");

  QByteArray messageUtf8 = response->message().toUtf8();
  QString messageLength = QString::number(messageUtf8.size()) + "\n";
  m_socket->write(messageLength.toAscii());
  m_socket->write(messageUtf8);
  delete response;
}

void Connection::writePageLoadFailure() {
  QString message = m_page->failureString();
  writeResponse(new Response(false, message));
}

void Connection::writeCommandTimeout() {
  writeResponse(new Response(false, "timeout"));
}
