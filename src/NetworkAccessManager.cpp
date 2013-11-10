#include "NetworkAccessManager.h"
#include "WebPage.h"
#include <iostream>
#include <fstream>
#include "NoOpReply.h"
#include "NetworkReplyProxy.h"

NetworkAccessManager::NetworkAccessManager(QObject *parent):QNetworkAccessManager(parent) {
  connect(this, SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)), SLOT(provideAuthentication(QNetworkReply*,QAuthenticator*)));
  connect(this, SIGNAL(finished(QNetworkReply *)), this, SLOT(finished(QNetworkReply *)));
  disableKeyChainLookup();
}

QNetworkReply* NetworkAccessManager::createRequest(QNetworkAccessManager::Operation operation, const QNetworkRequest &request, QIODevice * outgoingData = 0) {
  QNetworkRequest new_request(request);
  QByteArray url = new_request.url().toEncoded();
  if (this->isBlacklisted(new_request.url())) {
    return new NetworkReplyProxy(new NoOpReply(new_request), this);
  } else {
    if (operation != QNetworkAccessManager::PostOperation && operation != QNetworkAccessManager::PutOperation) {
      new_request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant());
    }
    QHashIterator<QString, QString> item(m_headers);
    while (item.hasNext()) {
        item.next();
        new_request.setRawHeader(item.key().toLatin1(), item.value().toLatin1());
    }
    QNetworkReply *reply = new NetworkReplyProxy(QNetworkAccessManager::createRequest(operation, new_request, outgoingData), this);
    emit requestCreated(url, reply);
    return reply;
  }
};

void NetworkAccessManager::finished(QNetworkReply *reply) {
  QUrl redirectUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
  if (redirectUrl.isValid())
    m_redirectMappings[reply->url().resolved(redirectUrl)] = reply->url();
  else {
    QUrl requestedUrl = reply->url();
    while (m_redirectMappings.contains(requestedUrl))
      requestedUrl = m_redirectMappings.take(requestedUrl);
    emit finished(requestedUrl, reply);
  }
}

void NetworkAccessManager::addHeader(QString key, QString value) {
  m_headers.insert(key, value);
}

void NetworkAccessManager::reset() {
  m_headers.clear();
  m_userName = QString();
  m_password = QString();
}

void NetworkAccessManager::setUserName(const QString &userName) {
  m_userName = userName;
}

void NetworkAccessManager::setPassword(const QString &password) {
  m_password = password;
}

void NetworkAccessManager::provideAuthentication(QNetworkReply *reply, QAuthenticator *authenticator) {
  Q_UNUSED(reply);
  if (m_userName != authenticator->user()) 
    authenticator->setUser(m_userName);
  if (m_password != authenticator->password())
    authenticator->setPassword(m_password);
}

void NetworkAccessManager::setUrlBlacklist(QStringList urlBlacklist) {
  m_urlBlacklist.clear();

  QStringListIterator iter(urlBlacklist);
  while (iter.hasNext()) {
    m_urlBlacklist << QUrl(iter.next());
  }
};

bool NetworkAccessManager::isBlacklisted(QUrl url) {
  QListIterator<QUrl> iter(m_urlBlacklist);

  while (iter.hasNext()) {
    QUrl blacklisted = iter.next();

    if (blacklisted == url) {
      return true;
    } else if (blacklisted.path().isEmpty() && blacklisted.isParentOf(url)) {
      return true;
    }
  }

  return false;
};

/*
 * This is a workaround for a Qt 5/OS X bug:
 * https://bugreports.qt-project.org/browse/QTBUG-30434
 */
void NetworkAccessManager::disableKeyChainLookup() {
  QNetworkProxy fixedProxy = proxy();
  fixedProxy.setHostName(" ");
  setProxy(fixedProxy);
}
