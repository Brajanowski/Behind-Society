#include "engine.h"
#include "imgui/imgui.h"
#include "imgui/imgui-SFML.h"
#include "animation_handler.h"

static Engine* engine;

// input function wrappers
bool GetKey(int code) {
  return engine->input.keys[code];
}

bool GetKeyDown(int code) {
  return engine->input.keys_down[code];
}

bool GetKeyUp(int code) {
  return engine->input.keys_up[code];
}

bool GetMouseButton(int code) {
  return engine->input.buttons[code];
}

bool GetMouseButtonDown(int code) {
  return engine->input.buttons_down[code];
}

bool GetMouseButtonUp(int code) {
  return engine->input.buttons_up[code];
}

sf::Vector2f GetWorldMousePosition() {
  return engine->window.mapPixelToCoords(sf::Vector2i(engine->input.mouse_x, engine->input.mouse_y), engine->game_view);
}

std::string InputGetLastInput() {
  engine->input.is_input = false;
  return std::string(1, engine->input.last_input);
}

bool InputIsCharInput() {
  return engine->input.is_input;
}

// console
void ConsoleLog(const char* txt) {
  engine->console.Log(std::string(txt));
}

void ConsoleClear() {
  engine->console.Clear();
}

// engine
void EngineSaveSetting() {
  engine->SaveSettings();
}

void EngineExit() {
  engine->Exit();
}

// audio
static sf::Music current_music;
void AudioPlayMusic(const char* path) {
  //current_music.setBuffer(engine->resource_manager.GetSoundBuffer(std::string(path)));
  current_music.openFromFile(std::string(path));
  current_music.setVolume(engine->volume);
  current_music.setLoop(true);
  current_music.play();
}

void AudioStopMusic() {
  current_music.stop();
}

static sf::Sound current_sound;
void AudioPlaySound(const char* path) {
  current_sound.setBuffer(engine->resource_manager.GetSoundBuffer(std::string(path)));
  current_sound.setVolume(engine->volume);
  current_sound.play();
}

void AudioSetVolume(float volume) {
  engine->volume = volume;
  current_sound.setVolume(volume);
  current_music.setVolume(volume);
  engine->SaveSettings();
}

float AudioGetVolume() {
  return engine->volume;
}

// renderer
void RendererSetClearColor(sf::Color color) {
  engine->clear_color = color;
}

sf::Color& RendererGetClearColor() {
  return engine->clear_color;
}

void RendererDraw(int layer, const char *id, const char *path, const sf::Color& color,
                  const sf::IntRect& rect, const sf::Vector2f& position, 
                  const sf::Vector2f& scale, const char* shader) {
  engine->renderer.Draw(layer, std::string(id),
                        std::string(path), color, rect, position, scale,
                        std::string(shader));
}

void RendererDrawText(int layer, const char *id, const char *text, 
                      const char *font, int char_size, const sf::Vector2f& pos, 
                      const sf::Color& color) {
  engine->renderer.DrawText(layer, std::string(id), 
                            std::string(text), std::string(font), 
                            char_size, pos, color);
}

void RendererSetWindowSize(const sf::Vector2f& size) {
  int flags = sf::Style::Titlebar | sf::Style::Close;
  
  if (engine->is_fullscreen) {
    flags |= sf::Style::Fullscreen;
  }

  engine->window.create(sf::VideoMode(size.x, size.y),
                        "Behind Society",
                        flags);
  engine->game.render_texture.create(size.x, size.y);
}

sf::Vector2f RendererGetWindowSize() {
  return (sf::Vector2f)engine->window.getSize();//sf::Vector2f((float)engine->window.getSize().x, (float)engine->window.getSize().y);
}

void RendererSetFpsMax(int fps) {
  if (fps > 0) {
    engine->window.setFramerateLimit(fps);
  } else {
    engine->window.setFramerateLimit(0);
  }
}

bool RendererIsFullscreen() {
  return engine->is_fullscreen;
}

void RendererSetFullscreen(bool active) {
  if (active == engine->is_fullscreen)
    return;

  sf::Vector2u current_size = engine->window.getSize();

  int flags = sf::Style::Titlebar | sf::Style::Close;

  if (active) {
    flags |= sf::Style::Fullscreen;
  }

  engine->window.create(sf::VideoMode(current_size.x, current_size.y),
                        "Behind Society",
                        flags);
}

// gui
static bool paint_prepared = false;
static sf::Sprite paint_preview_bg;

static sf::RectangleShape paint_pointer;

void GuiGroupLogoPaint(const sf::Vector2f& pos) {
  if (!paint_prepared) {
    paint_preview_bg.setTexture(
      engine->resource_manager.GetTexture("./assets/graphics/gui/paint_bg.png")
    );

    paint_pointer.setFillColor(sf::Color::Red);
    paint_pointer.setSize(sf::Vector2f(128, 128));
    paint_prepared = true;
  }

  paint_preview_bg.setScale(512 / 128, 512 / 128);
  paint_preview_bg.setOrigin(64, 64);
  paint_preview_bg.setPosition(1280 / 2, 720 / 2);

  engine->window.setView(engine->window.getDefaultView());
  engine->window.draw(paint_preview_bg);
  engine->window.draw(paint_pointer);
}

