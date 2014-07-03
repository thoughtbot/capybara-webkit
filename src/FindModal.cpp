#include "FindModal.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "ErrorMessage.h"

FindModal::FindModal(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
}

void FindModal::start() {
  int modalId = arguments()[0].toInt();
  if (page()->modalCount() < modalId) {
    finish(false, new ErrorMessage("ModalIndexError", ""));
  } else {
    if (page()->modalMessage(modalId).isNull()) {
      finish(false, new ErrorMessage("ModalNotFound", ""));
    } else {
      finish(true, page()->modalMessage(modalId));
    }
  }
}
