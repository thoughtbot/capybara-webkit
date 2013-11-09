#include "Server.h"
#include <QApplication>
#include <iostream>
#ifdef Q_OS_UNIX
  #include <unistd.h>
#endif

void ignoreDebugOutput(QtMsgType type, const char *msg);

#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
  void ignoreDebugOutputQt5(QtMsgType type, const QMessageLogContext &context, const QString &message);
#endif

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

#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
  qInstallMessageHandler(ignoreDebugOutputQt5);
#else
  qInstallMsgHandler(ignoreDebugOutput);
#endif

  Server server(0);

  if (server.start()) {
    std::cout << "Capybara-webkit server started, listening on port: " << server.server_port() << std::endl;
    return app.exec();
  } else {
    std::cerr << "Couldn't start capybara-webkit server" << std::endl;
    return 1;
  }
}

void ignoreDebugOutput(QtMsgType type, const char *msg) {
  switch (type) {
    case QtDebugMsg:
    case QtWarningMsg:
      break;
    default:
      fprintf(stderr, "%s\n", msg);
      break;
  }
}

#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
  void ignoreDebugOutputQt5(QtMsgType type, const QMessageLogContext &context, const QString &message) {
    Q_UNUSED(context);
    ignoreDebugOutput(type, message.toLocal8Bit().data());
  }
#endif
