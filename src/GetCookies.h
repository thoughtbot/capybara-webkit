#include "Command.h"

class WebPage;

class GetCookies : public Command {
  Q_OBJECT;

 public:
  GetCookies(WebPage *page, QObject *parent = 0);
  virtual void start(QStringList &arguments);

 private:
  QString m_buffer;
};
