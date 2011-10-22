#include "SetAttribute.h"
#include "WebPage.h"
#include <QWebSettings>
#include <iostream>

static QMap<QString, QWebSettings::WebAttribute> getAttributesByName()
{
  QMap<QString, QWebSettings::WebAttribute> map;
  map.insert("AutoLoadImages",
             QWebSettings::AutoLoadImages);
  // disable setting JavascriptEnabled to false,
  // as our Javascript helpers won't work then
  //map.insert("JavascriptEnabled",
  //           QWebSettings::JavascriptEnabled);
  map.insert("DnsPrefetchEnabled",
             QWebSettings::DnsPrefetchEnabled);
  map.insert("PluginsEnabled",
             QWebSettings::PluginsEnabled);
  map.insert("PrivateBrowsingEnabled",
             QWebSettings::PrivateBrowsingEnabled);
  map.insert("JavascriptCanOpenWindows",
             QWebSettings::JavascriptCanOpenWindows);
  map.insert("JavascriptCanAccessClipboard",
             QWebSettings::JavascriptCanAccessClipboard);
  map.insert("OfflineStorageDatabaseEnabled",
             QWebSettings::OfflineStorageDatabaseEnabled);
  map.insert("OfflineWebApplicationCacheEnabled",
             QWebSettings::OfflineWebApplicationCacheEnabled);
  map.insert("LocalStorageEnabled",
             QWebSettings::LocalStorageEnabled);
  map.insert("LocalStorageDatabaseEnabled",
             QWebSettings::LocalStorageDatabaseEnabled);
  map.insert("LocalContentCanAccessRemoteUrls",
             QWebSettings::LocalContentCanAccessRemoteUrls);
  map.insert("LocalContentCanAccessFileUrls",
             QWebSettings::LocalContentCanAccessFileUrls);
  map.insert("AcceleratedCompositingEnabled",
             QWebSettings::AcceleratedCompositingEnabled);
  map.insert("SiteSpecificQuirksEnabled",
             QWebSettings::SiteSpecificQuirksEnabled);
  return map;
}

const QMap<QString, QWebSettings::WebAttribute> attributes_by_name =
  getAttributesByName();

SetAttribute::SetAttribute(WebPage *page, QObject *parent)
  : Command(page, parent)
{ }

void SetAttribute::start(QStringList &arguments)
{
  if (!attributes_by_name.contains(arguments[0])) {
    // not found
    emit finished(new Response(false, QString("No such attribute: ") +
                                      arguments[0]));
    return;
  }

  QWebSettings::WebAttribute attr =
    attributes_by_name[arguments[0]];

  if (arguments[1] != "reset")
    page()->settings()->setAttribute(attr, arguments[1] != "false");
  else
    page()->settings()->resetAttribute(attr);

  emit finished(new Response(true));
}
