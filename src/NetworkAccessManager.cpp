#include "NetworkAccessManager.h"
#include "WebPage.h"
#include <iostream>


NetworkAccessManager::NetworkAccessManager(QObject *parent):QNetworkAccessManager(parent) {
}

QNetworkReply* NetworkAccessManager::createRequest(QNetworkAccessManager::Operation oparation, const QNetworkRequest &request, QIODevice * outgoingData = 0) {
  QNetworkRequest new_request(request);

  // emulate Firefox, allowing to disable certificate
  // verification using an environment variable
  if (!strcmp(getenv("IGNORECERT"), "1")) {
    QSslConfiguration config = request.sslConfiguration();
    config.setPeerVerifyMode(QSslSocket::VerifyNone);
    config.setProtocol(QSsl::TlsV1);
    QNetworkRequest new_request(request);
    new_request.setSslConfiguration(config);
  }

  QHashIterator<QString, QString> item(m_headers);
  while (item.hasNext()) {
      item.next();
      new_request.setRawHeader(item.key().toAscii(), item.value().toAscii());
  }
  QNetworkReply *reply = QNetworkAccessManager::createRequest(oparation, new_request, outgoingData);

  // not sure 100% if this is needed, but just in case
  if (!strcmp(getenv("IGNORECERT"), "1"))
    reply->ignoreSslErrors();

  return reply;
};

void NetworkAccessManager::addHeader(QString key, QString value) {
  m_headers.insert(key, value);
};

