#include "JavascriptInvocation.h"

JavascriptInvocation::JavascriptInvocation(const QString &functionName, const QStringList &arguments, QObject *parent) : QObject(parent) {
  m_functionName = functionName;
  m_arguments = arguments;
}

QString &JavascriptInvocation::functionName() {
  return m_functionName;
}

QStringList &JavascriptInvocation::arguments() {
  return m_arguments;
}
