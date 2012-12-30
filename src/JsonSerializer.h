#include <QObject>
#include <QVariantList>

class JsonSerializer : public QObject {
  Q_OBJECT

  public:
    JsonSerializer(QObject *parent = 0);
    QString serialize(const QVariant &object);

  private:
    void addVariant(const QVariant &object);
    void addString(const QString &string);
    void addArray(const QVariantList &list);
    void addMap(const QVariantMap &map);
    QString sanitizeString(QString string);

    QString m_buffer;
};

