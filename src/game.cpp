#include "game.h"
#include "engine.h"
#include "to_string.h"
#include "icon.c"
#include <iostream>

Game::Game(Engine* engine) :
    engine(engine) {
  handler.SetFrameSize(sf::IntRect(0, 0, 16, 32));
  handler.AddAnimation(Animation(0, 3, 1.0f));
  handler.AddAnimation(Animation(0, 3, 1.0f));
  handler.Play(1);

  gamedata.money = 0;
  gamedata.day = 1;
  gamedata.fans = 0;
  gamedata.current_abode = 0;
  gamedata.seed = 123;
  gamedata.place_computer_mode = false;
}

Game::~Game() {
}

void Game::Init() {
  // render texture for effects
  render_texture.create(engine->window.getSize().x, engine->window.getSize().y);
  render_texture.setSmooth(false);


  sf::Texture logo;
  gamedata.group_logo.create(game_icon.width, game_icon.height, 
                             game_icon.pixel_data);
  logo.loadFromImage(gamedata.group_logo);

  engine->resource_manager.AddTexture("group_logo", logo);
  engine->script_engine.GetGlobal("Gameplay")["Init"]();

}

void Game::Update() {
  engine->script_engine.GetGlobal("Gameplay")["Update"]();

  for (unsigned int i = 0; i < gamedata.hackers.size(); i++) {
    auto sprite = engine->renderer.GetObject(0, "hacker " + to_string(i));
    if (sprite != nullptr) {
      sprite->sprite.setTextureRect(handler.GetBounds());
    }
  }

  handler.Update(engine->delta_time);
}

void Game::Draw(sf::RenderTarget *target) {
  render_texture.clear(sf::Color::Black);
  render_texture.setView(engine->game_view);
    
  if (gamedata.draw_gameplay && gamedata.abodes.size() > 0) {
    for (unsigned int i = 0; i < gamedata.hackers.size(); i++) {
      if (gamedata.hackers[i].computer != -1) {
        Computer computer = gamedata.computers[gamedata.hackers[i].computer];

        std::string skin_path = "./assets/graphics/people/";

        if (i == 0) {
          skin_path += "player_" + to_string(gamedata.hackers[i].skin_id) + ".png";
        } else {
          skin_path += to_string(gamedata.hackers[i].skin_id) + ".png";
        }

        engine->renderer.Draw(3, "hacker " + to_string(i),
                              skin_path, sf::Color::White,
                              handler.GetBounds(),
                              sf::Vector2f(computer.x * 16 + (computer.right ? (32 - 5) : (-16 + 5)), computer.y * 16 - 2 - 16),
                              sf::Vector2f(computer.right ? -1 : 1, 1));
      }
    }

    for (unsigned int i = 0; i < gamedata.computers.size(); i++) {
      if (gamedata.computers[i].abode_id < 0)
        continue;

      engine->renderer.Draw(4, "computer " + to_string(i),
                            "assets/graphics/computers/computer_" +
                            std::string(gamedata.computers[i].company == 0 ? "red" : "blue") + "_" + to_string(gamedata.computers[i].generation) + ".png",
                            sf::Color::White,
                            sf::IntRect(0, 0, 32, 32),
                            sf::Vector2f(gamedata.computers[i].x * 16 - (gamedata.computers[i].right ? -32 : 16), gamedata.computers[i].y * 16 - 16),
                            sf::Vector2f(gamedata.computers[i].right ? -1 : 1, 1), "default");
    }
  }

  engine->renderer.DrawAll(&render_texture);

  if (gamedata.place_computer_mode) {
    static sf::RectangleShape rect;
    rect.setSize(sf::Vector2f(320, 180));
    rect.setPosition(sf::Vector2f(0, 0));
    rect.setFillColor(sf::Color(0, 0, 0, 96));
    render_texture.draw(rect);

    for (unsigned int y = 0; y < 12; y++) {
      for (unsigned int x = 0; x < 20; x++) {
        if (gamedata.abodes[0].tilemap.GetTile(sf::Vector2u(x, y)).type == 2) {
          rect.setSize(sf::Vector2f(16, 16));
          rect.setPosition(sf::Vector2f(x * 16, y * 16 - 2));
          rect.setFillColor(sf::Color(32, 160, 32, 64));
          render_texture.draw(rect);
        }
      }
    }

    auto view = target->getView();
    render_texture.setView(target->getDefaultView());

    rect.setFillColor(sf::Color(155, 155, 171, 96));

    float scale = (float)engine->window.getSize().x / 320.0f;

    for (unsigned int y = 0; y < 12; y++) {
      rect.setSize(sf::Vector2f(320 * scale, 1));
      rect.setPosition(sf::Vector2f(0, y * (16 * scale) - (2 * scale)));
      render_texture.draw(rect);
    }

    for (unsigned int x = 0; x < 20; x++) {
      if (x == 0)
        continue;
      rect.setSize(sf::Vector2f(1, 180 * scale));
      rect.setPosition(sf::Vector2f(x * (16 * scale), 0));
      render_texture.draw(rect);
    }

    render_texture.setView(view);
  }
  

  render_texture.setView(engine->window.getDefaultView());

  // display textures
  render_texture.display();

  // draw frame to the screen and apply postfx if there is any
  sf::Sprite frame_sprite(render_texture.getTexture());

  if (engine->effects.IsFX()) {
    engine->effects.Update();
    target->draw(frame_sprite, engine->effects.GetShader());
  } else {
    target->draw(frame_sprite);
  }

  // IKSDE?
  // RenderObject object;
  // object.draw = true;
  // object.type = TYPE_TEXT;
  // object.text.setFont(engine->resource_manager.GetFont("./assets/fonts/PressStart2P.ttf"));
  // object.text.setCharacterSize(32);
  // object.text.setPosition(sf::Vector2f(100, 100));
  // object.text.setColor(sf::Color::White);
  // object.text.setString("DAY 2");

  // target->draw(object.text);

}

