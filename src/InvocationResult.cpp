#include "InvocationResult.h"

InvocationResult::InvocationResult(QVariant result, bool error) {
  m_result = result;
  m_error = error;
}

const QVariant &InvocationResult::result() const {
  return m_result;
}

bool InvocationResult::hasError() {
  return m_error;
}
