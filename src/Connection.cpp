#include "Connection.h"
#include "Visit.h"
#include "Find.h"
#include "Command.h"
#include "Reset.h"
#include "Node.h"
#include "Url.h"
#include "Source.h"
#include "Evaluate.h"

#include <QTcpSocket>
#include <iostream>

Connection::Connection(QTcpSocket *socket, WebPage *page, QObject *parent) :
    QObject(parent) {
  m_socket = socket;
  m_page = page;
  m_command = NULL;
  connect(m_socket, SIGNAL(readyRead()), this, SLOT(checkNext()));
}

void Connection::checkNext() {
  while (m_socket->canReadLine()) {
    readNext();
  }
}

void Connection::readNext() {
  char buffer[1024];
  qint64 lineLength = m_socket->readLine(buffer, 1024);
  if (lineLength != -1) {
    buffer[lineLength - 1] = 0;
    processLine(buffer);
  }
}

void Connection::processLine(const char *line) {
  if (m_command) {
    continueCommand(line);
  } else {
    m_command = createCommand(line);
    if (m_command) {
      std::cout << "Starting command: " << line << std::endl;
      startCommand();
    } else {
      m_socket->write("bad command\n");
    }
  }
}

Command *Connection::createCommand(const char *name) {
  #include "find_command.h"
  return NULL;
}

void Connection::startCommand() {
  m_argumentsExpected = -1;
  connect(m_command,
          SIGNAL(finished(bool, QString &)),
          this,
          SLOT(finishCommand(bool, QString &)));
}

void Connection::continueCommand(const char *line) {
  if (m_argumentsExpected == -1) {
    m_argumentsExpected = QString(line).toInt();
  } else {
    m_arguments.append(line);
  }

  if (m_arguments.length() == m_argumentsExpected) {
    m_command->start(m_arguments);
  }
}

void Connection::finishCommand(bool success, QString &response) {
  m_command->deleteLater();
  m_command = NULL;
  m_arguments.clear();
  std::cout << "Finished command" << std::endl;
  if (success) {
    m_socket->write("ok\n");
  } else {
    m_socket->write("failure\n");
  }
  QString responseLength = QString::number(response.size()) + "\n";
  m_socket->write(responseLength.toAscii());
  m_socket->write(response.toAscii());
}

