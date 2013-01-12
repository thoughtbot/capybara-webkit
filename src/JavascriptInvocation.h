#include <QObject>
#include <QString>
#include <QStringList>
#include <QWebElement>

class WebPage;

class JavascriptInvocation : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString functionName READ functionName)
  Q_PROPERTY(QStringList arguments READ arguments)

  public:
    JavascriptInvocation(const QString &functionName, const QStringList &arguments, WebPage *page, QObject *parent = 0);
    QString &functionName();
    QStringList &arguments();
    Q_INVOKABLE bool click(const QWebElement &element, int left, int top, int width, int height);

  private:
    QString m_functionName;
    QStringList m_arguments;
    WebPage *m_page;
    void execClick(QPoint mousePos);
};

