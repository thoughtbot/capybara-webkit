#include "JavascriptInvocation.h"
#include "WebPage.h"
#include "InvocationResult.h"
#include <QApplication>
#include <QEvent>
#include <QContextMenuEvent>

QMap<QString, Qt::KeyboardModifiers> JavascriptInvocation::m_modifiersMap(JavascriptInvocation::makeModifiersMap());

JavascriptInvocation::JavascriptInvocation(const QString &functionName, bool allowUnattached, const QStringList &arguments, WebPage *page, QObject *parent) : QObject(parent) {
  m_functionName = functionName;
  m_allowUnattached = allowUnattached;
  m_arguments = arguments;
  m_page = page;
}

QString &JavascriptInvocation::functionName() {
  return m_functionName;
}

bool JavascriptInvocation::allowUnattached() {
  return m_allowUnattached;
}

QStringList &JavascriptInvocation::arguments() {
  return m_arguments;
}

QVariant JavascriptInvocation::getError() {
  return m_error;
}

void JavascriptInvocation::setError(QVariant error) {
  m_error = error;
}

InvocationResult JavascriptInvocation::invoke(QWebFrame *frame) {

  frame->addToJavaScriptWindowObject("CapybaraInvocation", this);
  QVariant result = frame->evaluateJavaScript("Capybara.invoke()");
  if (getError().isValid())
    return InvocationResult(getError(), true);
  else {
    if (functionName() == "leftClick") {
      // Don't trigger the left click from JS incase the frame closes
      QVariantMap qm = result.toMap();
      leftClick(qm["absoluteX"].toInt(), qm["absoluteY"].toInt(), qm["keys"].value<QVariantList>());
    }
    return InvocationResult(result);
  }
}

Qt::KeyboardModifiers JavascriptInvocation::modifiers(const QVariantList& keys){
  Qt::KeyboardModifiers modifiers = Qt::NoModifier;
  for (int i = 0; i < keys.length(); i++) {
    modifiers |= m_modifiersMap.value(keys[i].toString(), Qt::NoModifier);
  }
  return modifiers;
}

void JavascriptInvocation::leftClick(int x, int y, QVariantList keys) {
  QPoint mousePos(x, y);

  m_page->mouseEvent(QEvent::MouseButtonPress, mousePos, Qt::LeftButton, modifiers(keys));
  m_page->mouseEvent(QEvent::MouseButtonRelease, mousePos, Qt::LeftButton, modifiers(keys));
}

void JavascriptInvocation::rightClick(int x, int y, QVariantList keys) {
  QPoint mousePos(x, y);
  m_page->mouseEvent(QEvent::MouseButtonPress, mousePos, Qt::RightButton, modifiers(keys));

  // swallowContextMenuEvent tries to fire contextmenu event in html page
  QContextMenuEvent *event = new QContextMenuEvent(QContextMenuEvent::Mouse, mousePos, QCursor::pos(), modifiers(keys));
  m_page->swallowContextMenuEvent(event);

  m_page->mouseEvent(QEvent::MouseButtonRelease, mousePos, Qt::RightButton, modifiers(keys));
}

void JavascriptInvocation::doubleClick(int x, int y, QVariantList keys) {
  QPoint mousePos(x, y);

  m_page->mouseEvent(QEvent::MouseButtonDblClick, mousePos, Qt::LeftButton, modifiers(keys));
  m_page->mouseEvent(QEvent::MouseButtonRelease, mousePos, Qt::LeftButton, modifiers(keys));
}

bool JavascriptInvocation::clickTest(QWebElement element, int absoluteX, int absoluteY) {
  return m_page->clickTest(element, absoluteX, absoluteY);
}

QVariantMap JavascriptInvocation::clickPosition(QWebElement element, int left, int top, int width, int height) {
  QRect elementBox(left, top, width, height);
  QRect viewport(QPoint(0, 0), m_page->viewportSize());
  QRect boundedBox = elementBox.intersected(viewport);
  QPoint mousePos = boundedBox.center();

  QVariantMap m;
  m["relativeX"] = mousePos.x();
  m["relativeY"] = mousePos.y();
  m["relativeTop"] = boundedBox.top();
  m["relativeLeft"] = boundedBox.left();

  QWebFrame *parent = element.webFrame();
  while (parent) {
    elementBox.translate(parent->geometry().topLeft());
    parent = parent->parentFrame();
  }

  boundedBox = elementBox.intersected(viewport);
  mousePos = boundedBox.center();
  m["absoluteTop"] = boundedBox.top();
  m["absoluteLeft"] = boundedBox.left();
  m["absoluteX"] = mousePos.x();
  m["absoluteY"] = mousePos.y();

  return m;
}

