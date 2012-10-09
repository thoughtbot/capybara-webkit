#include <QTimer.h>
#include "NoOpReply.h"

NoOpReply::NoOpReply(QObject *parent) : QNetworkReply(parent) {
  open(ReadOnly | Unbuffered);
  setAttribute(QNetworkRequest::HttpStatusCodeAttribute, 200);
  setHeader(QNetworkRequest::ContentLengthHeader, QVariant(0));
  setHeader(QNetworkRequest::ContentTypeHeader, QVariant(QString("text/plain")));

  QTimer::singleShot( 0, this, SIGNAL(readyRead()) );
  QTimer::singleShot( 0, this, SIGNAL(finished()) );
}

void NoOpReply::abort() {
  // NO-OP
}

qint64 NoOpReply::bytesAvailable() const {
  return 0;
}

bool NoOpReply::isSequential() const {
  return true;
}

qint64 NoOpReply::readData(char *data, qint64 maxSize) {
  return 0;
}

