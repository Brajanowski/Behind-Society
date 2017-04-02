#include "engine.h"
#include <iostream>

#ifdef _WIN32
#include <windows.h>
#endif

int main(int argc, char** argv) {
#ifdef _WIN32
# ifndef DEBUG
ShowWindow(GetConsoleWindow(), SW_HIDE);
# endif
#endif
  Engine engine;
  int result = engine.Run();
  if (result != 0) {
    std::cout << "Something went wrong: " << result << std::endl;
    return result;
  }
#ifdef _WIN32
# ifndef DEBUG
ShowWindow(GetConsoleWindow(), SW_SHOW);
# endif
#endif

  return 0;
}
