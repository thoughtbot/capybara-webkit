#include "UnsupportedContentReply.h"
#include <QNetworkReply>

UnsupportedContentReply::UnsupportedContentReply(
  QNetworkReply *reply,
  QObject *parent
) : QObject(parent) {
  m_reply = reply;
}

void UnsupportedContentReply::send() {
  if (m_reply->isFinished())
    readReply();
  else
    readReplyWhenFinished();
}

void UnsupportedContentReply::readReply() {
  QByteArray text = m_reply->readAll();
  emit replyFinished(m_reply, text);
}

void UnsupportedContentReply::readReplyWhenFinished() {
  connect(m_reply, SIGNAL(finished()), SLOT(readReply()));
}
