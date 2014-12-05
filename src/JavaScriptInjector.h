#include <QObject>
#include <QWebPage>
#include <QString>

class JavaScriptInjector : public QObject {
  Q_OBJECT

  public:
    JavaScriptInjector(const QString &fileName, QObject *parent = 0);
    void injectIntoPage(QWebPage *);

  private slots:
    void frameCreated(QWebFrame *);
    void injectIntoSender();
    void injectIntoFrame(QWebFrame *);

  private:
    void loadJavaScript();

    QString m_fileName;
    QString m_javaScript;
};
