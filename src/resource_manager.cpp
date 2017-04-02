#include "resource_manager.h"
#include "engine.h"

ResourceManager::ResourceManager(Engine *engine) :
    engine_(engine) {
}

ResourceManager::~ResourceManager() {
}

sf::Texture& ResourceManager::GetTexture(const std::string& filename) {
  auto it = textures_.find(filename);

  if (it != textures_.end()) {
    return it->second;
  } else {
    sf::Texture texture;
    texture.loadFromFile(filename);
    textures_[filename] = texture;
    return textures_[filename];
  }
}

void ResourceManager::LoadTexture(const std::string& filename) {
  auto it = textures_.find(filename);

  if (it != textures_.end()) {
    engine_->console.Log("Texture \"" + filename + "\"" + " is already loaded.");
  } else {
    sf::Texture texture;
    texture.loadFromFile(filename);
    textures_[filename] = texture;
  }
}

void ResourceManager::AddTexture(const std::string& name, const sf::Texture& texture) {
  auto it = textures_.find(name);

  if (it != textures_.end()) {
    engine_->console.Log("Texture \"" + name + "\"" + " is already loaded.");
  } else {
    textures_[name] = texture;
  } 
}

sf::Font& ResourceManager::GetFont(const std::string& filename) {
  auto it = fonts_.find(filename);

  if (it != fonts_.end()) {
    return it->second;
  } else {
    sf::Font font;
    font.loadFromFile(filename);
    fonts_[filename] = font;
    return fonts_[filename];
  }
}

void ResourceManager::LoadFont(const std::string& filename) {
  auto it = fonts_.find(filename);

  if (it != fonts_.end()) {
    engine_->console.Log("Font \"" + filename + "\"" + " is already loaded.");
  } else {
    sf::Font font;
    font.loadFromFile(filename);
    fonts_[filename] = font;
  }
}

void ResourceManager::AddFont(const std::string& name, const sf::Font& font) {
  auto it = fonts_.find(name);

  if (it != fonts_.end()) {
    engine_->console.Log("Font \"" + name + "\"" + " is already loaded.");
  } else {
    fonts_[name] = font;
  } 
}

sf::SoundBuffer& ResourceManager::GetSoundBuffer(const std::string& filename) {
  auto it = soundbuffers_.find(filename);

  if (it != soundbuffers_.end()) {
    return it->second;
  } else {
    sf::SoundBuffer sound;
    sound.loadFromFile(filename);
    soundbuffers_[filename] = sound;
    return soundbuffers_[filename];
  }
}

void ResourceManager::LoadSoundBuffer(const std::string& filename) {
  auto it = soundbuffers_.find(filename);

  if (it != soundbuffers_.end()) {
    engine_->console.Log("Sound \"" + filename + "\"" + " is already loaded.");
  } else {
    sf::SoundBuffer sound;
    sound.loadFromFile(filename);
    soundbuffers_[filename] = sound;
  }
}

sf::Shader& ResourceManager::GetShader(const std::string& name) {
  auto it = shaders_.find(name);

  if (it != shaders_.end()) {
    return it->second;
  } else {
    //shaders_[name] = sf::Shader();
    shaders_[name].loadFromFile("./assets/effects/default.vert", sf::Shader::Vertex);
    shaders_[name].loadFromFile("./assets/effects/" + name + ".frag", sf::Shader::Fragment);
    return shaders_[name];
  }
}

