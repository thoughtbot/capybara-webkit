#include "SetSkipImageLoading.h"
#include "WebPage.h"

SetSkipImageLoading::SetSkipImageLoading(WebPage *page, QStringList &arguments, QObject *parent) :
  Command(page, arguments, parent) {
}

void SetSkipImageLoading::start() {
  page()->setSkipImageLoading(arguments().contains("true"));
  emit finished(new Response(true));
}
