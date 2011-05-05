#include "FrameFocus.h"
#include "Command.h"
#include "WebPage.h"

FrameFocus::FrameFocus(WebPage *page, QObject *parent) : Command(page, parent) {
}

void FrameFocus::start(QStringList &arguments) {
  findFrames();
  switch(arguments.length()) {
    case 1:
      focusId(arguments[0]);
      break;
    case 2:
      focusIndex(arguments[1].toInt());
      break;
    default:
      focusParent();
  }
}

void FrameFocus::findFrames() {
  frames = page()->currentFrame()->childFrames();
}

void FrameFocus::focusIndex(int index) {
  if (isFrameAtIndex(index)) {
    frames[index]->setFocus();
    success();
  } else {
    frameNotFound();
  }
}

bool FrameFocus::isFrameAtIndex(int index) {
  return 0 <= index && index < frames.length();
}

void FrameFocus::focusId(QString name) {
  for (int i = 0; i < frames.length(); i++) {
    if (frames[i]->frameName().compare(name) == 0) {
      frames[i]->setFocus();
      success();
      return;
    }
  }

  frameNotFound();
}

void FrameFocus::focusParent() {
  if (page()->currentFrame()->parentFrame() == 0) {
    emit finished(new Response(false, "Already at parent frame."));
  } else {
    page()->currentFrame()->parentFrame()->setFocus();
    success();
  }
}

void FrameFocus::frameNotFound() {
  emit finished(new Response(false, "Unable to locate frame. "));
}

void FrameFocus::success() {
  emit finished(new Response(true));
}
