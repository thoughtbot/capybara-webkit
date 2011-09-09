#include "NetworkAccessManager.h"
#include "WebPage.h"
#include <iostream>


NetworkAccessManager::NetworkAccessManager(QObject *parent):QNetworkAccessManager(parent) {
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
  return QNetworkAccessManager::createRequest(operation, new_request, outgoingData);
};

void NetworkAccessManager::addHeader(QString key, QString value) {
  m_headers.insert(key, value);
};

