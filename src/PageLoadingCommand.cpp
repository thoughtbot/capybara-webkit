#include "PageLoadingCommand.h"
#include "Command.h"
#include "WebPage.h"

PageLoadingCommand::PageLoadingCommand(Command *command, WebPage *page, QObject *parent) : QObject(parent) {
  m_page = page;
  m_command = command;
  m_pageLoadingFromCommand = false;
  m_pageSuccess = true;
  m_pendingResponse = NULL;
  connect(m_page, SIGNAL(loadStarted()), this, SLOT(pageLoadingFromCommand()));
  connect(m_page, SIGNAL(pageFinished(bool)), this, SLOT(pendingLoadFinished(bool)));
}

void PageLoadingCommand::start() {
  connect(m_command, SIGNAL(finished(Response *)), this, SLOT(commandFinished(Response *)));
  m_command->start();
};

void PageLoadingCommand::pendingLoadFinished(bool success) {
  m_pageSuccess = success;
  if (m_pageLoadingFromCommand) {
    m_pageLoadingFromCommand = false;
    if (m_pendingResponse) {
      if (m_pageSuccess) {
        emit finished(m_pendingResponse);
      } else {
        QString message = m_page->failureString();
        emit finished(new Response(false, message));
      }
    }
  }
}

void PageLoadingCommand::pageLoadingFromCommand() {
  m_pageLoadingFromCommand = true;
}

void PageLoadingCommand::commandFinished(Response *response) {
  disconnect(m_page, SIGNAL(loadStarted()), this, SLOT(pageLoadingFromCommand()));
  m_command->deleteLater();
  if (m_pageLoadingFromCommand)
    m_pendingResponse = response;
  else
    emit finished(response);
}
