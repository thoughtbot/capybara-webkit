TEMPLATE = app
TARGET = webkit_server
DESTDIR = .
HEADERS = \
  Version.h \
  EnableLogging.h \
  Authenticate.h \
  SetConfirmAction.h \
  SetPromptAction.h \
  SetPromptText.h \
  ClearPromptText.h \
  JavascriptAlertMessages.h \
  JavascriptConfirmMessages.h \
  JavascriptPromptMessages.h \
  IgnoreSslErrors.h \
  ResizeWindow.h \
  CurrentUrl.h \
  ConsoleMessages.h \
  WebPage.h \
  Server.h \
  Connection.h \
  Command.h \
  SocketCommand.h \
  Visit.h \
  Reset.h \
  Node.h \
  JavascriptInvocation.h \
  Evaluate.h \
  Execute.h \
  FrameFocus.h \
  Response.h \
  NetworkAccessManager.h \
  NetworkCookieJar.h \
  Header.h \
  Render.h \
  Body.h \
  Status.h \
  Headers.h \
  UnsupportedContentHandler.h \
  SetCookie.h \
  ClearCookies.h \
  GetCookies.h \
  CommandParser.h \
  CommandFactory.h \
  SetProxy.h \
  NullCommand.h \
  PageLoadingCommand.h \
  SetSkipImageLoading.h \
  WebPageManager.h \
  WindowFocus.h \
  GetWindowHandles.h \
  GetWindowHandle.h \
  GetTimeout.h \
  SetTimeout.h \
  TimeoutCommand.h \
  SetUrlBlacklist.h \
  NoOpReply.h \
  JsonSerializer.h \
  InvocationResult.h \
  ErrorMessage.h \
  Title.h \
  FindCss.h \
  JavascriptCommand.h \
  FindXpath.h \
  NetworkReplyProxy.h

SOURCES = \
  Version.cpp \
  EnableLogging.cpp \
  Authenticate.cpp \
  SetConfirmAction.cpp \
  SetPromptAction.cpp \
  SetPromptText.cpp \
  ClearPromptText.cpp \
  JavascriptAlertMessages.cpp \
  JavascriptConfirmMessages.cpp \
  JavascriptPromptMessages.cpp \
  IgnoreSslErrors.cpp \
  ResizeWindow.cpp \
  CurrentUrl.cpp \
  ConsoleMessages.cpp \
  main.cpp \
  WebPage.cpp \
  Server.cpp \
  Connection.cpp \
  Command.cpp \
  SocketCommand.cpp \
  Visit.cpp \
  Reset.cpp \
  Node.cpp \
  JavascriptInvocation.cpp \
  Evaluate.cpp \
  Execute.cpp \
  FrameFocus.cpp \
  Response.cpp \
  NetworkAccessManager.cpp \
  NetworkCookieJar.cpp \
  Header.cpp \
  Render.cpp \
  body.cpp \
  Status.cpp \
  Headers.cpp \
  UnsupportedContentHandler.cpp \
  SetCookie.cpp \
  ClearCookies.cpp \
  GetCookies.cpp \
  CommandParser.cpp \
  CommandFactory.cpp \
  SetProxy.cpp \
  NullCommand.cpp \
  PageLoadingCommand.cpp \
  SetTimeout.cpp \
  GetTimeout.cpp \
  SetSkipImageLoading.cpp \
  WebPageManager.cpp \
  WindowFocus.cpp \
  GetWindowHandles.cpp \
  GetWindowHandle.cpp \
  TimeoutCommand.cpp \
  SetUrlBlacklist.cpp \
  NoOpReply.cpp \
  JsonSerializer.cpp \
  InvocationResult.cpp \
  ErrorMessage.cpp \
  Title.cpp \
  FindCss.cpp \
  JavascriptCommand.cpp \
  FindXpath.cpp \
  NetworkReplyProxy.cpp

RESOURCES = webkit_server.qrc
QT += network
greaterThan(QT_MAJOR_VERSION, 4) {
  QT += webkitwidgets
} else {
  QT += webkit
}
CONFIG += console precompile_header
CONFIG -= app_bundle
PRECOMPILED_HEADER = stable.h

