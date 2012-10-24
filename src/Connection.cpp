#include "Connection.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "CommandParser.h"
#include "CommandFactory.h"
#include "PageLoadingCommand.h"
#include "TimeoutCommand.h"
#include "SocketCommand.h"

#include <QTcpSocket>

Connection::Connection(QTcpSocket *socket, WebPageManager *manager, QObject *parent) :
    QObject(parent) {
  m_socket = socket;
  m_manager = manager;
  m_commandFactory = new CommandFactory(m_manager, this);
  m_commandParser = new CommandParser(socket, m_commandFactory, this);
  m_pageSuccess = true;
  connect(m_socket, SIGNAL(readyRead()), m_commandParser, SLOT(checkNext()));
  connect(m_commandParser, SIGNAL(commandReady(Command *)), this, SLOT(commandReady(Command *)));
  connect(m_manager, SIGNAL(pageFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
}

void Connection::commandReady(Command *command) {
  m_queuedCommand = command;
  m_manager->logger() << "Received" << command->toString();
  startCommand();
}

void Connection::startCommand() {
  if (m_pageSuccess) {
    m_runningCommand = new PageLoadingCommand(m_queuedCommand, m_manager, this);
    m_runningCommand = new TimeoutCommand(m_runningCommand, m_manager, this);
    connect(m_runningCommand, SIGNAL(finished(Response *)), this, SLOT(finishCommand(Response *)));
    m_runningCommand->start();
  } else {
    writePageLoadFailure();
  }
}

void Connection::pendingLoadFinished(bool success) {
  m_pageSuccess = m_pageSuccess && success;
}

void Connection::writePageLoadFailure() {
  m_pageSuccess = true;
  QString message = currentPage()->failureString();
  writeResponse(new Response(false, message));
}

void Connection::finishCommand(Response *response) {
  m_pageSuccess = true;
  m_runningCommand->deleteLater();
  writeResponse(response);
}

void Connection::writeResponse(Response *response) {
  if (response->isSuccess())
    m_socket->write("ok\n");
  else
    m_socket->write("failure\n");

  m_manager->logger() << "Wrote response" << response->isSuccess() << response->message();

  QByteArray messageUtf8 = response->message();
  QString messageLength = QString::number(messageUtf8.size()) + "\n";
  m_socket->write(messageLength.toAscii());
  m_socket->write(messageUtf8);
  delete response;
}

WebPage *Connection::currentPage() {
  return m_manager->currentPage();
}
