#include "NetworkAccessManager.h"
#include "WebPage.h"
#include <iostream>


NetworkAccessManager::NetworkAccessManager(QObject *parent):QNetworkAccessManager(parent) {
}

QNetworkReply* NetworkAccessManager::createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &req, QIODevice * outgoingData = 0) {
  QNetworkRequest new_req(req);
  QHashIterator<QString, QString> item(m_headers);
  while (item.hasNext()) {
      item.next();
      new_req.setRawHeader(item.key().toAscii(), item.value().toAscii());
  }
  return QNetworkAccessManager::createRequest(op, new_req, outgoingData);
};

void NetworkAccessManager::addHeader(QString key, QString value) {
  m_headers.insert(key, value);
};

