SOURCES = testignoredebugoutput.cpp
OBJECTS += ../src/build/IgnoreDebugOutput.o
QT += testlib
CONFIG += testcase console
CONFIG -= app_bundle
macx {
  QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.9
}
