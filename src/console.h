#ifndef CONSOLE_H_
#define CONSOLE_H_

#include <vector>
#include <string>

class Engine;
class Console {
public:
  Console(Engine* engine);
  virtual ~Console();

  void Update();

  void Log(const std::string& text);
  void Clear();

  void Exec(const std::string& str);

private:
  Engine* engine_;
  bool active_;
  bool update_scroll_pos_;
  std::vector<std::string> console_content_;
  std::string input_buffer_;
};

#endif
