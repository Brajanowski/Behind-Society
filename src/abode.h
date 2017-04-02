#ifndef ABODE_H_
#define ABODE_H_

#include <string>
#include <vector>

#include "tilemap.h"

struct Abode {
  std::string name;
  Tilemap tilemap;

  Abode(const std::string& name = "unknown") : name(name) { }

  // wrappers for lua bridge
  void SetTile(unsigned int x, unsigned int y, const Tile& tile) { 
    tilemap.SetTile(sf::Vector2u(x, y), tile); 
  }

  Tile GetTile(unsigned int x, unsigned int y) { 
    return tilemap.GetTile(sf::Vector2u(x, y));
  }

  void GenerateTilemap() { tilemap.Generate(); }

  void SetTileset(const char *filename) {  }
};

#endif
