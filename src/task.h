#ifndef TASK_H_
#define TASK_H_

#include <string>

struct Task {
  std::string name;
  int type;
  int points;
  int points_to_finish;
  int company_id;
  int reward;
  int days_to_finish;
  int money;

  Task() :
      name("no name"),
      type(-1),
      points(0),
      points_to_finish(0),
      company_id(-1),
      reward(0),
      days_to_finish(-1),
      money(0) { }
};

#endif
