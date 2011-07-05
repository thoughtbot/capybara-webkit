#include "Server.h"
#include <QtGui>
#include <iostream>

int main(int argc, char **argv) {
  int port = 8200;
  QApplication app(argc, argv);
  app.setApplicationName("capybara-webkit");
  app.setOrganizationName("thoughtbot, inc");
  app.setOrganizationDomain("thoughtbot.com");

  Server server;

  if (argc > 1) {
    port = atoi(argv[1]);
  }

  if (server.start(port)) {
    return app.exec();
  } else {
    std::cerr << "Couldn't start server" << std::endl;
    return 1;
  }
}

