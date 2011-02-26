#include "Find.h"
#include "Command.h"
#include "WebPage.h"
#include <iostream>

Find::Find(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Find::receivedArgument(const char *xpath) {
  std::cout << "<< Running query: " << xpath << std::endl;
  QString javascript = QString("Capybara.find(\"") + xpath + "\")";

  std::cout << "<< Javascript to execute:" << std::endl;
  std::cout << javascript.toAscii().data() << std::endl;

  QString response;
  QVariant result = page()->mainFrame()->evaluateJavaScript(javascript);

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

