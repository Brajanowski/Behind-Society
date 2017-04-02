#ifndef RENDERER_H_
#define RENDERER_H_

#include <SFML/Graphics.hpp>
#include <map>
#include <string>

enum RenderObjectType {
  TYPE_SPRITE,
  TYPE_TEXT
};

struct RenderObject {
  RenderObjectType type;
  sf::Sprite sprite;
  sf::Color color;
  bool draw;
  std::string texture_path;
  std::string effect_name;
  sf::Text text;
};

#define MAX_LAYERS 5

class Engine;
class Renderer {
public:
  Renderer(Engine *engine);
  virtual ~Renderer();

  void Draw(unsigned int layer, const std::string& id,
            const std::string& sprite_path, const sf::Color& color, const sf::IntRect& rect,
            const sf::Vector2f& position,
            const sf::Vector2f& scale = sf::Vector2f(1, 1),
            const std::string& effect = std::string("default"));

  void DrawText(unsigned int layer, const std::string& id, const std::string& text, const std::string& font, 
                int char_size, const sf::Vector2f& pos, const sf::Color& color);
  void DrawAll(sf::RenderTarget* target);

  RenderObject* GetObject(unsigned int layer, const std::string& id);

private:
  Engine *engine_;

  std::map<std::string, RenderObject> objects_[MAX_LAYERS];

  void RemoveUnusedObjects();
};

#endif

