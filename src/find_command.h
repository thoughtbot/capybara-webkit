#define CHECK_COMMAND(expectedName) \
  if (strcmp(#expectedName, name) == 0) { \
    return new expectedName(m_page, this); \
  }

CHECK_COMMAND(Visit)
CHECK_COMMAND(Find)
CHECK_COMMAND(Reset)
CHECK_COMMAND(Attribute)
CHECK_COMMAND(Url)
