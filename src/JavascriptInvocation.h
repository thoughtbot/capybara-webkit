#include <QObject>
#include <QString>
#include <QStringList>
#include <QWebElement>

class WebPage;
class InvocationResult;

class JavascriptInvocation : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString functionName READ functionName)
  Q_PROPERTY(QStringList arguments READ arguments)
  Q_PROPERTY(QVariantMap error READ getError WRITE setError)

  public:
    JavascriptInvocation(const QString &functionName, const QStringList &arguments, WebPage *page, QObject *parent = 0);
    QString &functionName();
    QStringList &arguments();
    Q_INVOKABLE bool click(QWebElement element, int left, int top, int width, int height);
    QVariantMap getError();
    void setError(QVariantMap error);
    InvocationResult invoke(QWebFrame *);

  private:
    QString m_functionName;
    QStringList m_arguments;
    WebPage *m_page;
    void execClick(QPoint mousePos);
    QVariantMap m_error;
};

