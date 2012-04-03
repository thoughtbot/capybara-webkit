#include <QObject>

class Command;
class WebPage;

class CommandFactory : public QObject {
  Q_OBJECT

  public:
    CommandFactory(WebPage *page, QObject *parent = 0);
    Command *createCommand(const char *name, QStringList &arguments);

  private:
    WebPage *m_page;
};

