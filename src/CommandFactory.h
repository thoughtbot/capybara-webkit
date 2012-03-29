#include <QObject>

class Command;
class WebPage;
class WebPageManager;

class CommandFactory : public QObject {
  Q_OBJECT

  public:
    CommandFactory(WebPageManager *page, QObject *parent = 0);
    Command *createCommand(const char *name, QStringList &arguments);
    WebPageManager *m_manager;

  private:
    WebPage *currentPage();
};

