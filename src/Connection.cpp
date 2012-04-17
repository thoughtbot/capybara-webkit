#include "Connection.h"
#include "WebPage.h"
#include "CommandParser.h"
#include "CommandFactory.h"
#include "PageLoadingCommand.h"
#include "Command.h"

#include <QTcpSocket>

Connection::Connection(QTcpSocket *socket, WebPage *page, QObject *parent) :
    QObject(parent) {
  m_socket = socket;
  m_page = page;
  m_commandFactory = new CommandFactory(page, this);
  m_commandParser = new CommandParser(socket, m_commandFactory, this);
  m_pageSuccess = true;
  m_commandWaiting = false;
  connect(m_socket, SIGNAL(readyRead()), m_commandParser, SLOT(checkNext()));
  connect(m_commandParser, SIGNAL(commandReady(Command *)), this, SLOT(commandReady(Command *)));
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
  } else {
    writePageLoadFailure();
  }
}

void Connection::pendingLoadFinished(bool success) {
  m_pageSuccess = success;
  if (m_commandWaiting)
    startCommand();
}

void Connection::writePageLoadFailure() {
  m_pageSuccess = true;
  QString message = m_page->failureString();
  writeResponse(new Response(false, message));
}

void Connection::finishCommand(Response *response) {
  m_runningCommand->deleteLater();
  writeResponse(response);
}

void Connection::writeResponse(Response *response) {
  if (response->isSuccess())
    m_socket->write("ok\n");
  else
    m_socket->write("failure\n");

  QByteArray messageUtf8 = response->message();
  QString messageLength = QString::number(messageUtf8.size()) + "\n";
  m_socket->write(messageLength.toAscii());
  m_socket->write(messageUtf8);
  delete response;
}

