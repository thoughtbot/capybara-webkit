#define CHECK_COMMAND(expectedName) \
  if (strcmp(#expectedName, name) == 0) { \
    return new expectedName(m_page, this); \
  }

CHECK_COMMAND(Visit)
CHECK_COMMAND(Find)
CHECK_COMMAND(Reset)
CHECK_COMMAND(Node)
CHECK_COMMAND(Url)
CHECK_COMMAND(Source)
CHECK_COMMAND(Evaluate)
CHECK_COMMAND(Execute)
CHECK_COMMAND(FrameFocus)
CHECK_COMMAND(Header)
CHECK_COMMAND(Render)
CHECK_COMMAND(Body)
CHECK_COMMAND(Status)
CHECK_COMMAND(Headers)
CHECK_COMMAND(SetCookie)
CHECK_COMMAND(ClearCookies)
CHECK_COMMAND(GetCookies)
CHECK_COMMAND(Headers)
CHECK_COMMAND(SetProxy)
CHECK_COMMAND(ConsoleMessages)