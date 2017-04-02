#ifndef ANIMATION_H_
#define ANIMATION_H_

class Animation {
 public:
  Animation(unsigned int start_frame, unsigned int end_frame, float duration) :
    start_(start_frame),
    end_(end_frame),
    duration_(duration) { }

  inline unsigned int GetStartFrame() { return start_; }
  inline unsigned int GetEndFrame()   { return end_; }
  inline float GetDuration()          { return duration_; }
  inline unsigned int GetLength()     { return end_ - start_ + 1; }

 private:
  unsigned int start_;
  unsigned int end_;
  float duration_;
};


#endif
