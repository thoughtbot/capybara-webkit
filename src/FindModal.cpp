#include "FindModal.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "ErrorMessage.h"

FindModal::FindModal(WebPageManager *manager, QStringList &arguments, QObject *parent) : SocketCommand(manager, arguments, parent) {
  m_modalId = 0;
}

void FindModal::start() {
  m_modalId = arguments()[0].toInt();
  if (page()->modalCount() < m_modalId) {
    connect(page(), SIGNAL(modalReady(int)), SLOT(handleModalReady(int)));
  } else {
    handleModalReady(m_modalId);
  }
}

void FindModal::handleModalReady(int modalId) {
  if (modalId == m_modalId) {
    sender()->disconnect(SIGNAL(modalReady(int)), this, SLOT(handleModalReady(int)));
    if (page()->modalMessage(m_modalId).isNull()) {
      finish(false, new ErrorMessage("ModalNotFound", ""));
    } else {
      finish(true, page()->modalMessage(m_modalId));
    }
  }
}
