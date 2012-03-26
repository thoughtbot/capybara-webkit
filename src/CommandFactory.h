#include <QObject>

class Command;
class WebPage;

class CommandFactory : public QObject {
  Q_OBJECT

  public:
    CommandFactory(WebPage *page, QObject *parent = 0);
    Command *createCommand(const char *name, QStringList &arguments);

  public slots:
    void changeWindow(WebPage *);

  private:
    WebPage *m_page;
};

