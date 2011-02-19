#include "NAME.h"
#include "WebPage.h"

NAME::NAME(WebPage *page, QObject *parent) : Command(page, parent) {
}

void NAME::start() {
}

void NAME::receivedArgument(const char *argument) {
  Q_UNUSED(argument);
}

