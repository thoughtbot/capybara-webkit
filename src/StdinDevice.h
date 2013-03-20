#include <QIODevice>

class QByteArray;
class QFile;
class QThread;

class StdinDevice : public QIODevice {
  Q_OBJECT

  public:
    StdinDevice(QObject *parent = 0);
    void checkRead(void);
    bool isOpen(void) const;
    bool canReadLine() const;
    bool isReadable(void) const;
    bool isSequential() const;
    qint64 bytesAvailable(void) const;

  protected:
    qint64 readData(char *data, qint64 maxSize);
    qint64 writeData(const char *data, qint64 maxSize);

  protected slots:
    void readLoop(void);

  private:
    QByteArray m_buffer;
    QFile m_stdin;
    QThread *m_readThread;
};

