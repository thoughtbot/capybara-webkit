#include "Server.h"
#include "WebPage.h"
#include "Connection.h"

#include <QTcpServer>

#include <cerrno>

Server::Server(QObject *parent) : QObject(parent) {
  m_tcp_server = new QTcpServer(this);
  m_page = new WebPage(this);
}

bool Server::start() {
  unsigned short port = 9200;
  long l;
  char *env_port = getenv("CAPYBARA_WEBKIT_PORT");

  connect(m_tcp_server, SIGNAL(newConnection()), this, SLOT(handleConnection()));

  if (env_port) {
    errno = 0;
    l = strtol(env_port, NULL, 10); // Base 10
    if (errno == 0) {
      port = l;
    }
  }
  printf("Starting webkit on port %hu.\n", port);

  return m_tcp_server->listen(QHostAddress::Any, port);
}

void Server::handleConnection() {
  QTcpSocket *socket = m_tcp_server->nextPendingConnection();
  new Connection(socket, m_page, this);
}

