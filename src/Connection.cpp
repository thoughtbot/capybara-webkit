#include "Connection.h"
#include "WebPage.h"
#include "Visit.h"
#include "Find.h"
#include "Command.h"
#include "Reset.h"
#include "Node.h"
#include "Url.h"
#include "Source.h"
#include "Evaluate.h"
#include "Execute.h"
#include "FrameFocus.h"
#include "Header.h"
#include "Render.h"
#include "Body.h"
#include "Status.h"
#include "Headers.h"

#include <QTcpSocket>
#include <iostream>

Connection::Connection(QTcpSocket *socket, WebPage *page, QObject *parent) :
    QObject(parent) {
  m_socket = socket;
  m_page = page;
  m_command = NULL;
  m_expectingDataSize = -1;
  m_pageSuccess = true;
  m_commandWaiting = false;
  connect(m_socket, SIGNAL(readyRead()), this, SLOT(checkNext()));
  connect(m_page, SIGNAL(loadFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
}

void Connection::checkNext() {
  if (m_expectingDataSize == -1) {
    if (m_socket->canReadLine()) {
      readLine();
      checkNext();
    }
  } else {
    if (m_socket->bytesAvailable() >= m_expectingDataSize) {
      readDataBlock();
      checkNext();
    }
  }
}

void Connection::readLine() {
  char buffer[128];
  qint64 lineLength = m_socket->readLine(buffer, 128);
  if (lineLength != -1) {
    buffer[lineLength - 1] = 0;
    processNext(buffer);
  }
}

void Connection::readDataBlock() {
  char *buffer = new char[m_expectingDataSize + 1];
  m_socket->read(buffer, m_expectingDataSize);
  buffer[m_expectingDataSize] = 0;
  processNext(buffer);
  m_expectingDataSize = -1;
  delete[] buffer;
}

void Connection::processNext(const char *data) {
  if (m_commandName.isNull()) {
    m_commandName = data;
    m_argumentsExpected = -1;
  } else {
    processArgument(data);
  }
}

void Connection::processArgument(const char *data) {
  if (m_argumentsExpected == -1) {
    m_argumentsExpected = QString(data).toInt();
  } else if (m_expectingDataSize == -1) {
    m_expectingDataSize = QString(data).toInt();
  } else {
    m_arguments.append(QString::fromUtf8(data));
  }

  if (m_arguments.length() == m_argumentsExpected) {
    if (m_page->isLoading())
      m_commandWaiting = true;
    else
      startCommand();
  }
}

void Connection::startCommand() {
  m_commandWaiting = false;
  if (m_pageSuccess) {
    m_command = createCommand(m_commandName.toAscii().constData());
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

Command *Connection::createCommand(const char *name) {
  #include "find_command.h"
  return NULL;
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

  m_arguments.clear();
  m_commandName = QString();
  m_argumentsExpected = -1;
}

