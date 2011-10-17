#include <QObject>
#include <QStringList>

class QIODevice;

class CommandParser : public QObject {
  Q_OBJECT

  public:
    CommandParser(QIODevice *device, QObject *parent = 0);

  public slots:
    void checkNext();

  signals:
    void commandReady(QString commandName, QStringList arguments);

  private:
    void readLine();
    void readDataBlock();
    void processNext(const char *line);
    void processArgument(const char *data);
    QIODevice *m_device;
    QString m_commandName;
    QStringList m_arguments;
    int m_argumentsExpected;
    int m_expectingDataSize;
};

