#include "UnhandledModalCommand.h"
#include "SocketCommand.h"
#include "WebPage.h"
#include "WebPageManager.h"
#include "ErrorMessage.h"

UnhandledModalCommand::UnhandledModalCommand(Command *command, WebPageManager *manager, QObject *parent) : Command(parent) {
  m_manager = manager;
  m_command = command;
  m_command->setParent(this);
}

void UnhandledModalCommand::start() {
  connect(m_command, SIGNAL(finished(Response *)), this, SLOT(commandFinished(Response *)));
  m_command->start();
};

void UnhandledModalCommand::commandFinished(Response *response) {
  if (m_manager->currentPage()->hasUnexpectedModal()) {
    finish(false, new ErrorMessage("UnhandledModalError", ""));
  } else {
    emit finished(response);
  }
}
