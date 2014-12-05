#include "UnsupportedContentHandler.h"
#include "UnsupportedContentReply.h"

UnsupportedContentHandler::UnsupportedContentHandler(
  QWebPage *page,
  QObject *parent
) : QObject(parent) {
  m_page = page;

  connect(
    page,
    SIGNAL(unsupportedContent(QNetworkReply*)),
    SLOT(unsupportedContent(QNetworkReply*))
  );
}

void UnsupportedContentHandler::unsupportedContent(QNetworkReply *reply) {
  QVariant contentMimeType = reply->header(QNetworkRequest::ContentTypeHeader);
  if(!contentMimeType.isNull()) {
    m_page->triggerAction(QWebPage::Stop);
    UnsupportedContentReply *unsupportedReply =
      new UnsupportedContentReply(reply, reply);
    connect(
      unsupportedReply,
      SIGNAL(replyFinished(QNetworkReply *, QByteArray &)),
      SLOT(renderReply(QNetworkReply *, QByteArray &))
    );
    unsupportedReply->send();
  }
}

void UnsupportedContentHandler::renderReply(
  QNetworkReply *reply,
  QByteArray &text
) {
  m_page->mainFrame()->setContent(text, QString("text/plain"), reply->url());
  emit replyFinished(reply);
}
