#include "engine.h"
#include "imgui/imgui.h"
#include "imgui/imgui-SFML.h"
#include "to_string.h"
#include "icon.c"

#include <iostream>
#include <fstream>

#ifdef _WIN32
#include <windows.h>
#elif __linux__
#include <dirent.h>
#endif

#include "tilemap.h"

void ScriptBinds(Engine* engine);

Engine::Engine() :
    is_fullscreen(false),
    fps_max(-1),
    volume(100.0f),
    script_engine(this),
    renderer(this),
    resource_manager(this),
    game(this),
    console(this),
    effects(this),
    clear_color(sf::Color::Black),
    delta_time(0),
    fps(0),
    time(0) {
}

Engine::~Engine() {
  ImGui::SFML::Shutdown();
}

int Engine::Run() {
  // Read app config from lua configuration file
  // Config data
  unsigned int window_width = 1280;
  unsigned int window_height = 720;

  console.Log("Load config from \"app_config.lua\"");
  script_engine.LoadScript("app_config.lua");

  window_width      = 
    script_engine.GetGlobal("window")["width"].cast<unsigned int>();
  window_height     = 
    script_engine.GetGlobal("window")["height"].cast<unsigned int>();
  is_fullscreen = 
    script_engine.GetGlobal("window")["fullscreen"].cast<int>() != 0;
  fps_max   = 
    script_engine.GetGlobal("window")["fps_max"].cast<unsigned int>();
  volume  =
    script_engine.GetGlobal("volume").cast<float>();

  // check aspect ratio
  float aspect_ratio = (float)window_width / (float)window_height;

  if (aspect_ratio != (16.0f / 9.0f)) {
    console.Log("Aspect ratio should be 16/9 or game will look weird.");
  }

  if (window_width < 1024 ||
      window_height < 576) {
    window_width = 1024;
    window_height = 576;

    console.Log("Resolution is too small, minimum is 1024x576");
    console.Log("Changing to 1024x576");
  }

  // Bind all engine stuff to script engine
  ScriptBinds(this);

  // Load all scripts
  LoadScripts();

  // Open window
  int flags = sf::Style::Titlebar | sf::Style::Close;

  if (is_fullscreen)
    flags |= sf::Style::Fullscreen;

  console.Log("Creating window, size: " + 
              to_string(window_width) + "x" + to_string(window_height));

  window.create(sf::VideoMode(window_width, window_height), 
                "Behind Society", 
                flags);
  window.setIcon(game_icon.width, game_icon.height, game_icon.pixel_data);

  // Checking
  console.Log("Checking shaders...");
  if (sf::Shader::isAvailable()) {
    console.Log("Shaders are available.");
  } else {
    console.Log("Shaders are not available!");
  }

  if (fps_max > 0)
    window.setFramerateLimit(fps_max);

  // init input
  input.is_input = false;
  input.last_input = 'a';

  // gui stuff
  ImGui::SFML::Init(window);

  // init game
  game.Init();

  // helpful object to calculate delta time
  sf::Clock clock;

  uint32_t fps_counter = 0;
  float fps_time = 0;

  // set up game view
  game_view.setSize(320, 180);
  game_view.setCenter(160, 90);

  // set up some imgui stuff here
  // ImGuiStyle& style = ImGui::GetStyle();
  // style.AntiAliasedLines = false;
  // style.AntiAliasedShapes = false;

  // Main loop
  while (window.isOpen()) {
    // get elapsed time from end of last frame
    sf::Time elapsed = clock.restart();
    delta_time = elapsed.asSeconds();
    time += delta_time;

    // calc fps
    fps_counter++;
    fps_time += delta_time;

    if (fps_time >= 1.0f) {
      fps = fps_counter;
      fps_counter = 0;
      fps_time = 0;
    }

    // Handle events
    HandleEvents();

    // update
    ImGui::SFML::Update(elapsed);
    game.Update();
    console.Update();

    // update effects
    fade_effect.Update(delta_time);

    // render
    window.clear(clear_color);
    
    game.Draw(&window);

    // gui
    ImGui::Render();
    
    // draw effects
    window.draw(fade_effect);
    
    window.display();
  }
  return 0;
}

void Engine::Exit() {
  window.close();
}

void Engine::HandleEvents() {
  // Update input
  for (unsigned int i = 0; i < sf::Keyboard::KeyCount; i++) {
    input.keys_down[i] = false;
    input.keys_up[i] = false;
  }

  for (unsigned int i = 0; i < sf::Mouse::ButtonCount; i++) {
    input.buttons_down[i] = false;
    input.buttons_up[i] = false;
  }

  sf::Event event;
  while (window.pollEvent(event)) {
    ImGui::SFML::ProcessEvent(event);
    switch (event.type) {
      case sf::Event::Closed:         window.close(); break;
      case sf::Event::LostFocus:      input.is_focused = false; break;
      case sf::Event::GainedFocus:    input.is_focused = true; break;
      case sf::Event::KeyPressed:
        input.keys[event.key.code] = true; 
        input.keys_down[event.key.code] = true; 
        break;

      case sf::Event::KeyReleased:
        input.keys[event.key.code] = false; 
        input.keys_up[event.key.code] = true; 
        break;

      case sf::Event::MouseButtonPressed:
        input.buttons[event.mouseButton.button] = true; 
        input.buttons_down[event.mouseButton.button] = true; 
        break;

      case sf::Event::MouseButtonReleased:
        input.buttons[event.mouseButton.button] = false; 
        input.buttons_up[event.mouseButton.button] = true; 
        break;

      case sf::Event::MouseMoved:
        input.mouse_x = event.mouseMove.x; 
        input.mouse_y = event.mouseMove.y; 
        break;

      case sf::Event::TextEntered:
        if (event.text.unicode < 128) {
          input.last_input = static_cast<char>(event.text.unicode);
          input.is_input = true;
        }
        break;
      default: break;
    }
  }
}

void Engine::LoadScripts() {
  #if _WIN32
  HANDLE hFind;
  WIN32_FIND_DATA data;

  hFind = FindFirstFile("./assets/gameplay/*.lua", &data);
  if (hFind != INVALID_HANDLE_VALUE) {
    do {
      script_engine.LoadScript("./assets/gameplay/" + 
                               std::string(data.cFileName));
    } while (FindNextFile(hFind, &data));
    FindClose(hFind);
  }

  #elif __linux__
  DIR *dir;
  struct dirent *ent;
  if ((dir = opendir("./assets/gameplay/")) != NULL) {
    while ((ent = readdir(dir)) != NULL) {
      std::string filename(ent->d_name);
      size_t dot_offset = filename.rfind(".");
      if (filename == "." || filename == ".." || 
          filename.substr(dot_offset + 1) != "lua")
        continue;
      script_engine.LoadScript("./assets/gameplay/" + filename);
    }
    closedir (dir);
  } else {
    perror ("");
    return;
  }
  #else
    #error "Unsupported platform! Engine::LoadScripts()"
  #endif
}

void Engine::SaveSettings() {
  std::ofstream file("app_config.lua");

  file << "window = {\n"
       << "width      = " << to_string(window.getSize().x) << ",\n"
       << "height     = " << to_string(window.getSize().y) << ",\n"
       << "fps_max    = " << to_string(fps_max) << ",\n"
       << "fullscreen = " << (is_fullscreen ? "1" : "0") << "\n"
       << "}\n"
       << "volume = " << to_string(volume);

  file.close();
}

