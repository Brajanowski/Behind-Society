#ifndef GAME_H_
#define GAME_H_

#include <SFML/Graphics.hpp>

#include "tilemap.h"
#include "game_data.h"
#include "fade_effect.h"

#include "animation_handler.h"

class Engine;
struct Game {
  Engine *engine;
  GameData gamedata;

  // TODO: remove that later, this is only temporary here
  sf::Sprite sprite;
  AnimationHandler handler;
  // --

  sf::RenderTexture render_texture;

  Game(Engine* engine);
  virtual ~Game();

  void Init();
  void Update();
  void Draw(sf::RenderTarget *target);
};

#endif
