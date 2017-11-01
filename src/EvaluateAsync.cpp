#include "EvaluateAsync.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "JsonSerializer.h"
#include <iostream>

EvaluateAsync::EvaluateAsync(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void EvaluateAsync::start() {
  QString script = arguments()[0];
  QString jsonArgs;
  if (arguments().length()>1){
    jsonArgs = arguments()[1];
  } else {
    jsonArgs ="[]";
  }
  QString eval_script = QString("(function(){"
                           "   for(var i=0; i<arguments.length-1; i++) {"
                           "     arguments[i] = JSON.parse(arguments[i]);"
                           "     var elem_id = arguments[i]['element-581e-422e-8be1-884c4e116226'];"
                           "     if (elem_id) {"
                           "       arguments[i] = Capybara.getNode(elem_id);"
                           "     };"
                           "   };"
                           "   eval(\"%1\");"
                           "   return;"
                           " }).apply(null, %2.concat(function(res){ "
                           " res = Capybara.wrapResult(res);"
                           // This isn't necessary in Qt 5.5 but is in older (at least 5.2 on Travis)
                           " if (res instanceof Array) {"
                           "    CapybaraAsync['asyncResult(QVariantList)'](res);"
                           " } else { "
                           "    CapybaraAsync['asyncResult(QVariant)'](res);"
                           " }"
                           " }))").arg(script.replace("\"","\\\"").remove("\n"), jsonArgs);
  QObject invocation_stub;
  invocation_stub.setProperty("allowUnattached", false);
  page()->currentFrame()->addToJavaScriptWindowObject("CapybaraInvocation", &invocation_stub);
  page()->currentFrame()->addToJavaScriptWindowObject("CapybaraAsync", this);
  page()->currentFrame()->evaluateJavaScript(eval_script);
}

void EvaluateAsync::asyncResult(QVariantList result) {
  JsonSerializer serializer;
  finish(true, serializer.serialize(result));
}

void EvaluateAsync::asyncResult(QVariant result) {
  JsonSerializer serializer;
  finish(true, serializer.serialize(result));
}


