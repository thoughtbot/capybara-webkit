#include "Command.h"

class WebPage;

class GetCookies : public Command {
  Q_OBJECT;

 public:
  GetCookies(WebPage *page, QStringList &arguments, QObject *parent = 0);
  virtual void start();

 private:
  QString m_buffer;
};
