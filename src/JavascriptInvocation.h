#include <QObject>
#include <QString>
#include <QStringList>
#include <QEvent>
#include <QWebElement>

class WebPage;
class InvocationResult;

class JavascriptInvocation : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString functionName READ functionName)
  Q_PROPERTY(bool allowUnattached READ allowUnattached)
  Q_PROPERTY(QStringList arguments READ arguments)
  Q_PROPERTY(QVariant error READ getError WRITE setError)
  Q_PROPERTY(Qt::Key key_enum)

  public:
    JavascriptInvocation(const QString &functionName, bool allowUnattached, const QStringList &arguments, WebPage *page, QObject *parent = 0);
    QString &functionName();
    bool allowUnattached();
    QStringList &arguments();
    Q_INVOKABLE void leftClick(int x, int y, QVariantList keys);
    Q_INVOKABLE void rightClick(int x, int y, QVariantList keys);
    Q_INVOKABLE void doubleClick(int x, int y, QVariantList keys);
    Q_INVOKABLE bool clickTest(QWebElement element, int absoluteX, int absoluteY);
    Q_INVOKABLE QVariantMap clickPosition(QWebElement element, int left, int top, int width, int height);
    Q_INVOKABLE void hover(int absoluteX, int absoluteY);
    Q_INVOKABLE void keypress(QChar);
    Q_INVOKABLE void namedKeydown(QString keyName);
    Q_INVOKABLE void namedKeyup(QString keyName);
    Q_INVOKABLE void namedKeypress(QString keyName, QString modifiers);
    Q_INVOKABLE const QString render(void);
    QVariant getError();
    void setError(QVariant error);
    InvocationResult invoke(QWebFrame *);

  private:
    QString m_functionName;
    bool m_allowUnattached;
    QStringList m_arguments;
    WebPage *m_page;
    QVariant m_error;
    void hover(const QPoint &);
    int keyCodeFor(const QChar &);
    int keyCodeForName(const QString &);
    Qt::Key key_enum;
    Qt::KeyboardModifiers m_currentModifiers;
    Qt::KeyboardModifiers modifiers(const QVariantList& keys);
    static QMap<QString, Qt::KeyboardModifiers> makeModifiersMap();
    static QMap<QString, Qt::KeyboardModifiers> m_modifiersMap;
};

