#include <QObject>
#include <QString>
#include <QStringList>

class JavascriptInvocation : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString functionName READ functionName)
  Q_PROPERTY(QStringList arguments READ arguments)

  public:
    JavascriptInvocation(QString &functionName, QStringList &arguments, QObject *parent = 0);
    QString &functionName();
    QStringList &arguments();

  private:
    QString m_functionName;
    QStringList m_arguments;
};

