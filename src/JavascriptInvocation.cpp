#include "JavascriptInvocation.h"

JavascriptInvocation::JavascriptInvocation(QString &functionName, QStringList &arguments, QObject *parent) : QObject(parent) {
  m_functionName = functionName;
  m_arguments = arguments;
}

QString &JavascriptInvocation::functionName() {
  return m_functionName;
}

QStringList &JavascriptInvocation::arguments() {
  return m_arguments;
}
