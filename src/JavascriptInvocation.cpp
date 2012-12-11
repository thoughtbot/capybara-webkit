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

void JavascriptInvocation::click(const QWebElement &element, int left, int top, int width, int height) {
  QRect elementBox(left, top, width, height);
  QWebFrame *parent = element.webFrame();
  while (parent) {
    elementBox = elementBox.translated(parent->geometry().topLeft());
    parent = parent->parentFrame();
  }
  QRect viewport(QPoint(0, 0), m_page->viewportSize());
  QPoint mousePos = elementBox.intersected(viewport).center();

  QMouseEvent event(QEvent::MouseMove, mousePos, Qt::NoButton, Qt::NoButton, Qt::NoModifier);
  QApplication::sendEvent(m_page, &event);

  event = QMouseEvent(QEvent::MouseButtonPress, mousePos, Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);
  QApplication::sendEvent(m_page, &event);

  event = QMouseEvent(QEvent::MouseButtonRelease, mousePos, Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);
  QApplication::sendEvent(m_page, &event);
}
