#include "fade_effect.h"

FadeEffect::FadeEffect() :
    color_(sf::Color::Black),
    timer_(0),
    fade_time_(0.0f),
    done_(false),
    in_(false) {
  rect_.setSize(sf::Vector2f(1, 1));
}

FadeEffect::~FadeEffect() {
}

void FadeEffect::Update(float delta) {
  if (!done_) {
    timer_ += delta;
    if (timer_ >= fade_time_) {
      done_ = true;

      if (in_)
        rect_.setFillColor(color_);
      else
        rect_.setFillColor(sf::Color::Transparent);
      return;
    }

    sf::Color start = color_;
    sf::Color end = sf::Color::Transparent;

    if (in_) {
      start = sf::Color::Transparent;
      end = color_;
    }

    #define lerp(a, b, t) a + t * (b - a)
    sf::Color color = start;

    color.r = lerp(start.r, end.r, timer_ / fade_time_);
    color.g = lerp(start.g, end.g, timer_ / fade_time_);
    color.b = lerp(start.b, end.b, timer_ / fade_time_);
    color.a = lerp(start.a, end.a, timer_ / fade_time_);

    rect_.setFillColor(color);
    #undef lerp
  }
}

void FadeEffect::FadeIn(float time) {
  fade_time_ = time;
  in_ = true;
  done_ = false;
  timer_ = 0;
  
  rect_.setFillColor(sf::Color::Transparent);
}

void FadeEffect::FadeOut(float time) {
  fade_time_ = time;
  in_ = false;
  done_ = false;
  timer_ = 0;

  rect_.setFillColor(color_);
}

void FadeEffect::draw(sf::RenderTarget& target, sf::RenderStates states) const {
  sf::View old_view = target.getView();

  sf::View view = target.getView();
  view.setCenter(0.5f, 0.5f);
  view.setSize(1, 1);

  target.setView(view);
  target.draw(rect_);

  target.setView(old_view);
}
