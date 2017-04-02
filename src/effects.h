#ifndef EFFECTS_H_
#define EFFECTS_H_

#include <SFML/Graphics.hpp>
#include <string>

class Engine;
class Effects {
public:
  Effects(Engine* engine);
  virtual ~Effects();

  void SetPostFX(const std::string& name);
  void Update();
  
  inline bool IsFX() { return is_fx_; }
  inline void DisableFX() { is_fx_ = false; }
  inline sf::Shader* GetShader() { return &shader_; }

  void SetFloat(const std::string& key, float value);

private:
  Engine* engine_;
  bool is_fx_;
  sf::Shader shader_;
};

#endif

