#ifndef COMPUTER_H_
#define COMPUTER_H_

struct Computer {
  int x, y;
  bool right;
  int generation;
  int upgrade_level;
  int abode_id;
  int company; // 0 - red, 1 - blue

  Computer(int x = 0, int y = 0) :
      x(x),
      y(y),
      right(false),
      generation(1),
      upgrade_level(0),
      abode_id(-1),
      company(0) { }
};

#endif
