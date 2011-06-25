#include "UserAgent.h"
#include "WebPage.h"

UserAgent::UserAgent(WebPage *page, QObject *parent) : Command(page, parent) {
}

void UserAgent::start(QStringList &arguments) {
  switch(arguments.length()) {
    case 1:
      page()->setUserAgent(arguments[0]);
      emit finished(new Response(true));
      break;
    default:
      emit finished(new Response(true, page()->userAgent()));
  }
}