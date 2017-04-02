#include "animation_handler.h"

AnimationHandler::AnimationHandler() :
    time_(0),
    is_playing_(false),
    current_animation_(0) {
}

AnimationHandler::~AnimationHandler() {

}

void AnimationHandler::Update(float delta) {
  if (!is_playing_) return;

  float duration = animations_[current_animation_].GetDuration();

  // is there time for next frame?
  if ((int)((time_ + delta) / duration) > (int)(time_ / duration)) {
    int frame = int((time_ + delta) / duration);
    frame %= animations_[current_animation_].GetLength();

    SetFrameBounds(frame, current_animation_);
  }

  time_ += delta;

  if (time_ > duration * animations_[current_animation_].GetLength()) {
    time_ = 0.0f;
  }
}

void AnimationHandler::AddAnimation(const Animation& animation) {
  animations_.push_back(animation);
}

void AnimationHandler::Play(unsigned int animation) {
  // if try playing the same animation and animation is playing do nothing
  if (current_animation_ == animation && is_playing_)
    return;

  is_playing_ = true;
  current_animation_ = animation;
  time_ = 0.0f;

  // set up first frame on new animation
  SetFrameBounds(0, current_animation_);
}

void AnimationHandler::Stop() {
  is_playing_ = false;
}

void AnimationHandler::SetFrameBounds(int frame, int animation) {
  sf::IntRect rect = framesize_;
  rect.left = rect.width * frame;
  rect.top = rect.height * animation;

  bounds_ = rect;
}
