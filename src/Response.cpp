#include "Response.h"
#include <iostream>

Response::Response(bool success, QString message) {
  m_success = success;
  m_message = message;
}

Response::Response(bool success) {
  Response(success, QString());
}

bool Response::isSuccess() const {
  return m_success;
}

QString Response::message() const {
  return m_message;
}
