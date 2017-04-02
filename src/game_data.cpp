#include "game_data.h"
#include "to_string.h"

#include <iostream> // REMOVE THAT LATER
#include <fstream>

#define SAVES_DIR "./saves/"

bool IsSlotFree(unsigned int slot) {
  std::ifstream file(std::string(SAVES_DIR + to_string(slot) + ".save"));

  if (file.good()) {
    file.close();
    return false;
  }

  return true;
}

void DeleteSlot(unsigned int slot) {
  std::remove(std::string(SAVES_DIR + to_string(slot) + ".save").c_str());
}

GameData LoadGameData(unsigned int slot) { 
  GameData gamedata;
  gamedata.draw_gameplay = false;
  gamedata.place_computer_mode = false;
  size_t size = 0;

  std::ifstream file(std::string(SAVES_DIR + to_string(slot) + ".save"),
                     std::ios::binary);

  if (!file.good()) {
    return gamedata;
  }

  // group name
  file.read((char*)&size, sizeof(size_t));
  gamedata.group_name = std::string(size, '\0');
  file.read(&gamedata.group_name[0], size);

  // game single stats
  file.read((char*)&gamedata.logo, sizeof(int));
  file.read((char*)&gamedata.day, sizeof(int));
  file.read((char*)&gamedata.money, sizeof(int));
  file.read((char*)&gamedata.fans, sizeof(int));
  file.read((char*)&gamedata.security, sizeof(int));
  file.read((char*)&gamedata.current_abode, sizeof(int));
  file.read((char*)&gamedata.rent, sizeof(int));
  file.read((char*)&gamedata.rent_paid, sizeof(bool));
  file.read((char*)&gamedata.red_company_generation, sizeof(int));
  file.read((char*)&gamedata.blue_company_generation, sizeof(int));
  file.read((char*)&gamedata.red_company_tech_points, sizeof(int));
  file.read((char*)&gamedata.blue_company_tech_points, sizeof(int));
  file.read((char*)&gamedata.seed, sizeof(int));

  // read all quests_vars
  file.read((char*)&size, sizeof(size_t));

  for (size_t i = 0, sz = size; i < sz; i++) {
    std::string key;
    int value;

    file.read((char*)&size, sizeof(size_t));
    key = std::string(size, '\0');
    file.read(&key[0], size);

    file.read((char*)&value, sizeof(int));

    gamedata.quests_vars[key] = value;
  }

  // abodes
  file.read((char*)&size, sizeof(size_t));
  for (unsigned int i = 0, num = size; i < num; i++) {
    Abode abode;
    
    // name
    file.read((char*)&size, sizeof(size_t));
    abode.name = std::string(size, '\0');
    file.read(&abode.name[0], size);
  }

  // hackers
  file.read((char*)&size, sizeof(size_t));
  for (unsigned int i = 0, num = size; i < num; i++) {
    Hacker hacker;

    // name
    file.read((char*)&size, sizeof(size_t));
    hacker.name = std::string(size, '\0');
    file.read(&hacker.name[0], size);

    // other single statistics
    file.read((char*)&hacker.is_cop, sizeof(bool));
    file.read((char*)&hacker.personality, sizeof(int));
    file.read((char*)&hacker.age, sizeof(int));
    file.read((char*)&hacker.salary, sizeof(int));
    file.read((char*)&hacker.days_to_quit, sizeof(int));
    file.read((char*)&hacker.skin_id, sizeof(int));
    file.read((char*)&hacker.computer, sizeof(int));
    file.read((char*)&hacker.task, sizeof(int));
    file.read((char*)&hacker.level, sizeof(int));
    file.read((char*)&hacker.experience, sizeof(int));
    file.read((char*)&hacker.science_points, sizeof(int));
    file.read((char*)&hacker.cracking, sizeof(int));
    file.read((char*)&hacker.security, sizeof(int));
  
    gamedata.hackers.push_back(hacker);
  }

  // computers
  file.read((char*)&size, sizeof(size_t));
  for (unsigned int i = 0, num = size; i < num; i++) {
    Computer computer;
    
    file.read((char*)&computer, sizeof(Computer));

    gamedata.computers.push_back(computer);
  }

  // companies
  file.read((char*)&size, sizeof(size_t));
  for (unsigned int i = 0, num = size; i < num; i++) {
    Company company("noname");
    
    // name
    file.read((char*)&size, sizeof(size_t));
    company.name = std::string(size, '\0');
    file.read(&company.name[0], size);

    // other single statistics
    file.read((char*)&company.break_time, sizeof(int));
    file.read((char*)&company.popularity, sizeof(int));
    file.read((char*)&company.people_love, sizeof(int));
    file.read((char*)&company.security, sizeof(int));
    file.read((char*)&company.type, sizeof(int));

    gamedata.companies.push_back(company);
  }

  // tasks
  file.read((char*)&size, sizeof(size_t));
  for (unsigned int i = 0, num = size; i < num; i++) {
    Task task;
    
    // name
    file.read((char*)&size, sizeof(size_t));
    task.name = std::string(size, '\0');
    file.read(&task.name[0], size);

    // other single statistics
    file.read((char*)&task.type, sizeof(int));
    file.read((char*)&task.points, sizeof(int));
    file.read((char*)&task.points_to_finish, sizeof(int));
    file.read((char*)&task.company_id, sizeof(int));
    file.read((char*)&task.reward, sizeof(int));
    file.read((char*)&task.days_to_finish, sizeof(int));
    file.read((char*)&task.money, sizeof(int));

    gamedata.tasks.push_back(task);
  }

  file.close();

  return gamedata;
}

