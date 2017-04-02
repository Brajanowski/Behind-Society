#ifndef TILEMAP_H_
#define TILEMAP_H_

#include <SFML/Graphics.hpp>
#include <vector>

struct Tile {
  unsigned int tile_number;
  int type;

  Tile(unsigned int tile_num = 0, int type = 0) :
      tile_number(tile_num), type(type) { }
  virtual ~Tile() { }
};

class Tilemap : public sf::Drawable {
public:
  Tilemap(const sf::Vector2u& size = sf::Vector2u(20, 12), 
          const sf::Vector2u& tile_size = sf::Vector2u(16, 16), 
          const Tile& init_tile = Tile());
  virtual ~Tilemap();

  void SetTexture(const sf::Texture& texture);
  void Generate();

  void SetTile(const sf::Vector2u& pos, const Tile& tile);
  Tile GetTile(const sf::Vector2u& pos);

  sf::VertexArray& GetVertexArray() { return va_; }

private:
  sf::Vector2u size_;
  sf::Vector2u tile_size_;
  sf::VertexArray va_;
  sf::Texture texture_;
  std::vector<Tile> tiles_;

  virtual void draw(sf::RenderTarget& target, sf::RenderStates states) const;
};

#endif
