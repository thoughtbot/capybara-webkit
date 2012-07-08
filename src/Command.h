#ifndef COMMAND_H
#define COMMAND_H

#include <QObject>
#include "Response.h"

class Command : public QObject {
  Q_OBJECT

  public:
    Command(QObject *parent = 0);
    virtual void start() = 0;
    virtual QString toString() const;

  signals:
    void finished(Response *response);
};

#endif

