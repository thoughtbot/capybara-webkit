TEMPLATE = app
TARGET = webkit_server
DESTDIR = .
HEADERS = WebPage.h Server.h Connection.h Command.h Visit.h Find.h Reset.h Node.h JavascriptInvocation.h
SOURCES = main.cpp WebPage.cpp Server.cpp Connection.cpp Command.cpp Visit.cpp Find.cpp Reset.cpp Node.cpp JavascriptInvocation.cpp
RESOURCES = webkit_server.qrc
QT += network webkit
CONFIG += console

