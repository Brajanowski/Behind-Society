#ifndef INPUT_H_
#define INPUT_H_

#include <SFML/Window/Keyboard.hpp>
#include <SFML/Window/Mouse.hpp>

struct Input {
  int mouse_x;
  int mouse_y;

  bool is_focused;

  bool keys[sf::Keyboard::KeyCount];
  bool keys_down[sf::Keyboard::KeyCount];
  bool keys_up[sf::Keyboard::KeyCount];

  bool buttons[sf::Mouse::ButtonCount];
  bool buttons_down[sf::Mouse::ButtonCount];
  bool buttons_up[sf::Mouse::ButtonCount];

  char last_input;
  bool is_input;
};

#endif
