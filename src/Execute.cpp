#include "Execute.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "ErrorMessage.h"

Execute::Execute(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void Execute::start() {
  QStringList user_arguments = arguments().mid(1);
  QString jsonArgs = QJsonDocument::fromVariant(user_arguments).toJson(QJsonDocument::Compact);
  QString script = QString("(function(){"
                           "   for(var i=0; i<arguments.length; i++) {"
                           "     arguments[i] = JSON.parse(arguments[i]);"
                           "     if (arguments[i]['ELEMENT']) {"
                           "       arguments[i] = Capybara.getNode(arguments[i]['ELEMENT']);"
                           "     };"
                           "   };"
                           "   %1 }).apply(null, %2); 'success'").arg(arguments()[0], jsonArgs);

  QObject invocation_stub;
  invocation_stub.setProperty("allowUnattached", false);
  page()->currentFrame()->addToJavaScriptWindowObject("CapybaraInvocation", &invocation_stub);
  QVariant result = page()->currentFrame()->evaluateJavaScript(script);
  if (result.isValid()) {
    finish(true);
  } else {
    finish(false, new ErrorMessage("Javascript failed to execute"));
  }
}

