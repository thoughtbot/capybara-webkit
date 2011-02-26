#include "Find.h"
#include "Command.h"
#include "WebPage.h"
#include <iostream>

Find::Find(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Find::receivedArgument(const char *xpath) {
  QStringList arguments;
  QString response;
  arguments.append(QString(xpath));
  QVariant result = page()->invokeCapybaraFunction("find", arguments);

  if (result.isValid()) {
    response = result.toString();

    std::cout << "<< Got result:" << std::endl;
    std::cout << response.toAscii().data() << std::endl;

    emit finished(true, response);
  } else {
    response = "Invalid XPath expression";
    emit finished(false, response);
  }
}

