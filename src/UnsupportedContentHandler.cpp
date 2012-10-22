#include "UnsupportedContentHandler.h"
#include "WebPage.h"
#include <QNetworkReply>

UnsupportedContentHandler::UnsupportedContentHandler(WebPage *page, QNetworkReply *reply, QObject *parent) : QObject(parent) {
  m_page = page;
  m_reply = reply;
}

void UnsupportedContentHandler::renderNonHtmlContent() {
  QByteArray text = m_reply->readAll();
  m_page->mainFrame()->setContent(text, QString("text/plain"), m_reply->url());
  m_page->networkAccessManagerFinishedReply(m_reply);
  m_page->loadFinished(true);
  this->deleteLater();
}

void UnsupportedContentHandler::waitForReplyToFinish() {
  connect(m_reply, SIGNAL(finished()), this, SLOT(replyFinished()));
  disconnect(m_page, SIGNAL(loadFinished(bool)), m_page, SLOT(loadFinished(bool)));
}

void UnsupportedContentHandler::replyFinished() {
  renderNonHtmlContent();
  connect(m_page, SIGNAL(loadFinished(bool)), m_page, SLOT(loadFinished(bool)));
}
