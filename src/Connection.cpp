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

#include <QTcpSocket>
#include <iostream>

Connection::Connection(QTcpSocket *socket, WebPage *page, QObject *parent) :
    QObject(parent) {
  m_socket = socket;
  m_page = page;
  m_command = NULL;
  m_expectingDataSize = -1;
  connect(m_socket, SIGNAL(readyRead()), this, SLOT(checkNext()));
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
  delete buffer;
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
      connect(m_page, SIGNAL(loadFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
    else
      startCommand();
  }
}

void Connection::startCommand() {
  m_command = createCommand(m_commandName.toAscii().constData());
  if (m_command) {
    connect(m_command,
            SIGNAL(finished(bool, QString &)),
            this,
            SLOT(finishCommand(bool, QString &)));
    m_command->start(m_arguments);
  } else {
    QString failure = QString("Unknown command: ") +  m_commandName + "\n";
    writeResponse(false, failure);
  }
  m_commandName = QString();
}

Command *Connection::createCommand(const char *name) {
  #include "find_command.h"
  return NULL;
}

void Connection::pendingLoadFinished(bool success) {
  m_page->disconnect(this, SLOT(pendingLoadFinished(bool)));
  if (success) {
    startCommand();
  } else {
    QString response = m_page->failureString();
    finishCommand(false, response);
  }
}

void Connection::finishCommand(bool success, QString &response) {
  m_command->deleteLater();
  m_command = NULL;
  m_arguments.clear();
  writeResponse(success, response);
}

void Connection::writeResponse(bool success, QString &response) {
  if (success)
    m_socket->write("ok\n");
  else
    m_socket->write("failure\n");

  QByteArray response_utf8 = response.toUtf8();
  QString responseLength = QString::number(response_utf8.size()) + "\n";
  m_socket->write(responseLength.toAscii());
  m_socket->write(response_utf8);
}

