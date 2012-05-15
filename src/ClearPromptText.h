#include "Command.h"

class WebPage;

class ClearPromptText : public Command {
  Q_OBJECT;

 public:
  ClearPromptText(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();
};
