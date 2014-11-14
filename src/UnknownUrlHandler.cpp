#include "UnknownUrlHandler.h"
#include "NetworkReplyProxy.h"
#include "NoOpReply.h"

UnknownUrlHandler::UnknownUrlHandler(
  RequestHandler *next,
  QObject *parent
) : RequestHandler(parent) {
  m_next = next;
  m_allowedUrls.append(QString("127.0.0.1"));
  m_allowedUrls.append(QString("localhost"));
  m_mode = WARN;
}

QNetworkReply* UnknownUrlHandler::handleRequest(
  NetworkAccessManager *manager,
  QNetworkAccessManager::Operation operation,
  QNetworkRequest &request,
  QIODevice *outgoingData
) {
  QUrl url(request.url());
  if (this->isUnknown(url)) {
    switch(m_mode) {
      case WARN:
        QTextStream(stderr) <<
           "Unexpected request: " << url.toString() << endl <<
           "To block unknown requests:" << endl <<
           "  page.driver.block_unknown_requests" << endl <<
           "To allow just this request:" << endl <<
           "  page.driver.allow_url(\"" << url.toString() << "\")" << endl <<
           "To allow allow requests from this host:" << endl <<
           "  page.driver.allow_url(\"" << url.host() << "\")" << endl;
        break;
      case BLOCK:
        return new NetworkReplyProxy(new NoOpReply(request), this);
    }
  }

  return m_next->handleRequest(manager, operation, request, outgoingData);
}

void UnknownUrlHandler::allowUrl(const QString &url) {
  m_allowedUrls << url;
}

void UnknownUrlHandler::setMode(Mode mode) {
  m_mode = mode;
}

bool UnknownUrlHandler::isUnknown(QUrl url) {
  QStringListIterator iterator(m_allowedUrls);
  QString urlString = url.toString();

  while (iterator.hasNext()) {
    QRegExp allowedUrl = QRegExp(iterator.next());
    allowedUrl.setPatternSyntax(QRegExp::Wildcard);

    if(urlString.contains(allowedUrl)) {
      return false;
    }
  }

  return true;
}
