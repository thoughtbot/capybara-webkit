#include "SetSkipImageLoading.h"
#include "WebPage.h"
#include "WebPageManager.h"

SetSkipImageLoading::SetSkipImageLoading(WebPageManager *manager, QStringList &arguments, QObject *parent) :
  Command(manager, arguments, parent) {
}

void SetSkipImageLoading::start() {
  page()->setSkipImageLoading(arguments().contains("true"));
  emit finished(new Response(true));
}
