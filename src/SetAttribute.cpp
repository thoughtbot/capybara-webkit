#include "SetAttribute.h"
#include "WebPage.h"
#include <QWebSettings>
#include <iostream>

static QMap<QString, QWebSettings::WebAttribute> getAttributesByName()
{
  QMap<QString, QWebSettings::WebAttribute> map;
  map.insert("LocalStorageEnabled", QWebSettings::LocalStorageEnabled);
  map.insert("LocalStorageDatabaseEnabled", QWebSettings::LocalStorageDatabaseEnabled);
  return map;
}

const QMap<QString, QWebSettings::WebAttribute> attributes_by_name = getAttributesByName();

SetAttribute::SetAttribute(WebPage *page, QStringList &arguments, QObject *parent)
  : Command(page, arguments, parent)
{
}

void SetAttribute::start()
{
  QStringList &args = arguments();
  if (!attributes_by_name.contains(args[0])) {
    // not found
    emit finished(new Response(false, QString("No such attribute: " + args[0])));
    return;
  }

  QWebSettings::WebAttribute attr = attributes_by_name[args[0]];

  if (args[1] != "reset") {
    page()->settings()->setAttribute(attr, args[1] != "false");
  }
  else {
    page()->settings()->resetAttribute(attr);
  }

  emit finished(new Response(true));
}

