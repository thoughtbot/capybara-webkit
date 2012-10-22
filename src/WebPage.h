#ifndef _WEBPAGE_H
#define _WEBPAGE_H
#include <QtWebKit>

class WebPageManager;

class WebPage : public QWebPage {
  Q_OBJECT

  public:
    WebPage(WebPageManager *, QObject *parent = 0);
    QVariant invokeCapybaraFunction(const char *name, const QStringList &arguments);
    QVariant invokeCapybaraFunction(QString &name, const QStringList &arguments);
    QString failureString();
    QString userAgentForUrl(const QUrl &url ) const;
    void setUserAgent(QString userAgent);
    void setConfirmAction(QString action);
    void setPromptAction(QString action);
    void setPromptText(QString action);
    int getLastStatus();
    void setCustomNetworkAccessManager();
    bool render(const QString &fileName);
    virtual bool extension (Extension extension, const ExtensionOption *option=0, ExtensionReturn *output=0);
    void setSkipImageLoading(bool skip);
    QString consoleMessages();
    QString alertMessages();
    QString confirmMessages();
    QString promptMessages();
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
    const QList<QNetworkReply::RawHeaderPair> &pageHeaders();
    void frameCreated(QWebFrame *);
    void handleSslErrorsForReply(QNetworkReply *reply, const QList<QSslError> &);
    void handleUnsupportedContent(QNetworkReply *reply);
    void networkAccessManagerCreatedRequest(QByteArray &url, QNetworkReply *reply);
    void networkAccessManagerFinishedReply(QNetworkReply *reply);

  signals:
    void pageFinished(bool);
    void requestCreated(QByteArray &url, QNetworkReply *reply);
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
    bool m_failed;
    QString getLastAttachedFileName();
    void loadJavascript();
    void setUserStylesheet();
    bool m_confirm;
    bool m_prompt;
    QStringList m_consoleMessages;
    QStringList m_alertMessages;
    QStringList m_confirmMessages;
    QString m_prompt_text;
    QStringList m_promptMessages;
    QString m_uuid;
    WebPageManager *m_manager;
    QString m_errorPageMessage;
};

#endif //_WEBPAGE_H

