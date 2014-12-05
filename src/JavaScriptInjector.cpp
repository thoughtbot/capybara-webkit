#include "JavaScriptInjector.h"

JavaScriptInjector::JavaScriptInjector(
  const QString &fileName,
  QObject *parent
) : QObject(parent) {
  m_fileName = fileName;
  loadJavaScript();
}

void JavaScriptInjector::injectIntoPage(QWebPage *page) {
  connect(
    page,
    SIGNAL(frameCreated(QWebFrame *)),
    SLOT(frameCreated(QWebFrame *))
  );
  injectIntoFrame(page->mainFrame());
}

void JavaScriptInjector::frameCreated(QWebFrame *frame) {
  connect(
    frame,
    SIGNAL(javaScriptWindowObjectCleared()),
    SLOT(injectIntoSender())
  );
}

void JavaScriptInjector::injectIntoSender() {
  QWebFrame* frame = qobject_cast<QWebFrame *>(QObject::sender());
  injectIntoFrame(frame);
}

void JavaScriptInjector::injectIntoFrame(QWebFrame *frame) {
  frame->evaluateJavaScript(m_javaScript);
}

void JavaScriptInjector::loadJavaScript() {
  QResource javaScript(m_fileName);
  if (javaScript.isCompressed()) {
    QByteArray uncompressedBytes(
        qUncompress(javaScript.data(), javaScript.size())
    );
    m_javaScript = QString(uncompressedBytes);
  } else {
    char *javaScriptString =  new char[javaScript.size() + 1];
    strcpy(javaScriptString, (const char *) javaScript.data());
    javaScriptString[javaScript.size()] = 0;
    m_javaScript = javaScriptString;
  }
}
