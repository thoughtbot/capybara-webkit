#include "CurrentUrl.h"
#include "WebPage.h"
#include "WebPageManager.h"

CurrentUrl::CurrentUrl(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void CurrentUrl::start() {
#if QT_VERSION >= QT_VERSION_CHECK(4, 8, 0)
  QStringList arguments;
  QVariant result = page()->invokeCapybaraFunction("currentUrl", arguments);
  QString url = result.toString();
  emit finished(new Response(true, url));
#else
  QUrl humanUrl = wasRedirectedAndNotModifiedByJavascript() ?
    page()->currentFrame()->url() : page()->currentFrame()->requestedUrl();
  QByteArray encodedBytes = humanUrl.toEncoded();
  emit finished(new Response(true, encodedBytes));
}

bool CurrentUrl::wasRegularLoad() {
  return page()->currentFrame()->url() == page()->currentFrame()->requestedUrl();
}

bool CurrentUrl::wasRedirectedAndNotModifiedByJavascript() {
  return !wasRegularLoad() && page()->currentFrame()->url() == page()->history()->currentItem().url();
#endif
}

