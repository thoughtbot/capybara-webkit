#include <QVariant>

class InvocationResult {
  public:
    InvocationResult(QVariant result, bool error = false);
    const QVariant &result() const;
    bool hasError();

  private:
    QVariant m_result;
    bool m_error;
};

