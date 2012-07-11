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
  this->renderNonHtmlContent();
  this->finish();
  this->deleteLater();
}

void UnsupportedContentHandler::renderNonHtmlContent() {
    QByteArray text = m_reply->readAll();
    m_page->mainFrame()->setContent(text, QString("text/plain"), m_reply->url());
}

void UnsupportedContentHandler::finish() {
    connect(m_page, SIGNAL(loadFinished(bool)), m_page, SLOT(loadFinished(bool)));
    m_page->networkAccessManagerFinishedReply(m_reply);
    m_page->loadFinished(true);
}
