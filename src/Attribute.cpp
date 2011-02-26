#include "Attribute.h"
#include "WebPage.h"

Attribute::Attribute(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Attribute::start(QStringList &arguments) {
  QVariant result = page()->invokeCapybaraFunction("attribute", arguments);
  QString attributeValue = result.toString();
  emit finished(true, attributeValue);
}

