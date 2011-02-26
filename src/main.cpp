#include "Server.h"
#include <QtGui>
#include <iostream>

int main(int argc, char **argv) {
  QApplication app(argc, argv);
  app.setApplicationName("capybara-webkit");
  app.setOrganizationName("thoughtbot, inc");
  app.setOrganizationDomain("thoughtbot.com");

  Server server;

  if (server.start()) {
    return app.exec();
  } else {
    std::cerr << "Couldn't start server" << std::endl;
    return 1;
  }
}

