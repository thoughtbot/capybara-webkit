TEMPLATE = app
TARGET = webkit_server
DESTDIR = .
HEADERS = \
  WebPage.h \
  Server.h \
  Connection.h \
  Command.h \
  Visit.h \
  Find.h \
  Reset.h \
  Node.h \
  JavascriptInvocation.h \
  Url.h \
  Source.h \
  Evaluate.h \
  Execute.h \
  FrameFocus.h \
  Response.h \
  NetworkAccessManager.h \
  NetworkCookieJar.h \
  Header.h \
  Render.h \
  body.h \
  Status.h \
  Headers.h \
  SetCookie.h \
  ClearCookies.h \
  GetCookies.h \
  SetHtml.h \
  SetProxy.h \
  SetAttribute.h \

SOURCES = \
  main.cpp \
  WebPage.cpp \
  Server.cpp \
  Connection.cpp \
  Command.cpp \
  Visit.cpp \
  Find.cpp \
  Reset.cpp \
  Node.cpp \
  JavascriptInvocation.cpp \
  Url.cpp \
  Source.cpp \
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
  SetCookie.cpp \
  ClearCookies.cpp \
  GetCookies.cpp \
  SetHtml.cpp \
  SetProxy.cpp \
  SetAttribute.cpp \

RESOURCES = webkit_server.qrc
QT += network webkit
CONFIG += console
CONFIG -= app_bundle

