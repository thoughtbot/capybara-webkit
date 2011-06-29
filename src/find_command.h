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
CHECK_COMMAND(UserAgent)
