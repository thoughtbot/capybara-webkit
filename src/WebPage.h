#include <QtWebKit>
#include <iostream>

class WebPage : public QWebPage {
  Q_OBJECT

  public:
    WebPage(QObject *parent = 0);

  public slots:
    bool shouldInterruptJavaScript();
    void injectJavascriptHelpers();

  private:
    QString m_capybaraJavascript;
};

