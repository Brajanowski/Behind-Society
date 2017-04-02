#include "renderer.h"
#include "engine.h"
#include <iostream>

Renderer::Renderer(Engine *engine) :
  engine_(engine) {
}

Renderer::~Renderer() {
}

void Renderer::Draw(unsigned int layer, const std::string& id, 
                    const std::string& sprite_path, const sf::Color& color,
                    const sf::IntRect& rect, const sf::Vector2f& position,
                    const sf::Vector2f& scale, const std::string& effect) {
  if (objects_[layer].find(id) != objects_[layer].end()) {
    objects_[layer][id].draw = true;
    objects_[layer][id].type = TYPE_SPRITE;
    objects_[layer][id].color = color;
    objects_[layer][id].sprite.setPosition(position);
    objects_[layer][id].sprite.setScale(scale);
    objects_[layer][id].sprite.setTextureRect(rect);
    objects_[layer][id].effect_name = effect;
  } else {
    engine_->console.Log("Loading new sprite. id = " + id + ", file = " + sprite_path);

    RenderObject object;
    object.draw = true;
    object.type = TYPE_SPRITE;
    object.color = color;
    object.sprite.setTexture(engine_->resource_manager.GetTexture(sprite_path));
    object.sprite.setPosition(position);
    object.sprite.setScale(scale);
    object.sprite.setTextureRect(rect);
    object.effect_name = effect;
    objects_[layer][id] = object;
  }
}

void Renderer::DrawText(unsigned int layer, const std::string& id, const std::string& text, const std::string& font, 
                        int char_size, const sf::Vector2f& pos, const sf::Color& color) {
  if (objects_[layer].find(id) != objects_[layer].end()) {
    objects_[layer][id].draw = true;
    objects_[layer][id].type = TYPE_TEXT;
    objects_[layer][id].text.setFont(engine_->resource_manager.GetFont(font));
    objects_[layer][id].text.setCharacterSize(char_size);
    objects_[layer][id].text.setPosition(pos);
    objects_[layer][id].text.setColor(color);
    objects_[layer][id].text.setString(text);
    objects_[layer][id].sprite.setPosition(pos);
  } else {
    engine_->console.Log("Loading new text. id = " + id + ", font = " + font);

    RenderObject object;
    object.draw = true;
    object.type = TYPE_TEXT;
    object.text.setFont(engine_->resource_manager.GetFont(font));
    object.text.setCharacterSize(char_size);
    object.text.setPosition(pos);
    object.text.setColor(color);
    object.text.setString(text);
    objects_[layer][id] = object;
  }
}

void Renderer::DrawAll(sf::RenderTarget* target) {
  RemoveUnusedObjects();

  for (unsigned int i = 0; i < MAX_LAYERS; i++) {
    for (auto it = objects_[i].begin(); it != objects_[i].end(); ++it) {
      if (it->second.type == TYPE_SPRITE) {
        if (it->second.effect_name == "default") {
          it->second.sprite.setColor(it->second.color);
          target->draw(it->second.sprite);
          it->second.sprite.setColor(sf::Color::White);
        } else {
          sf::Shader& shader =
                engine_->resource_manager.GetShader(it->second.effect_name);
          shader.setParameter("texture", sf::Shader::CurrentTexture);
          shader.setParameter("color", it->second.color);
          target->draw(it->second.sprite, &shader);
        }
      } else if (it->second.type == TYPE_TEXT) {
        engine_->game.render_texture.setView(engine_->window.getDefaultView());
        target->draw(it->second.text);
        engine_->game.render_texture.setView(engine_->game_view);
      }

      it->second.draw = false;
    }
  }
}

RenderObject* Renderer::GetObject(unsigned int layer, const std::string& id) {
  auto object = objects_[layer].find(id);

  if (object != objects_[layer].end()) {
    return &object->second;
  }

  return nullptr;
}

void Renderer::RemoveUnusedObjects() {
  for (unsigned int i = 0; i < MAX_LAYERS; i++) {
    for (auto it = objects_[i].begin(); it != objects_[i].end();) {
      if (it->second.draw == false) {
        objects_[i].erase(it++);
      } else {
        ++it;
      }
    }
  }
}

