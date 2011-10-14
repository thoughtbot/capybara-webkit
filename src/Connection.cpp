#include "Connection.h"
#include "WebPage.h"
#include "UnsupportedContentHandler.h"
#include "CommandParser.h"
#include "CommandFactory.h"
#include "Command.h"

#include <QTcpSocket>
#include <iostream>

Connection::Connection(QTcpSocket *socket, WebPage *page, QObject *parent) :
    QObject(parent) {
  m_socket = socket;
  m_page = page;
  m_commandParser = new CommandParser(socket, this);
  m_commandFactory = new CommandFactory(page, this);
  m_command = NULL;
  m_pageSuccess = true;
  m_commandWaiting = false;
  connect(m_socket, SIGNAL(readyRead()), m_commandParser, SLOT(checkNext()));
  connect(m_commandParser, SIGNAL(commandReady(QString, QStringList)), this, SLOT(commandReady(QString, QStringList)));
  connect(m_page, SIGNAL(pageFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
}


void Connection::commandReady(QString commandName, QStringList arguments) {
  m_commandName = commandName;
  m_arguments = arguments;

  if (m_page->isLoading())
    m_commandWaiting = true;
  else
    startCommand();
}

void Connection::startCommand() {
  m_commandWaiting = false;
  if (m_pageSuccess) {
    m_command = m_commandFactory->createCommand(m_commandName.toAscii().constData());
    if (m_command) {
      connect(m_command,
              SIGNAL(finished(Response *)),
              this,
              SLOT(finishCommand(Response *)));
      m_command->start(m_arguments);
    } else {
      QString failure = QString("[Capybara WebKit] Unknown command: ") +  m_commandName + "\n";
      writeResponse(new Response(false, failure));
    }
    m_commandName = QString();
  } else {
    m_pageSuccess = true;
    QString message = m_page->failureString();
    writeResponse(new Response(false, message));
  }
}

void Connection::pendingLoadFinished(bool success) {
  m_pageSuccess = success;
  if (m_commandWaiting)
    startCommand();
}

void Connection::finishCommand(Response *response) {
  m_command->deleteLater();
  m_command = NULL;
  writeResponse(response);
}

void Connection::writeResponse(Response *response) {
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

