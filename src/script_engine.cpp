#include "script_engine.h"
#include "engine.h"

#include <iostream>

ScriptEngine::ScriptEngine(Engine *engine) :
    engine_(engine) {
  L_ = luaL_newstate();
  luaL_openlibs(L_);
}

ScriptEngine::~ScriptEngine() {
  lua_close(L_);
}

bool ScriptEngine::LoadScript(const std::string& filename) {
  if (luaL_loadfile(L_, filename.c_str()) || lua_pcall(L_, 0, 0, 0)) {
    //std::cout << "lua error in file \"" << filename << "\": " << lua_tostring(L_, -1) << std::endl;
    engine_->console.Log("lua error in file \"" + filename + "\": " +  std::string(lua_tostring(L_, -1)));
    return false;
  }
  return true;
}

void ScriptEngine::Execute(const std::string& script) {
  if ((luaL_loadstring(L_, script.c_str()) || lua_pcall(L_, 0, LUA_MULTRET, 0))) {
    engine_->console.Log("lua error: " + std::string(lua_tostring(L_, -1)));
  }
}

luabridge::LuaRef ScriptEngine::GetGlobal(const std::string& name) {
  return luabridge::getGlobal(L_, name.c_str());
}