void JavascriptInvocation::hover(int absoluteX, int absoluteY) {
  QPoint mousePos(absoluteX, absoluteY);
  hover(mousePos);
}

void JavascriptInvocation::hover(const QPoint &mousePos) {
  m_page->mouseEvent(QEvent::MouseMove, mousePos, Qt::NoButton);
}

int JavascriptInvocation::keyCodeFor(const QChar &key) {
  switch(key.unicode()) {
    case 0x18:
      return Qt::Key_Cancel;
    case 0x08:
      return Qt::Key_Backspace;
    case 0x09:
      return Qt::Key_Tab;
    case 0x0A:
      return Qt::Key_Return;
    case 0x1B:
      return Qt::Key_Escape;
    case 0x7F:
      return Qt::Key_Delete;
    default:
      int keyCode = key.toUpper().toLatin1();
      if (keyCode >= Qt::Key_Space || keyCode <= Qt::Key_AsciiTilde)
        return keyCode;
      else
        return Qt::Key_unknown;
  }
}

int JavascriptInvocation::keyCodeForName(const QString &keyName) {
  const QMetaObject &mo = JavascriptInvocation::staticMetaObject;
  int prop_index = mo.indexOfProperty("key_enum");
  QMetaProperty metaProperty = mo.property(prop_index);
  QMetaEnum metaEnum = metaProperty.enumerator();

  QByteArray array ((QString("Key_") + keyName).toStdString().c_str());
  return metaEnum.keyToValue(array);
  // return Qt::Key_unknown;
}

void JavascriptInvocation::keypress(QChar key) {
  int keyCode = keyCodeFor(key);
  QKeyEvent event(QKeyEvent::KeyPress, keyCode, m_currentModifiers, (m_currentModifiers ? QString() : key));
  QApplication::sendEvent(m_page, &event);
  event = QKeyEvent(QKeyEvent::KeyRelease, keyCode, m_currentModifiers);
  QApplication::sendEvent(m_page, &event);
}

void JavascriptInvocation::namedKeypress(QString keyName, QString modifiers){
  Qt::KeyboardModifiers key_modifiers(m_currentModifiers);
  if (modifiers == "Keypad") {
    key_modifiers |= Qt::KeypadModifier;
  };
  int keyCode = keyCodeForName(keyName);
  QKeyEvent event(QKeyEvent::KeyPress, keyCode, key_modifiers);
  QApplication::sendEvent(m_page, &event);
  event = QKeyEvent(QKeyEvent::KeyRelease, keyCode, key_modifiers);
  QApplication::sendEvent(m_page, &event);
}

void JavascriptInvocation::namedKeydown(QString keyName){
  int keyCode = keyCodeForName(keyName);
  QKeyEvent event(QKeyEvent::KeyPress, keyCode, m_currentModifiers);
  QApplication::sendEvent(m_page, &event);

  switch(keyCode){
    case Qt::Key_Shift:
      m_currentModifiers |= Qt::ShiftModifier;
      break;
    case Qt::Key_Control:
        m_currentModifiers |= Qt::ControlModifier;
        break;
    case Qt::Key_Alt:
      m_currentModifiers |= Qt::AltModifier;
      break;
    case Qt::Key_Meta:
      m_currentModifiers |= Qt::MetaModifier;
      break;
  };
}

void JavascriptInvocation::namedKeyup(QString keyName){
  int keyCode = keyCodeForName(keyName);
  QKeyEvent event(QKeyEvent::KeyRelease, keyCode, m_currentModifiers, 0);
  QApplication::sendEvent(m_page, &event);

  switch(keyCode){
    case Qt::Key_Shift:
      m_currentModifiers &= ~Qt::ShiftModifier;
      break;
    case Qt::Key_Control:
        m_currentModifiers &= ~Qt::ControlModifier;
        break;
    case Qt::Key_Alt:
      m_currentModifiers &= ~Qt::AltModifier;
      break;
    case Qt::Key_Meta:
      m_currentModifiers &= ~Qt::MetaModifier;
      break;
  };
}

const QString JavascriptInvocation::render(void) {
  QString pathTemplate =
    QDir::temp().absoluteFilePath("./click_failed_XXXXXX.png");
  QTemporaryFile file(pathTemplate);
  file.open();
  file.setAutoRemove(false);
  QString path = file.fileName();
  m_page->render(path, QSize(1024, 768));
  return path;
}

QMap<QString, Qt::KeyboardModifiers> JavascriptInvocation::makeModifiersMap(){
  QMap<QString, Qt::KeyboardModifiers> map;
  map["alt"] = Qt::AltModifier;
  map["control"] = Qt::ControlModifier;
  map["meta"] = Qt::MetaModifier;
  map["shift"] = Qt::ShiftModifier;
  return map;
}


