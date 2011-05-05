#include "Evaluate.h"
#include "WebPage.h"
#include <iostream>

Evaluate::Evaluate(WebPage *page, QObject *parent) : Command(page, parent) {
  m_buffer = "";
}

void Evaluate::start(QStringList &arguments) {
  QVariant result = page()->currentFrame()->evaluateJavaScript(arguments[0]);
  addVariant(result);
  emit finished(new Response(true, m_buffer));
}

void Evaluate::addVariant(QVariant &object) {
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

void Evaluate::addString(QString &string) {
  QString escapedString(string);
  escapedString.replace("\"", "\\\"");
  m_buffer.append("\"");
  m_buffer.append(escapedString);
  m_buffer.append("\"");
}

void Evaluate::addArray(QVariantList &list) {
  m_buffer.append("[");
  for (int i = 0; i < list.length(); i++) {
    if (i > 0)
      m_buffer.append(",");
    addVariant(list[i]);
  }
  m_buffer.append("]");
}

void Evaluate::addMap(QVariantMap &map) {
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
