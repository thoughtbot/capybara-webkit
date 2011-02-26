#include <QtWebKit>

class WebPage : public QWebPage {
  Q_OBJECT

  public:
    WebPage(QObject *parent = 0);
    QVariant invokeCapybaraFunction(const char *name, QStringList &arguments);
    QVariant invokeCapybaraFunction(QString &name, QStringList &arguments);

  public slots:
    bool shouldInterruptJavaScript();
    void injectJavascriptHelpers();

  private:
    QString m_capybaraJavascript;
};

