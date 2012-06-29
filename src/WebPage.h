#ifndef _WEBPAGE_H
#define _WEBPAGE_H
#include <QtWebKit>

class WebPageManager;

class WebPage : public QWebPage {
  Q_OBJECT

  public:
    WebPage(WebPageManager *, QObject *parent = 0);
    QVariant invokeCapybaraFunction(const char *name, QStringList &arguments);
    QVariant invokeCapybaraFunction(QString &name, QStringList &arguments);
    QString failureString();
    QString userAgentForUrl(const QUrl &url ) const;
    void setUserAgent(QString userAgent);
    int getLastStatus();
    void setCustomNetworkAccessManager();
    bool render(const QString &fileName);
    virtual bool extension (Extension extension, const ExtensionOption *option=0, ExtensionReturn *output=0);
    void setSkipImageLoading(bool skip);
    QString consoleMessages();
    void resetWindowSize();
    QWebPage *createWindow(WebWindowType type);
    QString uuid();
    QString getWindowName();
    bool matchesWindowSelector(QString);
    void setFocus();

  public slots:
    bool shouldInterruptJavaScript();
    void injectJavascriptHelpers();
    void loadStarted();
    void loadFinished(bool);
    bool isLoading() const;
    QString pageHeaders();
    void frameCreated(QWebFrame *);
    void handleSslErrorsForReply(QNetworkReply *reply, const QList<QSslError> &);
    void handleUnsupportedContent(QNetworkReply *reply);
    void networkAccessManagerCreatedRequest(QNetworkReply *reply);
    void networkAccessManagerFinishedReply(QNetworkReply *reply);

  signals:
    void pageFinished(bool);
    void requestCreated(QNetworkReply *reply);
    void replyFinished(QNetworkReply *reply);

  protected:
    virtual void javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID);
    virtual void javaScriptAlert(QWebFrame *frame, const QString &message);
    virtual bool javaScriptConfirm(QWebFrame *frame, const QString &message);
    virtual bool javaScriptPrompt(QWebFrame *frame, const QString &message, const QString &defaultValue, QString *result);
    virtual QString chooseFile(QWebFrame * parentFrame, const QString &suggestedFile);
    virtual bool supportsExtension(Extension extension) const;

  private:
    QString m_capybaraJavascript;
    QString m_userAgent;
    bool m_loading;
    QString getLastAttachedFileName();
    void loadJavascript();
    void setUserStylesheet();
    int m_lastStatus;
    QString m_pageHeaders;
    QStringList m_consoleMessages;
    QString m_uuid;
    WebPageManager *m_manager;
    QString m_errorPageMessage;
};

#endif //_WEBPAGE_H

