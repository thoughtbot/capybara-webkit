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
    virtual bool extension (Extension extension, const ExtensionOption *option=0, ExtensionReturn *output=0);

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
    virtual QString chooseFile(QWebFrame * parentFrame, const QString &suggestedFile);

  private:
    QString m_capybaraJavascript;
    QString m_userAgent;
    bool m_loading;
    QString getLastAttachedFileName();
};