void GuiBegin(const char *title) {
  ImGui::Begin(title);
}

bool GuiBeginClosable(const char *title) {
  bool active = true;
  ImGui::Begin(title, &active);
  return active;
}

int GetFlagsFromString(const std::string& flags_str) {
  int flags = 0;

  if (flags_str.find("NoTitleBar") != std::string::npos)
    flags |= ImGuiWindowFlags_NoTitleBar;
  if (flags_str.find("NoResize") != std::string::npos)
    flags |= ImGuiWindowFlags_NoResize;
  if (flags_str.find("NoMove") != std::string::npos)
    flags |= ImGuiWindowFlags_NoMove;
  if (flags_str.find("NoScrollbar") != std::string::npos)
    flags |= ImGuiWindowFlags_NoScrollbar;
  if (flags_str.find("NoScrollWithMouse") != std::string::npos)
    flags |= ImGuiWindowFlags_NoScrollWithMouse;
  if (flags_str.find("NoCollapse") != std::string::npos)
    flags |= ImGuiWindowFlags_NoCollapse;
  if (flags_str.find("AlwaysAutoResize") != std::string::npos)
    flags |= ImGuiWindowFlags_AlwaysAutoResize;
  if (flags_str.find("ShowBorders") != std::string::npos)
    flags |= ImGuiWindowFlags_ShowBorders;
  if (flags_str.find("NoSavedSettings") != std::string::npos)
    flags |= ImGuiWindowFlags_NoSavedSettings;
  if (flags_str.find("NoInputs") != std::string::npos)
    flags |= ImGuiWindowFlags_NoInputs;
  if (flags_str.find("MenuBar") != std::string::npos)
    flags |= ImGuiWindowFlags_MenuBar;
  if (flags_str.find("HorizontalScrollbar") != std::string::npos)
    flags |= ImGuiWindowFlags_HorizontalScrollbar;
  if (flags_str.find("NoFocusOnAppearing") != std::string::npos)
    flags |= ImGuiWindowFlags_NoFocusOnAppearing;
  if (flags_str.find("AlwaysVerticalScrollbar") != std::string::npos)
    flags |= ImGuiWindowFlags_AlwaysVerticalScrollbar;
  if (flags_str.find("AlwaysHorizontalScrollbar") != std::string::npos)
    flags |= ImGuiWindowFlags_AlwaysHorizontalScrollbar;
  if (flags_str.find("AlwaysUseWindowPadding") != std::string::npos)
    flags |= ImGuiWindowFlags_AlwaysUseWindowPadding;
  
  return flags;
}

void GuiBeginFlags(const char *title, const char *flags_) {
  std::string flags_str = std::string(flags_);
  ImGui::Begin(title, 0, GetFlagsFromString(flags_str));
}

bool GuiBeginFlagsClosable(const char *title, const char *flags_) {
  std::string flags_str = std::string(flags_);
  bool active = true;
  ImGui::Begin(title, &active, GetFlagsFromString(flags_str));
  return active;
}

void GuiBeginChild(const char *id, const sf::Vector2f& size, bool border) {
  ImGui::BeginChild(id, ImVec2(size.x, size.y), border);
}

bool GuiButton(const char *text, const sf::Vector2f& size) {
  return ImGui::Button(text, size);
}

bool GuiImageButton(const char *image, const sf::Vector2f& size) {
  return ImGui::ImageButton(engine->resource_manager.GetTexture(std::string(image)), ImVec2(size.x, size.y));
}

void GuiImage(const char *image, const sf::Vector2f& size, 
              const sf::FloatRect& rect) {
  ImGui::Image(engine->resource_manager.GetTexture(std::string(image)), ImVec2(size.x, size.y), rect);
}

void GuiTextWrapped(const char *text) {
  ImGui::TextWrapped(text);
}

void GuiText(const char *text) {
  ImGui::Text(text);
}

#include <sstream>

ImVec4 StringToImVec4(const std::string& str) {
  std::stringstream ss(str);
  int r, g, b, a;
  char c;

  ss >> c >> r >> c >> g >> c >> b >> c >> a;

  return ImVec4(r / 255.0f, g / 255.0f, b / 255.0f, a / 255.0f);
}

