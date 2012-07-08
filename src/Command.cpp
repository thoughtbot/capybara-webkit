#include "SocketCommand.h"

Command::Command(QObject *parent) : QObject(parent) {
}

QString Command::toString() const {
  return metaObject()->className();
}
