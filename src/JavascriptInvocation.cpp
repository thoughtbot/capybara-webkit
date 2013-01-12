#include "JavascriptInvocation.h"
#include "WebPage.h"
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

bool JavascriptInvocation::click(const QWebElement &element, int left, int top, int width, int height) {
  QRect elementBox(left, top, width, height);
  QWebFrame *parent = element.webFrame();
  while (parent) {
    elementBox.translate(parent->geometry().topLeft());
    parent = parent->parentFrame();
  }
  QRect viewport(QPoint(0, 0), m_page->viewportSize());
  QRect boundedBox = elementBox.intersected(viewport);
  QPoint mousePos = boundedBox.center();

  QRect r = QRect(QPoint(left, top), boundedBox.size());
  QPoint p = r.center();
  bool ok = QWebElement(element).evaluateJavaScript(QString("Capybara.clickTest(this, %1, %2);").arg(p.x()).arg(p.y())).toBool();

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