void GuiTextExpanded(const char *text) {
  std::string str(text);

  int colors_to_pop = 0;
  int string_part_begin = 0;
  for (unsigned int i = 0; i < str.length(); i++) {
    if (str[i] == '{') {
      if (string_part_begin > 0)
        ImGui::SameLine(0, 0);

      ImGui::Text(str.substr(string_part_begin, i - string_part_begin).c_str());
      
      unsigned int color_begin = 0;
      for (color_begin = i; str[++i] != '}';);
      string_part_begin = ++i;

      std::string col = str.substr(color_begin, i - color_begin);
      if (col == "{pop}") {
        ImGui::PopStyleColor(1);
        colors_to_pop--;
      } else {
        ImGui::PushStyleColor(ImGuiCol_Text, StringToImVec4(col));
        colors_to_pop++;
      }
    }
    
    if (i == str.length() - 1) {
      if (string_part_begin > 0)
        ImGui::SameLine(0, 0);

      ImGui::Text(str.substr(string_part_begin, std::string::npos).c_str());
    }
  }

  ImGui::PopStyleColor(colors_to_pop);
}

std::string SkipColorsInString(const std::string& text) {
  std::string result = "";

  for (unsigned int i = 0; i < text.length(); i++) {
    if (text[i] == '{') {
      for (; text[++i] != '}';);

      ++i;
    }

    result += text[i];
  }

  return result;
}

void GuiTextExpandedCentered(const char* text, const char* options) {
  std::string str = SkipColorsInString(std::string(text));
  std::string opt(options);
  
  ImVec2 text_size = ImGui::CalcTextSize(str.c_str());
  ImVec2 old_cursor_pos = ImGui::GetCursorPos();

  if (opt.find("h") != std::string::npos) {
    ImGui::SetCursorPosX(ImGui::GetWindowWidth() / 2 - text_size.x / 2);
  }

  if (opt.find("v") != std::string::npos) {
    ImGui::SetCursorPosY(ImGui::GetWindowHeight() / 2 - text_size.y / 2);
  }

  GuiTextExpanded(text);

  ImGui::SetCursorPos(old_cursor_pos);
}

// TODO: FINISH THAT
bool GuiInputText(const char* label, char* input_buffer, int length) {
  /*if ((int)input_buffer.size() < length) {
    input_buffer.resize(length);
  }*/

  return ImGui::InputText(label, input_buffer, length, ImGuiInputTextFlags_EnterReturnsTrue);
}

bool GuiSliderFloat(const char* label, float value, float min, float max) {
  return ImGui::SliderFloat(label, &value, min, max);
}

std::string ColorToString(const sf::Color& color) {
  std::stringstream ss;
  ss << "{" << (int)color.r << "," 
    << (int)color.g << "," 
    << (int)color.b << "," 
    << (int)color.a << "}";
  return ss.str();
}

void GuiNextWindowSize(int x, int y) {
  ImGui::SetNextWindowSize(ImVec2(x, y));
}

void GuiNextWindowPos(int x, int y) {
  ImGui::SetNextWindowPos(ImVec2(x, y));
}

void GuiPushStyleVarFloat(int index, float var) {
  ImGui::PushStyleVar(index, var);
}

void GuiPushStyleVarVector2f(int index, const sf::Vector2f& var) {
  ImGui::PushStyleVar(index, ImVec2(var.x, var.y));
}

void GuiSetStyleVarVector2f(int index, const sf::Vector2f& var) {
  ImGuiStyle& style = ImGui::GetStyle();

  switch (index) {
    case 0: style.WindowTitleAlign = var; break;
    default: ConsoleLog("lua api: SetStyleVarVector2f: unsupported variable");
  }
}

void GuiSetStyleVarFloat(int index, float var) {
  ImGuiStyle& style = ImGui::GetStyle();

  switch (index) {
    case 1: style.ScrollbarSize = var; break;
    case 2: style.ScrollbarRounding = var; break;
    default: ConsoleLog("lua api: SetStyleVarFloat: unsupported variable");
  }
}

void GuiPushStyleColor(int index, const sf::Color& color) {
  ImGui::PushStyleColor(index, ImVec4(color.r / 255.0f, color.g / 255.0f, color.b / 255.0f, color.a / 255.0f));
}

sf::Vector2f GuiCalcTextSize(const char* text) {
  ImVec2 size = ImGui::CalcTextSize(text, NULL, false, -1.0f);

  return sf::Vector2f(size.x, size.y);
}

void GuiPushID(const char* id) {
  ImGui::PushID(id);
}

#include "imgui/imconfig.h"

static sf::Texture font_texture;

void GuiClearFonts() {
  ImGuiIO& io = ImGui::GetIO();
  io.Fonts->Clear();
}

void GuiGenerateFontTexture() {
  ImGuiIO& io = ImGui::GetIO();

  unsigned char* pixels;
  int width, height;
  io.Fonts->GetTexDataAsRGBA32(&pixels, &width, &height);

  font_texture.create(width, height);
  font_texture.update(pixels);
  font_texture.setSmooth(false);
  io.Fonts->TexID = (void*)&font_texture;

  io.Fonts->ClearInputData();
  io.Fonts->ClearTexData();
}

