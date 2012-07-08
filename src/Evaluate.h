#include "SocketCommand.h"

#include <QVariantList>

class Evaluate : public SocketCommand {
  Q_OBJECT

  public:
    Evaluate(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  private:
    void addVariant(QVariant &object);
    void addString(QString &string);
    void addArray(QVariantList &list);
    void addMap(QVariantMap &map);

    QString m_buffer;
};

