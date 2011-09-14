#include "Command.h"

class WebPage;

class SetHtml : public Command {
  Q_OBJECT;

 public:
  SetHtml(WebPage *page, QObject *parent = 0);
  virtual void start(QStringList &arguments);

 private slots:
  void loadFinished(bool success);
};
