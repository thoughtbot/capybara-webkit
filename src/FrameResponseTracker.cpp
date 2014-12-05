#include "FrameResponseTracker.h"
#include "NetworkReplyProxy.h"

FrameResponseTracker::FrameResponseTracker(
  QNetworkAccessManager *networkAccessManager,
  QWebFrame *frame,
  QObject *parent
) : QObject(parent) {
  m_frame = frame;
  m_networkAccessManager = networkAccessManager;

  connect(
    m_networkAccessManager,
    SIGNAL(finished(QUrl &, QNetworkReply *)),
    SLOT(replyFinished(QUrl &, QNetworkReply *))
  );
}

void FrameResponseTracker::replyFinished(QUrl &requestedUrl, QNetworkReply *reply) {
  NetworkReplyProxy *proxy = qobject_cast<NetworkReplyProxy *>(reply);
  setFrameProperties(m_frame, requestedUrl, proxy);
  foreach(QWebFrame *frame, m_frame->childFrames())
    setFrameProperties(frame, requestedUrl, proxy);
}

void FrameResponseTracker::setFrameProperties(
  QWebFrame *frame,
  QUrl &requestedUrl,
  NetworkReplyProxy *reply
) {
  if (frame->requestedUrl() == requestedUrl) {
    int statusCode =
      reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    frame->setProperty("statusCode", statusCode);

    QStringList headers;
    foreach(QNetworkReply::RawHeaderPair header, reply->rawHeaderPairs())
      headers << header.first+": "+header.second;
    frame->setProperty("headers", headers);

    frame->setProperty("body", reply->data());

    QVariant contentMimeType =
      reply->header(QNetworkRequest::ContentTypeHeader);
    frame->setProperty("contentType", contentMimeType);
  }
}
