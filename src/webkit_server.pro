TEMPLATE = app
TARGET = webkit_server
DESTDIR = .
HEADERS = WebPage.h Server.h Connection.h Command.h Visit.h Find.h Reset.h
SOURCES = main.cpp WebPage.cpp Server.cpp Connection.cpp Command.cpp Visit.cpp Find.cpp Reset.cpp
QT += network webkit
CONFIG += console staticlib

