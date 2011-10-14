#include "CustomRequest.h"
#include "WebPage.h"

static QMap<QString, QNetworkAccessManager::Operation> getOperationsByName()
{
  QMap<QString, QNetworkAccessManager::Operation> map;
  map.insert("HEAD",   QNetworkAccessManager::HeadOperation);
  map.insert("GET",    QNetworkAccessManager::GetOperation);
  map.insert("PUT",    QNetworkAccessManager::PutOperation);
  map.insert("POST",   QNetworkAccessManager::PostOperation);
  map.insert("DELETE", QNetworkAccessManager::DeleteOperation);
  return map;
}

const QMap<QString, QNetworkAccessManager::Operation> operations_by_name =
  getOperationsByName();

CustomRequest::CustomRequest(WebPage *page, QObject *parent) : Command(page, parent) {
  connect(page, SIGNAL(pageFinished(bool)), this, SLOT(loadFinished(bool)));
}

void CustomRequest::start(QStringList &arguments) {
  NetworkAccessManager* network_access_manager =
    qobject_cast<NetworkAccessManager*>(page()->networkAccessManager());
  QUrl url = QUrl(arguments[0]);
  QString method = arguments[1].toUpper();
  QString body;
  QString content_type;
  QNetworkAccessManager::Operation op;

  if (arguments.size() > 2) {
    // request body specified
    body         = arguments[2];
    content_type = arguments[3];
  }

  if (!operations_by_name.contains(method)) {
    emit finished(new Response(false, "Invalid request method"));
    return;
  }
  op = operations_by_name[method];

  QNetworkRequest request(url);
  network_access_manager->addHeadersToRequest(request);

  if (!body.isEmpty() && !content_type.isEmpty())
    request.setRawHeader("Content-Type", content_type.toAscii());

  page()->currentFrame()->load(request, op, body.toAscii());
}

void CustomRequest::loadFinished(bool success) {
  QString message;
  if (!success)
    message = page()->failureString();

  disconnect(page(), SIGNAL(pageFinished(bool)), this,
             SLOT(loadFinished(bool)));
  emit finished(new Response(success, message));
}
