#include <QtWebKit>

class WebPage : public QWebPage {
  Q_OBJECT

  public:
    WebPage(QObject *parent = 0);
    QVariant invokeCapybaraFunction(const char *name, QStringList &arguments);
    QVariant invokeCapybaraFunction(QString &name, QStringList &arguments);
    QString failureString();
    QString userAgentForUrl(const QUrl &url ) const;
    void setUserAgent(QString userAgent);
    bool render(const QString &fileName);

  public slots:
    bool shouldInterruptJavaScript();
    void injectJavascriptHelpers();
    void loadStarted();
    void loadFinished(bool);
    bool isLoading() const;
    void frameCreated(QWebFrame *);

  protected:
    virtual void javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID);
    virtual void javaScriptAlert(QWebFrame *frame, const QString &message);
    virtual bool javaScriptConfirm(QWebFrame *frame, const QString &message);
    virtual bool javaScriptPrompt(QWebFrame *frame, const QString &message, const QString &defaultValue, QString *result);

  private:
    QString m_capybaraJavascript;
    QString m_userAgent;
    bool m_loading;
};

