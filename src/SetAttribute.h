#include "Command.h"
#include <QMap>
#include <QString>
#include <QWebSettings>

extern const QMap<QString, QWebSettings::WebAttribute> attributes_by_name;

class WebPage;

class SetAttribute : public Command {
  Q_OBJECT;

 public:
  SetAttribute(WebPage *page, QObject *parent = 0);
  virtual void start(QStringList &arguments);
};
