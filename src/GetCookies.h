#include "Command.h"

class GetCookies : public Command {
  Q_OBJECT;

 public:
  GetCookies(WebPageManager *, QStringList &arguments, QObject *parent = 0);
  virtual void start();

 private:
  QString m_buffer;
};
