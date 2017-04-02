#ifndef SCRIPT_ENGINE_H_
#define SCRIPT_ENGINE_H_

#include <string>

#ifdef _WIN32
#include <lua.hpp>
#else
#include <lua5.3/lua.hpp>
#endif

#include "LuaBridge/LuaBridge.h"

class Engine;
class ScriptEngine {
public:
  ScriptEngine(Engine *engine);
  virtual ~ScriptEngine();

  bool LoadScript(const std::string& filename);
  void Execute(const std::string& script);

  luabridge::LuaRef GetGlobal(const std::string& name);
  inline lua_State *GetState() { return L_; }

private:
  lua_State *L_;
  Engine *engine_;

};

#endif
