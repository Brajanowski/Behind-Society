#ifndef HACKER_H_
#define HACKER_H_

#include <string>

struct Hacker {
  std::string name;
  bool is_cop;
  int personality;
  int age;
  int salary;
  int days_to_quit;
  int skin_id;
  int computer;
  int task;
  int level;
  int experience;
  int science_points;

  // statistics
  int cracking;
  int security;

  Hacker(const std::string& name = "no name") :
      name(name),
      is_cop(false),
      personality(0),
      age(18),
      salary(0),
      days_to_quit(-1),
      skin_id(0),
      computer(-1),
      task(-1),
      level(1),
      experience(0),
      science_points(0),
      cracking(1),
      security(1) { }
};

#endif
