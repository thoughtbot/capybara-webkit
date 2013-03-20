#include "StdinDevice.h"
#include <QByteArray>
#include <QMutex>

StdinDevice::StdinDevice(QObject *parent) : QIODevice(parent) {
  m_stdin.open(stdin, QIODevice::ReadOnly);
  open(QIODevice::ReadOnly);
  m_readThread = new QThread(this);
  this->moveToThread(m_readThread);
  connect(m_readThread, SIGNAL(started()), this, SLOT(readLoop()));
  m_readThread->start();
}

void StdinDevice::readLoop(void) {
  char nextChar;
  while (m_stdin.isOpen()) {
    m_stdin.getChar(&nextChar);
    m_mutex.lock();
    m_buffer.append(nextChar);
    m_mutex.unlock();
  }
}

qint64 StdinDevice::readData(char *target, qint64 maxSize) {
  QMutexLocker lock(&m_mutex);
  qint64 actualSize = qMin(maxSize, (qint64) m_buffer.size());
  memcpy(target, m_buffer.constData(), actualSize);
  m_buffer.remove(0, maxSize);
  return actualSize;
}

bool StdinDevice::isOpen(void) const {
  return m_stdin.isOpen();
}

bool StdinDevice::isSequential() const {
  return true;
}

qint64 StdinDevice::bytesAvailable(void) const {
  return m_buffer.size() + QIODevice::bytesAvailable();
}

bool StdinDevice::canReadLine() const {
  return m_buffer.contains('\n') || QIODevice::canReadLine();
}

qint64 StdinDevice::writeData(const char *data, qint64 maxSize) {
  Q_UNUSED(data);
  Q_UNUSED(maxSize);
  return 0;
}

bool StdinDevice::isReadable(void) const {
  return bytesAvailable() > 0;
}

void StdinDevice::checkRead(void) {
  if (isReadable()) {
    emit readyRead();
  }
}
