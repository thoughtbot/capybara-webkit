TEMPLATE = app
TARGET = webkit_server
DESTDIR = .
HEADERS = WebPage.h Server.h Connection.h Command.h Visit.h Find.h Reset.h Node.h JavascriptInvocation.h Url.h Source.h Evaluate.h Execute.h FrameFocus.h Response.h
SOURCES = main.cpp WebPage.cpp Server.cpp Connection.cpp Command.cpp Visit.cpp Find.cpp Reset.cpp Node.cpp JavascriptInvocation.cpp Url.cpp Source.cpp Evaluate.cpp Execute.cpp FrameFocus.cpp Response.cpp
RESOURCES = webkit_server.qrc
QT += network webkit
CONFIG += console
CONFIG -= app_bundle

