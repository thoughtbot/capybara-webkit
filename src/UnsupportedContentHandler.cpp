#include "UnsupportedContentHandler.h"
#include "WebPage.h"
#include <QNetworkReply>

UnsupportedContentHandler::UnsupportedContentHandler(WebPage *page, QNetworkReply *reply, QObject *parent) : QObject(parent) {
  m_page = page;
  m_reply = reply;
  connect(m_reply, SIGNAL(finished()), this, SLOT(handleUnsupportedContent()));
  disconnect(m_page, SIGNAL(loadFinished(bool)), m_page, SLOT(loadFinished(bool)));
}

void UnsupportedContentHandler::handleUnsupportedContent() {
  QVariant contentMimeType = m_reply->header(QNetworkRequest::ContentTypeHeader);
  if(contentMimeType.isNull()) {
    this->finish(false);
  } else {
    this->loadUnsupportedContent();
    this->finish(true);
  }
  this->deleteLater();
}

void UnsupportedContentHandler::loadUnsupportedContent() {
    QByteArray text = m_reply->readAll();
    m_page->mainFrame()->setContent(text, QString("text/plain"), m_reply->url());
}

void UnsupportedContentHandler::finish(bool success) {
    connect(m_page, SIGNAL(loadFinished(bool)), m_page, SLOT(loadFinished(bool)));
    m_page->replyFinished(m_reply);
    m_page->loadFinished(success);
}
