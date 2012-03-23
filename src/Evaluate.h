#include "Command.h"

#include <QVariantList>

class WebPage;

class Evaluate : public Command {
  Q_OBJECT

  public:
    Evaluate(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    void addVariant(QVariant &object);
    void addString(QString &string);
    void addArray(QVariantList &list);
    void addMap(QVariantMap &map);

    QString m_buffer;
};

