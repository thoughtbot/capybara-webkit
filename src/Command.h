#ifndef COMMAND_H
#define COMMAND_H

#include <QObject>
#include <QStringList>
#include "Response.h"

class WebPage;
class WebPageManager;

class Command : public QObject {
  Q_OBJECT

  public:
    Command(WebPageManager *, QStringList &arguments, QObject *parent = 0);
    virtual void start();
    virtual QString toString() const;

  signals:
    void finished(Response *response);

  protected:
    WebPage *page() const;
    const QStringList &arguments() const;
    WebPageManager *manager() const;

  private:
    QStringList m_arguments;
    WebPageManager *m_manager;

};

#endif