ImFont* GuiLoadFontTTF(const char* filename, float pixel_size) {
  ImGuiIO& io = ImGui::GetIO();
  ImFont* font = io.Fonts->AddFontFromFileTTF(filename, pixel_size);
  
  return font;
}

// effects
void EffectsFadeIn(float time) {
  engine->fade_effect.FadeIn(time);
}

void EffectsFadeOut(float time) {
  engine->fade_effect.FadeOut(time);
}

bool EffectsIsFadeDone() {
  return engine->fade_effect.IsDone();
}

static std::string last_fx;

void EffectsSetFX(const char *str) {
  if (last_fx != std::string(str)) {
    engine->effects.SetPostFX(std::string(str));
    last_fx = std::string(str);
  }
}

void EffectsDisableFX() {
  last_fx = std::string();
  engine->effects.DisableFX();
}

void EffectsSetFloat(const char* name, float value) {
  engine->effects.SetFloat(std::string(name), value);
}

// math
#define MATH_FUNC_VEC2(name, op) \
sf::Vector2f name(sf::Vector2f *a, sf::Vector2f *b) {\
  if (a == nullptr || b == nullptr) {\
    if (a == nullptr)\
      ConsoleLog("lua api: Math #op left pointer is equal to null!");\
    else if (b == nullptr)\
      ConsoleLog("lua api: Math #op right pointer is equal to null!");\
    else\
      ConsoleLog("lua api: Math #op pointers are equals to null!");\
    return sf::Vector2f(0, 0);\
  }\
  return sf::Vector2f(a->x op b->x, a->y op b->y);\
}

MATH_FUNC_VEC2(MathAdd, +);
MATH_FUNC_VEC2(MathSub, -);
MATH_FUNC_VEC2(MathMul, *);
MATH_FUNC_VEC2(MathDiv, /);

// class helpers
struct HackerHelper {
  static std::string GetName(const Hacker *hacker) { return hacker->name; }
  static void SetName(Hacker *hacker, const char *str) { hacker->name = std::string(str); }
};

struct AbodeHelper {
  static std::string GetName(const Abode *abode) { return abode->name; }
  static void SetName(Abode *abode, const char *str) { abode->name = std::string(str); }
};

struct CompanyHelper {
  static void SetName(Company* company, const char *str) { company->name = std::string(str); } 
  static std::string GetName(const Company *company) { return company->name; }
};

struct TaskHelper {
  static void SetName(Task *task, const char *str) { task->name = std::string(str); } 
  static std::string GetName(const Task *task) { return task->name; }
};

static void SetTileset(Abode *abode, const char *filename) {
  abode->tilemap.SetTexture(engine->resource_manager.GetTexture(filename));
}

std::string DataGetGroupName() {
  return engine->game.gamedata.group_name;
}

void DataSetGroupName(const char *name) {
  engine->game.gamedata.group_name = std::string(name);
}

void DataClear() {
  engine->game.gamedata.abodes.clear();
  engine->game.gamedata.computers.clear();
  engine->game.gamedata.hackers.clear();
  engine->game.gamedata.companies.clear();
  engine->game.gamedata.tasks.clear();
}

void DataSave(unsigned int slot) {
  SaveGameData(slot, engine->game.gamedata);
}

void DataLoad(unsigned int slot) {
  if (IsSlotFree(slot))
    return;
  
  engine->game.gamedata = LoadGameData(slot);
}

void DataPushAbode(const Abode& abode) {
  engine->game.gamedata.abodes.push_back(abode);
}

void DataRemoveAbode(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.abodes.size() - 1) {
    engine->console.Log("Wrong computer id in function: DataRemoveAbode");
    return;
  }

  engine->game.gamedata.abodes.erase(engine->game.gamedata.abodes.begin() + id);
}

void DataClearAbodes() {
  engine->game.gamedata.abodes.clear();
}


Abode* DataGetAbode(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.abodes.size() - 1) {
    engine->console.Log("Wrong abode id in function: DataGetAbode");
    return 0;
  }

  return &engine->game.gamedata.abodes[id];
}

int DataPushComputer(const Computer& computer) {
  engine->game.gamedata.computers.push_back(computer);
  return engine->game.gamedata.computers.size() - 1;
}

int DataGetComputersNumber() {
  return engine->game.gamedata.computers.size();
}

Computer* DataGetComputer(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.computers.size() - 1) {
    engine->console.Log("Wrong computer id in function: DataGetComputer");
    return nullptr;
  }

  return &engine->game.gamedata.computers[id];
}

void DataRemoveComputer(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.computers.size() - 1) {
    engine->console.Log("Wrong computer id in function: DataRemoveComputer");
    return;
  }

  engine->game.gamedata.computers.erase(engine->game.gamedata.computers.begin() + id);
}

