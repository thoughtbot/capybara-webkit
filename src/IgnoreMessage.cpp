#include "IgnoreMessage.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include <QRegExp>

IgnoreMessage::IgnoreMessage(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void IgnoreMessage::start() {
  patterns << arguments()[0];
  qInstallMsgHandler(messageHandler);
  finish(true);
}

QStringList IgnoreMessage::patterns = QStringList();

void IgnoreMessage::messageHandler(QtMsgType type, const char *msg) {
  if (shouldPrintMessage(msg)) {
    fprintf(stderr, "%s\n", msg);
  }
}

bool IgnoreMessage::shouldPrintMessage(const char *msg) {
  for (int i = 0; i < patterns.size(); ++i) {
    if (matchesPattern(patterns.at(i), msg)) {
      return false;
    }
  }

  return true;
}

bool IgnoreMessage::matchesPattern(QString pattern, const char *msg) {
  QRegExp regex(pattern);

  return regex.indexIn(msg) != -1;
}
