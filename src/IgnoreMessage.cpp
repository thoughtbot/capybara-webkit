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
  bool foundMatch = false;

  for (int i = 0; i < patterns.size(); ++i) {
    QRegExp rx(patterns.at(i));

    if (rx.indexIn(msg) != -1) {
      foundMatch = true;
      break;
    }
  }

  if (!foundMatch) {
    fprintf(stderr, "%s\n", msg);
  }
}
