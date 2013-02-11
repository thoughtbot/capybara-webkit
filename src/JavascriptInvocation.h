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
  Q_PROPERTY(QVariant error READ getError WRITE setError)

  public:
    JavascriptInvocation(const QString &functionName, const QStringList &arguments, WebPage *page, QObject *parent = 0);
    QString &functionName();
    QStringList &arguments();
    Q_INVOKABLE void click(int x, int y);
    Q_INVOKABLE bool clickTest(QWebElement element, int absoluteX, int absoluteY);
    Q_INVOKABLE QVariantMap clickPosition(QWebElement element, int left, int top, int width, int height);
    QVariant getError();
    void setError(QVariant error);
    InvocationResult invoke(QWebFrame *);

  private:
    QString m_functionName;
    QStringList m_arguments;
    WebPage *m_page;
    QVariant m_error;
};

