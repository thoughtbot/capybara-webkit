#ifndef COMMAND_H
#define COMMAND_H

#include <QObject>
#include <QStringList>
#include "Response.h"

class WebPage;

class Command : public QObject {
  Q_OBJECT

  public:
    Command(WebPage *page, QStringList &arguments, QObject *parent = 0);
    virtual void start();

  signals:
    void finished(Response *response);

  protected:
    WebPage *page();
    QStringList &arguments();

  private:
    WebPage *m_page;
    QStringList m_arguments;

};

#endif

