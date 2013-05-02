#ifndef RESPONSE_H
#define RESPONSE_H

#include <QObject>
#include <QString>
#include <QByteArray>

class Response : public QObject {
  Q_OBJECT

  public:
    Response(bool success, QString message, QObject *parent);
    Response(bool success, QByteArray message, QObject *parent);
    Response(bool success, QObject *parent);
    bool isSuccess() const;
    QByteArray message() const;
    QString toString() const;

  private:
    bool m_success;
    QByteArray m_message;
};

#endif

