#include "console.h"
#include "engine.h"
#include "imgui/imgui.h"
#include "imgui/imgui-SFML.h"

#ifdef DEBUG
#include <iostream>
#endif

Console::Console(Engine* engine) :
    engine_(engine),
    active_(false),
    update_scroll_pos_(false) {

    input_buffer_.resize(256);
}

Console::~Console() {
}

void Console::Update() {
  if (engine_->input.keys_down[sf::Keyboard::Tilde]) active_ = !active_;

  if (!active_)
    return;

  ImGui::SetNextWindowSize(ImVec2(640, 360), ImGuiSetCond_FirstUseEver);

  ImGui::Begin("Console", &active_, ImGuiWindowFlags_NoCollapse);
    ImGui::BeginChild("ScrollingArea", ImVec2(0, -ImGui::GetItemsLineHeightWithSpacing()), false, ImGuiWindowFlags_HorizontalScrollbar);
      for (unsigned int i = 0; i < console_content_.size(); i++)
        ImGui::TextWrapped(console_content_[i].c_str());
      if (update_scroll_pos_)
        ImGui::SetScrollHere(1.0f);
      update_scroll_pos_ = false;
    ImGui::EndChild();

    ImGui::Separator();

    if (ImGui::InputText("Type your command", &input_buffer_[0], input_buffer_.size(), ImGuiInputTextFlags_EnterReturnsTrue)) {
      Exec(input_buffer_);
      for (unsigned int i = 0; i < input_buffer_.size(); i++) input_buffer_[i] = '\0';
    }

  ImGui::End();
}

void Console::Log(const std::string& text) {
#ifdef DEBUG
  std::cout << text << std::endl;
#endif

  console_content_.push_back(text);
  update_scroll_pos_ = true;
}

void Console::Clear() {
  console_content_.clear();
}

void Console::Exec(const std::string& str) {

#ifdef DEBUG
  // execute lua code
  engine_->script_engine.Execute(str);
#else
  console_content_.push_back("Commands are only available in debug build.");
#endif
  
}
