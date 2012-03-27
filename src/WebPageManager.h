#include "WebPage.h"
#include <QList>

class WebPageManager {
  public:
    static WebPageManager *getInstance();
    void append(WebPage *value);
    WebPage *first();
    WebPage *last();

  private:
    WebPageManager();
    QList<WebPage*> *webPages;
    static WebPageManager *m_instance;
};

