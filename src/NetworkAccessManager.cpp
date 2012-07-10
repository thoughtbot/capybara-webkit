#include "NetworkAccessManager.h"
#include "WebPage.h"
#include <iostream>
#include <fstream>


NetworkAccessManager::NetworkAccessManager(QObject *parent):QNetworkAccessManager(parent) {
  connect(this, SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)), SLOT(provideAuthentication(QNetworkReply*,QAuthenticator*)));
}

QNetworkReply* NetworkAccessManager::createRequest(QNetworkAccessManager::Operation operation, const QNetworkRequest &request, QIODevice * outgoingData = 0) {
  QNetworkRequest new_request(request);
  if (operation != QNetworkAccessManager::PostOperation && operation != QNetworkAccessManager::PutOperation) {
    new_request.setHeader(QNetworkRequest::ContentTypeHeader, QVariant());
  }
  QHashIterator<QString, QString> item(m_headers);
  while (item.hasNext()) {
      item.next();
      new_request.setRawHeader(item.key().toAscii(), item.value().toAscii());
  }
  QNetworkReply *reply = QNetworkAccessManager::createRequest(operation, new_request, outgoingData);
  emit requestCreated(reply);
  return reply;
};

void NetworkAccessManager::addHeader(QString key, QString value) {
  m_headers.insert(key, value);
};

void NetworkAccessManager::resetHeaders() {
  m_headers.clear();
};

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
