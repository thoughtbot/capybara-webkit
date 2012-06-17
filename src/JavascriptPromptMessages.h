#include "Command.h"

class WebPage;

class JavascriptPromptMessages : public Command {
  Q_OBJECT

  public:
    JavascriptPromptMessages(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();
};
