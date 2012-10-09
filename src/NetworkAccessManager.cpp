#include "NetworkAccessManager.h"
#include "WebPage.h"
#include <iostream>
#include <fstream>
#include "NoOpReply.h"

NetworkAccessManager::NetworkAccessManager(QObject *parent):QNetworkAccessManager(parent) {
  connect(this, SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)), SLOT(provideAuthentication(QNetworkReply*,QAuthenticator*)));
  connect(this, SIGNAL(finished(QNetworkReply *)), this, SLOT(finished(QNetworkReply *)));
}

QNetworkReply* NetworkAccessManager::createRequest(QNetworkAccessManager::Operation operation, const QNetworkRequest &request, QIODevice * outgoingData = 0) {
  QNetworkRequest new_request(request);
  QByteArray url = new_request.url().toEncoded();
  if (this->isBlacklisted(new_request.url())) {
    return this->noOpRequest();
  } else {
    if (operation != QNetworkAccessManager::PostOperation && operation != QNetworkAccessManager::PutOperation) {
      new_request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant());
    }
    QHashIterator<QString, QString> item(m_headers);
    while (item.hasNext()) {
        item.next();
        new_request.setRawHeader(item.key().toAscii(), item.value().toAscii());
    }
    QNetworkReply *reply = QNetworkAccessManager::createRequest(operation, new_request, outgoingData);
    emit requestCreated(url, reply);
    return reply;
  }
};

void NetworkAccessManager::finished(QNetworkReply *reply) {
  NetworkResponse response;
  response.statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  response.headers = reply->rawHeaderPairs();
  m_responses[reply->url()] = response;
}

void NetworkAccessManager::addHeader(QString key, QString value) {
  m_headers.insert(key, value);
}

void NetworkAccessManager::resetHeaders() {
  m_headers.clear();
}

void NetworkAccessManager::setUserName(const QString &userName) {
  m_userName = userName;
}

void NetworkAccessManager::setPassword(const QString &password) {
  m_password = password;
}

void NetworkAccessManager::provideAuthentication(QNetworkReply *reply, QAuthenticator *authenticator) {
  Q_UNUSED(reply);
  authenticator->setUser(m_userName);
  authenticator->setPassword(m_password);
}

int NetworkAccessManager::statusFor(QUrl url) {
  return m_responses[url].statusCode;
}

const QList<QNetworkReply::RawHeaderPair> &NetworkAccessManager::headersFor(QUrl url) {
  return m_responses[url].headers;
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

QNetworkReply* NetworkAccessManager::noOpRequest() {
  return new NoOpReply();
};

