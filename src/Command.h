#ifndef COMMAND_H
#define COMMAND_H

#include "Response.h"
#include <QObject>
#include <QString>

class ErrorMessage;

class Command : public QObject {
  Q_OBJECT

  public:
    Command(QObject *parent = 0);
    virtual void start() = 0;
    virtual QString toString() const;

  protected:
    void emitFinished(bool success);
    void emitFinished(bool success, QString message);
    void emitFinished(bool success, QByteArray message);
    void emitFinished(bool success, ErrorMessage *message);

  signals:
    void finished(Response *response);
};

#endif

