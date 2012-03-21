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
  m_runningCommand = NULL;
  m_queuedCommand = NULL;
  m_pageSuccess = true;
  m_commandWaiting = false;
  m_pageLoadingFromCommand = false;
  m_pendingResponse = NULL;
  connect(m_socket, SIGNAL(readyRead()), m_commandParser, SLOT(checkNext()));
  connect(m_commandParser, SIGNAL(commandReady(QString, QStringList)), this, SLOT(commandReady(QString, QStringList)));
  connect(m_page, SIGNAL(pageFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
}


void Connection::commandReady(QString commandName, QStringList arguments) {
  m_queuedCommand = m_commandFactory->createCommand(commandName.toAscii().constData(), arguments);
  if (m_page->isLoading())
    m_commandWaiting = true;
  else
    startCommand();
}

void Connection::startCommand() {
  m_commandWaiting = false;
  if (m_pageSuccess) {
    m_runningCommand = m_queuedCommand;
    m_queuedCommand = NULL;
    connect(m_page, SIGNAL(loadStarted()), this, SLOT(pageLoadingFromCommand()));
    connect(m_runningCommand,
            SIGNAL(finished(Response *)),
            this,
            SLOT(finishCommand(Response *)));
    m_runningCommand->start();
  } else {
    pageLoadFailed();
  }
}

void Connection::pageLoadingFromCommand() {
  m_pageLoadingFromCommand = true;
}

void Connection::pendingLoadFinished(bool success) {
  m_pageSuccess = success;
  if (m_commandWaiting)
    startCommand();
  if (m_pageLoadingFromCommand) {
    m_pageLoadingFromCommand = false;
    if (m_pendingResponse) {
      if (m_pageSuccess) {
        writeResponse(m_pendingResponse);
      } else {
        pageLoadFailed();
      }
    }
  }
}

void Connection::pageLoadFailed() {
  m_pageSuccess = true;
  QString message = m_page->failureString();
  writeResponse(new Response(false, message));
}

void Connection::finishCommand(Response *response) {
  disconnect(m_page, SIGNAL(loadStarted()), this, SLOT(pageLoadingFromCommand()));
  m_runningCommand->deleteLater();
  m_runningCommand = NULL;
  delete m_queuedCommand;
  m_queuedCommand = NULL;
  if (m_pageLoadingFromCommand)
    m_pendingResponse = response;
  else
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
  m_pendingResponse = NULL;
}

