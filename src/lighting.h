#ifndef LIGHTING_H_
#define LIGHTING_H_

#include <SFML/Graphics.hpp>

struct PointLight {
  sf::Vector2f pos;
  sf::Color color;
  float radius;
  float intensity;

  PointLight() : 
    pos(sf::Vector2f(0, 0)),
    color(sf::Color::White),
    radius(256),
    intensity(15) { }
};

struct SpotLight {
  sf::Vector2f pos;
  sf::Vector2f dir;
  float angle;
  sf::Color color;
  float radius;
  float intensity;

  SpotLight() : 
    pos(sf::Vector2f(0, 0)),
    dir(sf::Vector2f(0, 1)),
    angle(30.0f),
    color(sf::Color::White),
    radius(256.0f),
    intensity(15.0f) { }
};

#endif

