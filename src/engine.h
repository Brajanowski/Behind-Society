#ifndef ENGINE_H_
#define ENGINE_H_

// SFML stuff
#include <SFML/Graphics.hpp>

#include <vector>

#include "script_engine.h"
#include "resource_manager.h"
#include "game.h"
#include "input.h"
#include "console.h"
#include "renderer.h"
#include "effects.h"
#include "lighting.h"

struct Engine {
  sf::RenderWindow window;
  bool is_fullscreen;
  int fps_max;
  float volume;
  ScriptEngine script_engine;
  Input input;
  Renderer renderer;
  ResourceManager resource_manager;
  Game game;
  Console console;
  FadeEffect fade_effect;
  Effects effects;
  
  sf::Color clear_color;
  sf::View game_view;
  float delta_time;
  int fps;
  float time; // time in seconds since program started

  Engine();
  virtual ~Engine();

  int Run();
  void Exit();

  void HandleEvents();
  void LoadScripts();

  void SaveSettings();
};

#endif