void SaveGameData(unsigned int slot, GameData& gamedata) {
  std::ofstream file(std::string(SAVES_DIR + to_string(slot) + ".save"), 
                     std::ios::binary | std::ios::out);

  size_t size = 0;

  // save group_name
  size = gamedata.group_name.size();
  file.write((char*)&size, sizeof(size_t));
  file.write(gamedata.group_name.c_str(), size);

  // single statistics
  file.write((char*)&gamedata.logo, sizeof(int));
  file.write((char*)&gamedata.day, sizeof(int));
  file.write((char*)&gamedata.money, sizeof(int));
  file.write((char*)&gamedata.fans, sizeof(int));
  file.write((char*)&gamedata.security, sizeof(int));
  file.write((char*)&gamedata.current_abode, sizeof(int));
  file.write((char*)&gamedata.rent, sizeof(int));
  file.write((char*)&gamedata.rent_paid, sizeof(bool));
  file.write((char*)&gamedata.red_company_generation, sizeof(int));
  file.write((char*)&gamedata.blue_company_generation, sizeof(int));
  file.write((char*)&gamedata.red_company_tech_points, sizeof(int));
  file.write((char*)&gamedata.blue_company_tech_points, sizeof(int));
  file.write((char*)&gamedata.seed, sizeof(int));

  // quest vars
  size = gamedata.quests_vars.size();
  file.write((char*)&size, sizeof(size_t));

  for (auto it = gamedata.quests_vars.begin(); it != gamedata.quests_vars.end(); ++it) {
    size = it->first.size();
    file.write((char*)&size, sizeof(size_t));
    file.write(it->first.c_str(), size);
    file.write((char*)&it->second, sizeof(int));
  }

  // abodes
  size = gamedata.abodes.size();
  file.write((char*)&size, sizeof(size_t));
  for (unsigned int i = 0; i < gamedata.abodes.size(); i++) {
    // name
    size = gamedata.abodes[i].name.size();
    file.write((char*)&size, sizeof(size_t));
    file.write(gamedata.abodes[i].name.c_str(), size);
  }

  // hackers
  size = gamedata.hackers.size();
  file.write((char*)&size, sizeof(size_t));
  for (unsigned int i = 0; i < gamedata.hackers.size(); i++) {
    size = gamedata.hackers[i].name.size();
    file.write((char*)&size, sizeof(size_t));
    file.write(gamedata.hackers[i].name.c_str(), size);
    
    // other single statistics
    file.write((char*)&gamedata.hackers[i].is_cop, sizeof(bool));
    file.write((char*)&gamedata.hackers[i].personality, sizeof(int));
    file.write((char*)&gamedata.hackers[i].age, sizeof(int));
    file.write((char*)&gamedata.hackers[i].salary, sizeof(int));
    file.write((char*)&gamedata.hackers[i].days_to_quit, sizeof(int));
    file.write((char*)&gamedata.hackers[i].skin_id, sizeof(int));
    file.write((char*)&gamedata.hackers[i].computer, sizeof(int));
    file.write((char*)&gamedata.hackers[i].task, sizeof(int));
    file.write((char*)&gamedata.hackers[i].level, sizeof(int));
    file.write((char*)&gamedata.hackers[i].experience, sizeof(int));
    file.write((char*)&gamedata.hackers[i].science_points, sizeof(int));
    file.write((char*)&gamedata.hackers[i].cracking, sizeof(int));
    file.write((char*)&gamedata.hackers[i].security, sizeof(int));
  }

  // computers
  size = gamedata.computers.size();
  file.write((char*)&size, sizeof(size_t));
  for (unsigned int i = 0; i < gamedata.computers.size(); i++) {
    file.write((char*)&gamedata.computers[i], sizeof(Computer));
  }

  // companies
  size = gamedata.companies.size();
  file.write((char*)&size, sizeof(size_t));
  for (unsigned int i = 0; i < gamedata.companies.size(); i++) {
    // name
    size = gamedata.companies[i].name.size();
    file.write((char*)&size, sizeof(size_t));
    file.write(gamedata.companies[i].name.c_str(), size);
    
    // other single statistics
    file.write((char*)&gamedata.companies[i].break_time, sizeof(int));
    file.write((char*)&gamedata.companies[i].popularity, sizeof(int));
    file.write((char*)&gamedata.companies[i].people_love, sizeof(int));
    file.write((char*)&gamedata.companies[i].security, sizeof(int));
    file.write((char*)&gamedata.companies[i].type, sizeof(int));
  }

  // tasks
  size = gamedata.tasks.size();
  file.write((char*)&size, sizeof(size_t));
  for (unsigned int i = 0; i < gamedata.tasks.size(); i++) {
    // name
    size = gamedata.tasks[i].name.size();
    file.write((char*)&size, sizeof(size_t));
    file.write(gamedata.tasks[i].name.c_str(), size);

    // other single statistics
    file.write((char*)&gamedata.tasks[i].type, sizeof(int));
    file.write((char*)&gamedata.tasks[i].points, sizeof(int));
    file.write((char*)&gamedata.tasks[i].points_to_finish, sizeof(int));
    file.write((char*)&gamedata.tasks[i].company_id, sizeof(int));
    file.write((char*)&gamedata.tasks[i].reward, sizeof(int));
    file.write((char*)&gamedata.tasks[i].days_to_finish, sizeof(int));
    file.write((char*)&gamedata.tasks[i].money, sizeof(int));
  }

  file.close();
}