bool DataIsComputerHere(int x, int y) {
  for (unsigned int i = 0; i < engine->game.gamedata.computers.size(); i++) {
    int faced = engine->game.gamedata.computers[i].right ? 1 : -1;
    
    if ((engine->game.gamedata.computers[i].x == x || engine->game.gamedata.computers[i].x + faced == x) &&
        engine->game.gamedata.computers[i].y == y && engine->game.gamedata.computers[i].abode_id != -1) {
      return true;
    }
  }
  return false;
}

int DataGetComputerId(int abode_id, int x, int y) {
  for (unsigned int i = 0; i < engine->game.gamedata.computers.size(); i++) {
    if (engine->game.gamedata.computers[i].abode_id == abode_id &&
        engine->game.gamedata.computers[i].x == x &&
         (engine->game.gamedata.computers[i].y == y || engine->game.gamedata.computers[i].y - 1 == y))
      return i;
  }
  return -1;
}

int DataGetHackerOnComputer(int computerid) {
  for (unsigned int i = 0; i < engine->game.gamedata.hackers.size(); i++) {
    if (engine->game.gamedata.hackers[i].computer == computerid) {
      return i;
    }
  }
  return -1;
}

int DataPushHacker(const Hacker& hacker) {
  engine->game.gamedata.hackers.push_back(hacker);
  return engine->game.gamedata.hackers.size() - 1;
}

Hacker* DataGetHacker(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.hackers.size() - 1) {
    engine->console.Log("Wrong id in function: DataGetHacker");
    return 0;
  }

  return &engine->game.gamedata.hackers[id];
}

void DataRemoveHacker(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.hackers.size() - 1) {
    engine->console.Log("Wrong id in function: DataRemoveHacker");
    return;
  }
  
  engine->game.gamedata.hackers.erase(engine->game.gamedata.hackers.begin() + id);
}

int DataGetHackersNumber() {
  return engine->game.gamedata.hackers.size();
}

int DataPushCompany(const Company& company) {
  engine->game.gamedata.companies.push_back(company);
  return engine->game.gamedata.companies.size() - 1;
}

void DataPushFrontCompany(const Company& company) {
  auto it = engine->game.gamedata.companies.begin();
  engine->game.gamedata.companies.insert(it, company);
}

void DataRemoveCompany(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.companies.size() - 1) {
    engine->console.Log("Wrong id in function: DataRemoveCompany");
    return;
  }
  
  engine->game.gamedata.companies.erase(engine->game.gamedata.companies.begin() + id);
}

void DataClearCompanies() {
  engine->game.gamedata.companies.clear();
}

Company* DataGetCompany(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.companies.size() - 1) {
    engine->console.Log("Wrong id in function: DataGetCompany");
    return 0;
  }

  return &engine->game.gamedata.companies[id];
}

int DataGetCompaniesNumber() {
  return engine->game.gamedata.companies.size();
}

int DataPushTask(const Task& task) {
  engine->game.gamedata.tasks.push_back(task);
  return engine->game.gamedata.tasks.size() - 1;
}

void DataRemoveTask(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.tasks.size() - 1) {
    engine->console.Log("Wrong id in function: DataRemoveTask");
    return;
  }

  engine->game.gamedata.tasks.erase(engine->game.gamedata.tasks.begin() + id);
}

Task* DataGetTask(int id) {
  if (id < 0 && (unsigned int)id > engine->game.gamedata.tasks.size() - 1) {
    engine->console.Log("Wrong id in function: DataGetTask");
    return 0;
  }

  return &engine->game.gamedata.tasks[id];
}

int DataGetTasksNumber() {
  return engine->game.gamedata.tasks.size();
}

int DataGetQuestVariable(const char* var) {
  auto it = engine->game.gamedata.quests_vars.find(std::string(var));

  if (it != engine->game.gamedata.quests_vars.end()) {
    return it->second;
  }
  return -1;
}

void DataSetQuestVariable(const char* var, int value) {
  engine->game.gamedata.quests_vars[std::string(var)] = value;
}

