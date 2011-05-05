#include <QString>

class Response {
  public:
    Response(bool success, QString message);
    Response(bool success);
    bool isSuccess() const;
    QString message() const;

  private:
    bool m_success;
    QString m_message;
};
