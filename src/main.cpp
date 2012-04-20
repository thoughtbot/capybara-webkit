#include "Server.h"
#include <QtGui>
#include <iostream>
#ifdef Q_OS_UNIX
  #include <unistd.h>
#endif

static int readBlackList(QStringList args, QStringList & blacklist) {
  int returnCode = 1;

  if (args.contains("--blacklist-file")) {
    int fileNameIndex = args.indexOf("--blacklist-file") + 1;
    if (fileNameIndex < args.size()) {
      QString fileName = args.at(fileNameIndex);
      QFile file(fileName);
      if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString line = in.readLine();
        while (!line.isNull()) {
          blacklist << line;
          line = in.readLine();
        }
      } else {
        std::cerr << "Unable to read blacklist file at " << qPrintable(fileName) << std::endl;
        returnCode = 0;
      }
    }
  }

  return returnCode;
}

int main(int argc, char **argv) {
#ifdef Q_OS_UNIX
  if (setpgid(0, 0) < 0) {
    std::cerr << "Unable to set new process group." << std::endl;
    return 1;
  }
#endif

  QApplication app(argc, argv);
  app.setApplicationName("capybara-webkit");
  app.setOrganizationName("thoughtbot, inc");
  app.setOrganizationDomain("thoughtbot.com");

  QStringList args = app.arguments();
  bool ignoreSslErrors = args.contains("--ignore-ssl-errors");
  bool skipImageLoading = args.contains("--skip-image-loading");

  QStringList blacklist;
  if (!readBlackList(args, blacklist)) {
    return 1;
  }

  Server server(0, ignoreSslErrors, skipImageLoading, blacklist);

  if (server.start()) {
    std::cout << "Capybara-webkit server started, listening on port: " << server.server_port() << std::endl;
    return app.exec();
  } else {
    std::cerr << "Couldn't start capybara-webkit server" << std::endl;
    return 1;
  }
}

