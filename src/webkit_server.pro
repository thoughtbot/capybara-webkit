TEMPLATE = app
TARGET = webkit_server
DESTDIR = .
HEADERS = WebPage.h Server.h Connection.h Command.h Visit.h Find.h Reset.h Attribute.h JavascriptInvocation.h
SOURCES = main.cpp WebPage.cpp Server.cpp Connection.cpp Command.cpp Visit.cpp Find.cpp Reset.cpp Attribute.cpp JavascriptInvocation.cpp
RESOURCES = webkit_server.qrc
QT += network webkit
CONFIG += console

