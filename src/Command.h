#ifndef COMMAND_H
#define COMMAND_H

#include <QObject>

class WebPage;

class Command : public QObject {
  Q_OBJECT

  public:
    Command(WebPage *page, QObject *parent = 0);
    virtual void start();
    virtual void receivedArgument(const char *argument);

  signals:
    void finished(bool success, QString &response);

  protected:
    WebPage *page();

  private:
    WebPage *m_page;

};

#endif

