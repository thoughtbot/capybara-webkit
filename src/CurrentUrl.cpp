#include "CurrentUrl.h"
#include "WebPage.h"

CurrentUrl::CurrentUrl(WebPage *page, QStringList &arguments, QObject *parent) : Command(page, arguments, parent) {
}

/*
 * This CurrentUrl command attempts to produce a current_url value consistent
 * with that returned by the Selenium WebDriver Capybara driver.
 *
 * It does not currently return the correct value in the case of an iframe whose
 * source URL results in a redirect because the loading of the iframe does not
 * generate a history item. This is most likely a rare case and is consistent
 * with the current behavior of the capybara-webkit driver.
 *
 * The following two values are *not* affected by Javascript pushState.
 *
 * QWebFrame->url()
 * QWebHistoryItem.originalUrl()
 *
 * The following two values *are* affected by Javascript pushState.
 *
 * QWebFrame->requestedUrl()
 * QWebHistoryItem.url()
 *
 * In the cases that we have access to both the QWebFrame values and the
 * correct history item for that frame, we can compare the values and determine
 * if a redirect occurred and if pushState was used. The table below describes
 * the various combinations of URL values that are possible.
 *
 *   O -> originally requested URL
 *   R -> URL after redirection
 *   P -> URL set by pushState
 *   * -> denotes the desired URL value from the frame
 *
 *               frame               history
 * case          url   requestedUrl  url     originalUrl
 * -----------------------------------------------------------------
 * regular load    O     O*            O       O
 *
 * redirect w/o    R*    O             R       O
 * pushState
 *
 * pushState       O     P*            P       O
 * only
 *
 * redirect w/     R     P*            P       O
 * pushState
 *
 * Based on the above information, we only need to check for the case of a
 * redirect w/o pushState, in which case QWebFrame->url() will have the correct
 * current_url value. In all other cases QWebFrame->requestedUrl() is correct.
 */
void CurrentUrl::start() {
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
}

