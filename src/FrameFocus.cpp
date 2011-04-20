#include "FrameFocus.h"
#include "Command.h"
#include "WebPage.h"

FrameFocus::FrameFocus(WebPage *page, QObject *parent) : Command(page, parent) {
}

void FrameFocus::start(QStringList &arguments) {
  int index;
  bool ok;
  bool found = false;
  QString response;
  QList<QWebFrame *> child_frames = page()->currentFrame()->childFrames();
  if (arguments.length() > 0) {
    if (arguments.length() > 1) {
      // Find frame by index.
      index = arguments[1].toInt(&ok);
      if (ok && 0 <= index && index < child_frames.length()) {
        child_frames[index]->setFocus();
        found = true;
      }
    } else {
      // Find frame by id.
      for (int i = 0; i < child_frames.length(); i++) {
        if (child_frames[i]->frameName().compare(arguments[0]) == 0) {
          child_frames[i]->setFocus();
          found = true;
          break;
        }
      }
    }
    if (found) {
      emit finished(true, response);
    } else {
      response = "Unable to locate frame. ";
      emit finished(false, response);
    }
  } else {
    // Set focus on parent.
    if (page()->currentFrame()->parentFrame() == 0) {
      response = "Already at parent frame.";
      emit finished(false, response);
    } else {
      page()->currentFrame()->parentFrame()->setFocus();
      emit finished(true, response);
    }
  }
}

