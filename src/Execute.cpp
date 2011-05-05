#include "Execute.h"
#include "WebPage.h"

Execute::Execute(WebPage *page, QObject *parent) : Command(page, parent) {
}

void Execute::start(QStringList &arguments) {
  QString script = arguments[0] + QString("; 'success'");
  QVariant result = page()->currentFrame()->evaluateJavaScript(script);
  if (result.isValid()) {
    emit finished(new Response(true));
  } else {
    emit finished(new Response(false, "Javascript failed to execute"));
  }
}

