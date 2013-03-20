#include "Connection.h"
#include "WebPageManager.h"
#include "StdinDevice.h"
#include <QApplication>
#include <QFile>
#include <iostream>
#ifdef Q_OS_UNIX
  #include <unistd.h>
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

  WebPageManager manager;
  StdinDevice stdinDevice;
  QFile stdoutDevice;
  stdoutDevice.open(stdout, QIODevice::WriteOnly);

  stdoutDevice.write("Ready\n");
  stdoutDevice.flush();

  Connection connection(&stdinDevice, &stdoutDevice, &manager);

  while (stdinDevice.isOpen()) {
    stdinDevice.checkRead();
    app.processEvents();
  }

  app.sendPostedEvents(NULL, QEvent::DeferredDelete);

  return 0;
}

