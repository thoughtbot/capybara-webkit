#include "Response.h"
#include <iostream>

Response::Response(bool success, QString message) {
  m_success = success;
  m_message = message.toUtf8();
}

Response::Response(bool success, QByteArray message) {
  m_success = success;
  m_message = message;
}

Response::Response(bool success) {
  m_success = success;
}

bool Response::isSuccess() const {
  return m_success;
}

QByteArray Response::message() const {
  return m_message;
}

QString Response::toString() const {
  return QString(m_success ? "Success(" : "Failure(") + m_message + ")";
}
