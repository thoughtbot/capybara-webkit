#include "CommandFactory.h"
#include "NullCommand.h"
#include "Visit.h"
#include "Find.h"
#include "Command.h"
#include "Reset.h"
#include "Node.h"
#include "Url.h"
#include "Source.h"
#include "Evaluate.h"
#include "Execute.h"
#include "FrameFocus.h"
#include "Header.h"
#include "Render.h"
#include "Body.h"
#include "Status.h"
#include "Headers.h"
#include "SetCookie.h"
#include "ClearCookies.h"
#include "GetCookies.h"
#include "SetProxy.h"
#include "ConsoleMessages.h"
#include "RequestedUrl.h"
#include "CurrentUrl.h"
#include "ResizeWindow.h"

CommandFactory::CommandFactory(WebPage *page, QObject *parent) : QObject(parent) {
  m_page = page;
}

Command *CommandFactory::createCommand(const char *name, QStringList &arguments) {
  #include "find_command.h"
  arguments.clear();
  arguments.append(QString(name));
  return new NullCommand(m_page, arguments);
}
