#include "JavascriptInvocation.h"
#include "WebPage.h"
#include "InvocationResult.h"
#include <QApplication>

JavascriptInvocation::JavascriptInvocation(const QString &functionName, const QStringList &arguments, WebPage *page, QObject *parent) : QObject(parent) {
  m_functionName = functionName;
  m_arguments = arguments;
  m_page = page;
}

QString &JavascriptInvocation::functionName() {
  return m_functionName;
}

QStringList &JavascriptInvocation::arguments() {
  return m_arguments;
}

QVariantMap JavascriptInvocation::getError() {
  return m_error;
}

void JavascriptInvocation::setError(QVariantMap error) {
  m_error = error;
}

InvocationResult JavascriptInvocation::invoke(QWebFrame *frame) {
  frame->addToJavaScriptWindowObject("CapybaraInvocation", this);
  QVariant result = frame->evaluateJavaScript("Capybara.invoke()");
  if (getError().isEmpty())
    return InvocationResult(result);
  else
    return InvocationResult(getError(), true);
}

bool JavascriptInvocation::click(QWebElement element, int left, int top, int width, int height) {
  QRect elementBox(left, top, width, height);
  QRect viewport(QPoint(0, 0), m_page->viewportSize());
  QRect boundedBox = elementBox.intersected(viewport);
  QPoint mousePos = boundedBox.center();

  QString script = QString("Capybara.clickTest(this, %1, %2);").arg(mousePos.x()).arg(mousePos.y());
  bool ok = element.evaluateJavaScript(script).toBool();

  QWebFrame *parent = element.webFrame();
  while (parent) {
    elementBox.translate(parent->geometry().topLeft());
    parent = parent->parentFrame();
  }

  boundedBox = elementBox.intersected(viewport);
  mousePos = boundedBox.center();

  QWebHitTestResult res = m_page->mainFrame()->hitTestContent(mousePos);
  ok = ok && res.frame() == element.webFrame();

  if (ok) {
    execClick(mousePos);
  }
  return ok;
}

void JavascriptInvocation::execClick(QPoint mousePos) {
  QMouseEvent event(QEvent::MouseMove, mousePos, Qt::NoButton, Qt::NoButton, Qt::NoModifier);
  QApplication::sendEvent(m_page, &event);

  event = QMouseEvent(QEvent::MouseButtonPress, mousePos, Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);
  QApplication::sendEvent(m_page, &event);

  event = QMouseEvent(QEvent::MouseButtonRelease, mousePos, Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);
  QApplication::sendEvent(m_page, &event);
}
