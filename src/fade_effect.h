#ifndef FADE_EFFECT_H_
#define FADE_EFFECT_H_

#include <SFML/Graphics.hpp>

class FadeEffect : public sf::Drawable {
public:
  FadeEffect();
  virtual ~FadeEffect();

  void Update(float delta);

  void FadeIn(float time = 1.0f);
  void FadeOut(float time = 1.0f);

  inline bool IsDone() { return done_; }

private:
  sf::RectangleShape rect_;
  sf::Color color_;

  float timer_;
  float fade_time_;
  bool done_;
  bool in_;

  virtual void draw(sf::RenderTarget& target, sf::RenderStates states) const;
};

#endif
