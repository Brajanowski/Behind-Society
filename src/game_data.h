#ifndef GAME_DATA_H_
#define GAME_DATA_H_

#include "abode.h"
#include "hacker.h"
#include "computer.h"
#include "task.h"
#include "company.h"

#include <SFML/Graphics.hpp>
#include <vector>

struct GameData {
  std::string group_name;
  int logo;
  int day;
  int money;
  int fans;
  int security;
  int current_abode;
  int rent;
  bool rent_paid;
  int red_company_generation;
  int blue_company_generation;
  int red_company_tech_points;
  int blue_company_tech_points;
  int seed;

  std::map<std::string, int> quests_vars;
  std::vector<Abode> abodes;
  std::vector<Hacker> hackers;
  std::vector<Computer> computers;
  std::vector<Company> companies;
  std::vector<Task> tasks;

  sf::Image group_logo;

  // do not save stuff under this line
  bool draw_gameplay;
  bool place_computer_mode;
};

bool IsSlotFree(unsigned int slot);
void DeleteSlot(unsigned int slot);
GameData LoadGameData(unsigned int slot);
void SaveGameData(unsigned int slot, GameData& gamedata);

#endif
