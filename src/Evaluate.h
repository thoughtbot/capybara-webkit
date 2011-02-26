#include "Command.h"

#include <QVariantList>

class WebPage;

class Evaluate : public Command {
  Q_OBJECT

  public:
    Evaluate(WebPage *page, QObject *parent = 0);
    virtual void start(QStringList &arguments);

  private:
    void addVariant(QVariant &object);
    void addString(QString &string);
    void addArray(QVariantList &list);
    void addMap(QVariantMap &map);

    QString m_buffer;
};

