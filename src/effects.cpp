#include "effects.h"
#include "engine.h"
#include <SFML/Graphics.hpp>

Effects::Effects(Engine* engine) :
    engine_(engine),
    is_fx_(false) {
}

Effects::~Effects() {
}

void Effects::SetPostFX(const std::string& name) {
  if (!shader_.loadFromFile("./assets/effects/default.vert", 
                            sf::Shader::Vertex)) {
    return;
  }

  if (!shader_.loadFromFile(std::string("./assets/effects/" + name + ".frag"), 
                            sf::Shader::Fragment)) {
    return;
  }

  is_fx_ = true;
}

void Effects::Update() {
  shader_.setParameter("time", engine_->time);
  shader_.setParameter("texture", sf::Shader::CurrentTexture);
  shader_.setParameter("resolution", 
                       sf::Vector2f(engine_->window.getSize().x, 
                                    engine_->window.getSize().y));
}

void Effects::SetFloat(const std::string& key, float value) {
  shader_.setParameter(key, value);
}