void ScriptBinds(Engine* eng) {
  lua_State* L = eng->script_engine.GetState();
  engine = eng;

  luabridge::getGlobalNamespace(L)
    .beginNamespace("Input")
      .addFunction("IsCharInput", &InputIsCharInput)
      .addFunction("GetLastInput", &InputGetLastInput)
      .beginNamespace("Keyboard")
        .addFunction("GetKey", &GetKey)
        .addFunction("GetKeyDown", &GetKeyDown)
        .addFunction("GetKeyUp", &GetKeyUp)
      .endNamespace()
      .beginNamespace("Mouse")
        .addVariable("x", &engine->input.mouse_x, false)
        .addVariable("y", &engine->input.mouse_y, false)
        .addFunction("GetMouseButton", &GetMouseButton)
        .addFunction("GetMouseButtonDown", &GetMouseButtonDown)
        .addFunction("GetMouseButtonUp", &GetMouseButtonUp)
      .endNamespace()
      .addFunction("GetWorldMousePosition", &GetWorldMousePosition)
    .endNamespace()
    .beginNamespace("Time")
      .addVariable("delta_time", &engine->delta_time)
      .addVariable("fps", &engine->fps)
      .addVariable("time", &engine->time)
    .endNamespace()
    .beginNamespace("Console")
      .addFunction("Log", &ConsoleLog)
      .addFunction("Clear", &ConsoleClear)
    .endNamespace()
    .beginNamespace("Engine")
      .addFunction("SaveSettings", &EngineSaveSetting)
      .addFunction("Exit", &EngineExit)
    .endNamespace()
    .beginNamespace("Game")
      .beginClass<Tile>("Tile")
        .addConstructor<void (*) (unsigned int, int)>()
        .addData("tile_number", &Tile::tile_number)
        .addData("type", &Tile::type)
      .endClass()
      .beginClass<Abode>("Abode")
        .addConstructor<void (*) (const char*)>()
        .addProperty("name", &AbodeHelper::GetName, &AbodeHelper::SetName)
        .addFunction("SetTile", &Abode::SetTile)
        .addFunction("GetTile", &Abode::GetTile)
        .addFunction("GenerateTilemap", &Abode::GenerateTilemap)
        .addStaticFunction("SetTileset", &SetTileset)
      .endClass()
      .beginClass<Hacker>("Hacker")
        .addConstructor<void (*) (const char*)>()
        .addProperty("name", &HackerHelper::GetName, &HackerHelper::SetName)
        .addData("is_cop", &Hacker::is_cop)
        .addData("personality", &Hacker::personality)
        .addData("age", &Hacker::age)
        .addData("salary", &Hacker::salary)
        .addData("days_to_quit", &Hacker::days_to_quit)
        .addData("skin_id", &Hacker::skin_id)
        .addData("computer", &Hacker::computer)
        .addData("task", &Hacker::task)
        .addData("level", &Hacker::level)
        .addData("experience", &Hacker::experience)
        .addData("science_points", &Hacker::science_points)
        .addData("cracking", &Hacker::cracking)
        .addData("security", &Hacker::security)
      .endClass()
      .beginClass<Computer>("Computer")
        .addConstructor<void (*) ()>()
        .addData("generation", &Computer::generation)
        .addData("x", &Computer::x)
        .addData("y", &Computer::y)
        .addData("abode_id", &Computer::abode_id)
        .addData("right", &Computer::right)
        .addData("company", &Computer::company)
        .addData("upgrade_level", &Computer::upgrade_level)
      .endClass()
      .beginClass<Company>("Company")
        .addConstructor<void (*) (const char*)>()
        .addProperty("name", &CompanyHelper::GetName, &CompanyHelper::SetName)
        .addData("break_time", &Company::break_time)
        .addData("popularity", &Company::popularity)
        .addData("people_love", &Company::people_love)
        .addData("security", &Company::security)
        .addData("type", &Company::type)
      .endClass()
      .beginClass<Task>("Task")
        .addConstructor<void (*) ()>()
        .addProperty("name", &TaskHelper::GetName, &TaskHelper::SetName)
        .addData("type", &Task::type)
        .addData("reward", &Task::reward)
        .addData("company_id", &Task::company_id)
        .addData("points", &Task::points)
        .addData("points_to_finish", &Task::points_to_finish)
        .addData("days_to_finish", &Task::days_to_finish)
        .addData("money", &Task::money)
      .endClass()
      .beginNamespace("Data")
        .addProperty("group_name", &DataGetGroupName, &DataSetGroupName)
        .addVariable("logo", &engine->game.gamedata.logo)
        .addVariable("money", &engine->game.gamedata.money)
        .addVariable("day", &engine->game.gamedata.day)
        .addVariable("fans", &engine->game.gamedata.fans)
        .addVariable("current_abode", &engine->game.gamedata.current_abode)
        .addVariable("rent", &engine->game.gamedata.rent)
        .addVariable("rent_paid", &engine->game.gamedata.rent_paid)
        .addVariable("red_company_generation", 
            &engine->game.gamedata.red_company_generation)
        .addVariable("blue_company_generation", 
            &engine->game.gamedata.blue_company_generation)
        .addVariable("red_company_tech_points", 
            &engine->game.gamedata.red_company_tech_points)
        .addVariable("blue_company_tech_points", 
            &engine->game.gamedata.blue_company_tech_points)
        .addVariable("seed", &engine->game.gamedata.seed)
        .addVariable("security", &engine->game.gamedata.security)
        .addVariable("draw_gameplay", &engine->game.gamedata.draw_gameplay)
        .addVariable("place_computer_mode", &engine->game.gamedata.place_computer_mode)
        .addFunction("Clear", &DataClear)
        .addFunction("DeleteSlot", &DeleteSlot)
        .addFunction("IsSlotFree", &IsSlotFree)
        .addFunction("Save", &DataSave)
        .addFunction("Load", &DataLoad)
        .addFunction("PushAbode", &DataPushAbode)
        .addFunction("RemoveAbode", &DataRemoveAbode)
        .addFunction("ClearAbodes", &DataClearAbodes)
        .addFunction("GetAbode", &DataGetAbode)
        .addFunction("PushComputer", &DataPushComputer)
        .addFunction("RemoveComputer", &DataRemoveComputer)
        .addFunction("GetComputersNumber", &DataGetComputersNumber)
        .addFunction("GetComputer", &DataGetComputer)
        .addFunction("GetComputerId", &DataGetComputerId)
        .addFunction("IsComputerHere", &DataIsComputerHere)
        .addFunction("GetHackerOnComputer", &DataGetHackerOnComputer)
        .addFunction("PushHacker", &DataPushHacker)
        .addFunction("RemoveHacker", &DataRemoveHacker)
        .addFunction("GetHackersNumber", &DataGetHackersNumber)
        .addFunction("GetHacker", &DataGetHacker)
        .addFunction("PushCompany", &DataPushCompany)
        .addFunction("PushFrontCompany", &DataPushFrontCompany)
        .addFunction("RemoveCompany", &DataRemoveCompany)
        .addFunction("ClearCompanies", &DataClearCompanies)
        .addFunction("GetCompany", &DataGetCompany)
        .addFunction("GetCompaniesNumber", &DataGetCompaniesNumber)
        .addFunction("PushTask", &DataPushTask)
        .addFunction("RemoveTask", &DataRemoveTask)
        .addFunction("GetTask", &DataGetTask)
        .addFunction("GetTaskNumber", &DataGetTasksNumber)
        .addFunction("SetQuestVariable", &DataSetQuestVariable)
        .addFunction("GetQuestVariable", &DataGetQuestVariable)
      .endNamespace()
    .endNamespace()
    .beginNamespace("Audio")
      .addFunction("PlayMusic", &AudioPlayMusic)
      .addFunction("StopMusic", &AudioStopMusic)
      .addFunction("PlaySound", &AudioPlaySound)
      .addFunction("SetVolume", &AudioSetVolume)
      .addFunction("GetVolume", &AudioGetVolume)
    .endNamespace()
    .beginNamespace("Renderer")
      .addFunction("SetFpsMax", &RendererSetFpsMax)
      .addFunction("SetFullscreen", &RendererSetFullscreen)
      .addFunction("IsFullscreen", &RendererIsFullscreen)
      .addFunction("SetClearColor", &RendererSetClearColor)
      .addFunction("GetClearColor", &RendererGetClearColor)
      .addFunction("Draw", &RendererDraw)
      .addFunction("DrawText", &RendererDrawText)
      .addFunction("SetWindowSize", &RendererSetWindowSize)
      .addFunction("GetWindowSize", &RendererGetWindowSize)
      .beginClass<Animation>("Animation")
        .addConstructor<void (*)(unsigned int, unsigned int, float)>()
      .endClass()
      .beginClass<AnimationHandler>("AnimationHandler")
        .addConstructor<void (*)()>()
        .addFunction("Update", &AnimationHandler::Update)
        .addFunction("Play", &AnimationHandler::Play)
        .addFunction("Stop", &AnimationHandler::Stop)
        .addFunction("AddAnimation", &AnimationHandler::AddAnimation)
        .addFunction("SetFrameSize", &AnimationHandler::SetFrameSize)
        .addFunction("GetBounds", &AnimationHandler::GetBounds)
        .addFunction("GetBoundsFloat", &AnimationHandler::GetBoundsFloat)
        .addFunction("GetFrameSize", &AnimationHandler::GetFrameSize)
      .endClass()
    .endNamespace()
    .beginNamespace("Effects")
      .addFunction("FadeIn", &EffectsFadeIn)
      .addFunction("FadeOut", &EffectsFadeOut)
      .addFunction("IsFadeDone", &EffectsIsFadeDone)
      .addFunction("SetFX", &EffectsSetFX)
      .addFunction("DisableFX", &EffectsDisableFX)
      .addFunction("SetFloat", &EffectsSetFloat)
    .endNamespace()
    .beginNamespace("Gui")
      .addFunction("GroupLogoPaint", &GuiGroupLogoPaint)
      .addFunction("ColorToString", &ColorToString)
      .addFunction("Begin", &GuiBegin)
      .addFunction("BeginClosable", &GuiBeginClosable)
      .addFunction("BeginFlags", &GuiBeginFlags)
      .addFunction("BeginFlagsClosable", &GuiBeginFlagsClosable)
      .addFunction("End", &ImGui::End)
      .addFunction("BeginChild", &GuiBeginChild)
      .addFunction("EndChild", &ImGui::EndChild)
      .addFunction("BeginGroup", &ImGui::BeginGroup)
      .addFunction("EndGroup", &ImGui::EndGroup)
      .addFunction("SetScrollHere", &ImGui::SetScrollHere)
      .addFunction("Indent", &ImGui::Indent)
      .addFunction("Unindent", &ImGui::Unindent)
      .addFunction("PushItemWidth", &ImGui::PushItemWidth)
      .addFunction("PopItemWidth", &ImGui::PopItemWidth)
      .addFunction("CalcItemWidth", &ImGui::CalcItemWidth)
      .addFunction("CalcTextSize", &GuiCalcTextSize)
      .addFunction("GetWindowWidth", &ImGui::GetWindowWidth)
      .addFunction("GetWindowHeight", &ImGui::GetWindowHeight)
      .addFunction("SetCursorPosX", &ImGui::SetCursorPosX)
      .addFunction("SetCursorPosY", &ImGui::SetCursorPosY)
      .addFunction("GetCursorPosX", &ImGui::GetCursorPosX)
      .addFunction("GetCursorPosY", &ImGui::GetCursorPosY)
      .addFunction("GetItemsLineHeightWithSpacing", &ImGui::GetItemsLineHeightWithSpacing)
      .addFunction("BeginTooltip", &ImGui::BeginTooltip)
      .addFunction("EndTooltip", &ImGui::EndTooltip)
      .addFunction("IsItemHovered", &ImGui::IsItemHovered)
      .addFunction("IsItemHoveredRect", &ImGui::IsItemHoveredRect)
      .addFunction("Button", &GuiButton)
      .addFunction("ImageButton", &GuiImageButton)
      .addFunction("Image", &GuiImage)
      .addFunction("Separator", &ImGui::Separator)
      .addFunction("TextWrapped", &GuiTextWrapped)
      .addFunction("Text", &GuiText)
      .addFunction("TextExpanded", &GuiTextExpanded)
      .addFunction("TextExpandedCentered", &GuiTextExpandedCentered)
      .addFunction("InputText", &GuiInputText)
      .addFunction("SliderFloat", &GuiSliderFloat)
      .addFunction("NewLine", &ImGui::NewLine)
      .addFunction("SameLine", &ImGui::SameLine)
      .addFunction("SetWindowFontScale", &ImGui::SetWindowFontScale)
      .addFunction("SetNextWindowSize", &GuiNextWindowSize)
      .addFunction("SetNextWindowPos", &GuiNextWindowPos)
      .addFunction("SetNextWindowFocus", &ImGui::SetNextWindowFocus)
      .addFunction("PushStyleColor", &GuiPushStyleColor)
      .addFunction("PushStyleFloat", &GuiPushStyleVarFloat)
      .addFunction("PushStyleVector2f", &GuiPushStyleVarVector2f)
      .addFunction("PopStyleColor", &ImGui::PopStyleColor)
      .addFunction("PopStyleVar", &ImGui::PopStyleVar)
      .addFunction("SetStyleVector2f", &GuiSetStyleVarVector2f)
      .addFunction("SetStyleFloat", &GuiSetStyleVarFloat)
      .addFunction("PushID", &GuiPushID)
      .addFunction("PopID", &ImGui::PopID)
      .addFunction("ClearFonts", &GuiClearFonts)
      .addFunction("GenerateFontTexture", &GuiGenerateFontTexture)
      .addFunction("LoadFontTTF", &GuiLoadFontTTF)
      .addFunction("PushFont", &ImGui::PushFont)
      .addFunction("PopFont", &ImGui::PopFont)
      .beginClass<ImFont>("Font")
      .endClass()
    .endNamespace()
    .beginNamespace("Math")
      .beginClass<sf::Vector2f>("Vector2f")
        .addConstructor<void (*) (float, float)>()
        .addData("x", &sf::Vector2f::x)
        .addData("y", &sf::Vector2f::y)
      .endClass()
      .addFunction("Add", &MathAdd)
      .addFunction("Sub", &MathSub)
      .addFunction("Mul", &MathMul)
      .addFunction("Div", &MathDiv)
      .beginClass<sf::Color>("Color")
        .addConstructor<void (*) (int, int, int, int)>()
        .addData("r", &sf::Color::r)
        .addData("g", &sf::Color::g)
        .addData("b", &sf::Color::b)
        .addData("a", &sf::Color::a)
      .endClass()
      .beginClass<sf::FloatRect>("FloatRect")
        .addConstructor<void (*) (float, float, float, float)>()
        .addData("left", &sf::FloatRect::left)
        .addData("top", &sf::FloatRect::top)
        .addData("width", &sf::FloatRect::width)
        .addData("height", &sf::FloatRect::height)
      .endClass()
       .beginClass<sf::IntRect>("IntRect")
        .addConstructor<void (*) (int, int, int, int)>()
        .addData("left", &sf::IntRect::left)
        .addData("top", &sf::IntRect::top)
        .addData("width", &sf::IntRect::width)
        .addData("height", &sf::IntRect::height)
      .endClass()     
    .endNamespace();
}
