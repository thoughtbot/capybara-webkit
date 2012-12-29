#include <QObject>
#include <QVariantList>

class JsonSerializer : public QObject {
  Q_OBJECT

  public:
    JsonSerializer(QObject *parent = 0);
    QString serialize(QVariant &object);

  private:
    void addVariant(QVariant &object);
    void addString(QString &string);
    void addArray(QVariantList &list);
    void addMap(QVariantMap &map);

    QString m_buffer;
};

