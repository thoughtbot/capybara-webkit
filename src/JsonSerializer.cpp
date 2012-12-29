#include "JsonSerializer.h"

JsonSerializer::JsonSerializer(QObject *parent) : QObject(parent) {
}

QString JsonSerializer::serialize(QVariant &object) {
  addVariant(object);
  return m_buffer;
}

void JsonSerializer::addVariant(QVariant &object) {
  if (object.isValid()) {
    switch(object.type()) {
      case QMetaType::QString:
        {
          QString string = object.toString();
          addString(string);
        }
        break;
      case QMetaType::QVariantList:
        {
          QVariantList list = object.toList();
          addArray(list);
        }
        break;
      case QMetaType::Double:
        m_buffer.append(object.toString());
        break;
      case QMetaType::QVariantMap:
        {
          QVariantMap map = object.toMap();
          addMap(map);
          break;
        }
      case QMetaType::Bool:
        {
          m_buffer.append(object.toString());
          break;
        }
      default:
        m_buffer.append("null");
    }
  } else {
    m_buffer.append("null");
  }
}

void JsonSerializer::addString(QString &string) {
  QString escapedString(string);
  escapedString.replace("\"", "\\\"");
  m_buffer.append("\"");
  m_buffer.append(escapedString);
  m_buffer.append("\"");
}

void JsonSerializer::addArray(QVariantList &list) {
  m_buffer.append("[");
  for (int i = 0; i < list.length(); i++) {
    if (i > 0)
      m_buffer.append(",");
    addVariant(list[i]);
  }
  m_buffer.append("]");
}

void JsonSerializer::addMap(QVariantMap &map) {
  m_buffer.append("{");
  QMapIterator<QString, QVariant> iterator(map);
  while (iterator.hasNext()) {
    iterator.next();
    QString key = iterator.key();
    QVariant value = iterator.value();
    addString(key);
    m_buffer.append(":");
    addVariant(value);
    if (iterator.hasNext())
      m_buffer.append(",");
  }
  m_buffer.append("}");
}

