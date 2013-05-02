#include "SocketCommand.h"

Command::Command(QObject *parent) : QObject(parent) {
}

QString Command::toString() const {
  return metaObject()->className();
}

void Command::emitFinished(bool success) {
  emit finished(new Response(success, this));
}

void Command::emitFinished(bool success, QString message) {
  emit finished(new Response(success, message, this));
}

void Command::emitFinished(bool success, QByteArray message) {
  emit finished(new Response(success, message, this));
}

