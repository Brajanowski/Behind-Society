#ifndef RESOURCE_MANAGER_H_
#define RESOURCE_MANAGER_H_

#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <string>
#include <map>

class Engine;
class ResourceManager {
public:
  ResourceManager(Engine *engine);
  virtual ~ResourceManager();

  sf::Texture& GetTexture(const std::string& filename);
  void LoadTexture(const std::string& filename);
  void AddTexture(const std::string& name, const sf::Texture& texture);

  sf::Font& GetFont(const std::string& filename);
  void LoadFont(const std::string& filename);
  void AddFont(const std::string& name, const sf::Font& font);

  sf::SoundBuffer& GetSoundBuffer(const std::string& filename);
  void LoadSoundBuffer(const std::string& filename);

  sf::Shader& GetShader(const std::string& filename);

private:
  Engine *engine_;
  std::map<std::string, sf::Texture> textures_;
  std::map<std::string, sf::Font> fonts_;
  std::map<std::string, sf::SoundBuffer> soundbuffers_;
  std::map<std::string, sf::Shader> shaders_;
};

#endif
