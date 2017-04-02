#include "tilemap.h"

Tilemap::Tilemap(const sf::Vector2u& size,
                 const sf::Vector2u& tile_size,
                 const Tile& init_tile) :
    size_(size),
    tile_size_(tile_size) {
  tiles_.resize(size_.x * size_.y);
  for (unsigned int i = 0; i < size_.x * size_.y; i++)
    tiles_.push_back(init_tile);
}

Tilemap::~Tilemap() {
}

void Tilemap::SetTexture(const sf::Texture& texture) {
  texture_ = texture;
}

void Tilemap::Generate() {
  va_.clear();
  va_.setPrimitiveType(sf::Quads);
  va_.resize(size_.x * size_.y * 4);

  for (unsigned int i = 0; i < size_.x; i++) {
    for (unsigned int j = 0; j < size_.y; j++) {
      int tile_number = tiles_[i + j * size_.x].tile_number;

      int u = tile_number % (texture_.getSize().x / tile_size_.x);
      int v = tile_number / (texture_.getSize().x / tile_size_.y);

      sf::Vertex* quad = &va_[(i + j * size_.x) * 4];

      quad[0].position = sf::Vector2f(i * tile_size_.x, j * tile_size_.y);
      quad[1].position = sf::Vector2f((i + 1) * tile_size_.x, j * tile_size_.y);
      quad[2].position = sf::Vector2f((i + 1) * tile_size_.x, (j + 1) * tile_size_.y);
      quad[3].position = sf::Vector2f(i * tile_size_.x, (j + 1) * tile_size_.y);

      quad[0].texCoords = sf::Vector2f(u * tile_size_.x, v * tile_size_.y);
      quad[1].texCoords = sf::Vector2f((u + 1) * tile_size_.x, v * tile_size_.y);
      quad[2].texCoords = sf::Vector2f((u + 1) * tile_size_.x, (v + 1) * tile_size_.y);
      quad[3].texCoords = sf::Vector2f(u * tile_size_.x, (v + 1) * tile_size_.y);
    }
  }
}

void Tilemap::SetTile(const sf::Vector2u& pos, const Tile& tile) {
  tiles_[pos.x + pos.y * size_.x] = tile;
}

Tile Tilemap::GetTile(const sf::Vector2u& pos) {
  return tiles_[pos.x + pos.y * size_.x];
}

void Tilemap::draw(sf::RenderTarget& target, sf::RenderStates states) const {
  states.texture = &texture_;
  target.draw(va_, states);
}
