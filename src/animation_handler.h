#ifndef ANIMATION_HANDLER_H_
#define ANIMATION_HANDLER_H_

#include <SFML/Graphics.hpp>
#include <string>
#include <vector>

#include "animation.h"

class AnimationHandler {
 public:
  AnimationHandler();
  virtual ~AnimationHandler();

  void Update(float delta);
  void AddAnimation(const Animation& animation);
  void Play(unsigned int animation);
  void Stop();

  inline void SetFrameSize(const sf::IntRect& size) { framesize_ = size; bounds_ = framesize_; }

  inline sf::IntRect GetBounds() { return bounds_; }
  inline sf::IntRect GetFrameSize() { return framesize_; }
  inline sf::FloatRect GetBoundsFloat() { return sf::FloatRect(bounds_.left, bounds_.top, bounds_.width, bounds_.height); }

 private:
  std::vector<Animation> animations_;
  float time_;
  bool is_playing_;
  uint32_t current_animation_;

  sf::IntRect bounds_;
  sf::IntRect framesize_;

  void SetFrameBounds(int frame, int animation);
};

#endif
