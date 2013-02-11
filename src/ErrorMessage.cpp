#include "ErrorMessage.h"
#include "JsonSerializer.h"

ErrorMessage::ErrorMessage(QString message, QObject *parent) : QObject(parent) {
  m_message = message;
}

ErrorMessage::ErrorMessage(QString type, QString message, QObject *parent) : QObject(parent) {
  m_type = type;
  m_message = message;
}

QByteArray ErrorMessage::toString() {
  JsonSerializer serializer;

  QVariantMap map;

  if (m_type.isNull())
    map["json_class"] = "Capybara::Webkit::InvalidResponseError";
  else
    map["json_class"] = m_type;

  map["message"] = m_message;

  return serializer.serialize(map);
}
