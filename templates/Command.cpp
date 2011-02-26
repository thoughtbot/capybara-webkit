#include "NAME.h"
#include "WebPage.h"

NAME::NAME(WebPage *page, QObject *parent) : Command(page, parent) {
}

void NAME::start(QStringList &arguments) {
  Q_UNUSED(arguments);
}

