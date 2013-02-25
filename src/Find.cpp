#include "Find.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "InvocationResult.h"

Find::Find(WebPageManager *manager, QStringList &arguments, QObject *parent) : JavascriptCommand(manager, arguments, parent) {
}

void Find::start() {
  InvocationResult result = page()->invokeCapybaraFunction("find", arguments());
  finish(&result);
}

