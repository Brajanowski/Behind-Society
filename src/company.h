#ifndef COMPANY_H_
#define COMPANY_H_

#include <string>

struct Company {
  std::string name;
  int break_time;
  int popularity;
  int people_love; // range from 0 to 100. 0-50 is hate, 50-100 is love
  int security;
  int type;

  Company(const std::string& name = "unknown") :
      name(name),
      break_time(0),
      popularity(0),
      people_love(50),
      security(0),
      type(0) { }
};

#endif
