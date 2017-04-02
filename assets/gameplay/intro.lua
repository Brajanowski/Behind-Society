Intro = {}

local timer = 0
local text_to_show = 
[[My name is $and this is my story.

When I was 17 years old I studied at highschool, 

but there was one big problem. No one liked me.

I tried to make new friends, but all my attempts 

were unsuccessful. But one day I said to myself: 

"That's enough", I decided to act. I had enough 

of everyone ignoring me and my genius. I have 

extraordinary IT skills, so I put them to good 

use. I hacked the main school computer and made 

a big mess with everyones data, grades and names. 
 
When I did this I felt like I had unlimited power,
 
I felt I can do anything I ever wanted. I created

an organisation called $

My goal is to launch the biggest hacker attack in

history, but in order to make it happen my plan

needs resources...]]

local current_text = ""
local max_length = 24
local current_cursor_pos = 0
local current_state = 0
local write_animation = true
local skip_step = 0

local user_input = ""
local hacker_name = ""
local group_name = ""

Intro.Start = function()
  timer = 0
  current_cursor_pos = 0
  write_animation = true
  current_state = 0
  current_text = ""
  user_input = ""
  group_name = ""
  Effects.FadeOut(1)
  Effects.SetFX("crt")
end

Intro.Show = function()
  local window_size = Renderer.GetWindowSize()

  if current_state == 0 then
    if string.sub(text_to_show, current_cursor_pos, current_cursor_pos) == "$" then
      current_cursor_pos = current_cursor_pos + 1
      current_state = 1
      user_input = ""
      write_animation = false
      Input.GetLastInput()
    end
  elseif current_state == 1 then
    Gameplay.SetScreenTip("Type your name")
    if Intro.GetUserInput() then
      current_state = 2
      current_text = current_text .. user_input .. " "
      hacker_name = user_input
      user_input = ""
      write_animation = true
      Gameplay.SetScreenTip("")
    end
  elseif current_state == 2 then
    if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) then
      if skip_step == 0 then
        skip_step = 1
      elseif skip_step == 1 then
        local skipping = true
        while skipping do
          current_text = current_text .. string.sub(text_to_show, current_cursor_pos, current_cursor_pos)
          current_cursor_pos = current_cursor_pos + 1
          if string.sub(text_to_show, current_cursor_pos, current_cursor_pos) == "$" then
            skipping = false
          end
        end

        current_cursor_pos = current_cursor_pos + 1
        current_state = 3
        user_input = ""
        write_animation = false
        skip_step = 0
      end
    end

    if skip_step == 1 then
      Gameplay.SetScreenTip("Press space to skip")
    end

    if string.sub(text_to_show, current_cursor_pos, current_cursor_pos) == "$" then
      current_cursor_pos = current_cursor_pos + 1
      current_state = 3
      user_input = ""
      write_animation = false
    end
  elseif current_state == 3 then
    Gameplay.SetScreenTip("Type a group name")
    if Intro.GetUserInput() then
      current_state = 4
      current_text = current_text .. user_input .. " "
      group_name = user_input
      user_input = ""
      write_animation = true
      Gameplay.SetScreenTip("")
    end
  elseif current_state == 4 then
    if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) then
      if skip_step == 0 then
        skip_step = 1
      elseif skip_step == 1 then
        local skipping = true
        while skipping do
          current_text = current_text .. string.sub(text_to_show, current_cursor_pos, current_cursor_pos)
          current_cursor_pos = current_cursor_pos + 1
          if current_cursor_pos > string.len(text_to_show) then
            skipping = false
          end
        end

        current_state = 10
        user_input = ""
        write_animation = false
        skip_step = 0
      end
    end

    if skip_step == 1 then
      Gameplay.SetScreenTip("Press space to skip")
    end
  elseif current_state == 10 then
    Gameplay.SetScreenTip("Press [space] to continue...")
    if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) then
      current_state = 11
    end
  elseif current_state == 11 then 
    Effects.FadeIn(2)
    current_state = 12
  elseif current_state == 12 then
    if Effects.IsFadeDone() then
      current_state = 13
    end
  elseif current_state == 13 then
    Gameplay.NewGame(hacker_name, group_name)
    Gameplay.SetGameState(GameState.Game)
    Effects.DisableFX()
  end

  if write_animation == true then
    if current_cursor_pos > string.len(text_to_show) then
      if timer >= 1.0 and current_state < 10 then
        current_state = 10
      end
    else
      if timer >= 0.1 then
        timer = 0.0
        current_text = current_text .. 
                       string.sub(text_to_show, current_cursor_pos,
                                  current_cursor_pos)
        current_cursor_pos = current_cursor_pos + 1
      end
    end
  end

  if speed_up_animation then
    timer = timer + Time.delta_time * 500.0
  else
    timer = timer + Time.delta_time
  end
  Renderer.Draw(0, "intro_bg",
                "./assets/graphics/intro/background.png", Math.Color(255, 255, 255, 255),
                Math.IntRect(0, 0, 320, 180),
                Math.Vector2f(0, 0),
                Math.Vector2f(1, 1), "default")

  local cursor_pointer = "I"

  if math.sin(Time.time * 5.0) >= 0.0 then
    cursor_pointer = ""
  end

  -- get font size based on res
  local font_size = 17
  if window_size.x >= 1280 then
    font_size = 20
  elseif window_size.x >= 1600 then
    font_size = 24
  end

  Renderer.DrawText(1, "intro_text",
                    current_text .. user_input .. cursor_pointer,
                    "./assets/fonts/PressStart2P.ttf",
                    font_size, Math.Vector2f(32, 32), Math.Color(26, 127, 87, 255))
end

Intro.GetUserInput = function()
  local input = nil

  if Input.IsCharInput() then
    input = Input.GetLastInput()
  end

  if input then
    local ascii = string.byte(input, 1)

    if ascii >= 65 and 
       ascii <= 90  or ascii >= 97 and
       ascii <= 122 or ascii >= 48 and
       ascii <= 57  or ascii == 32 then
      if string.len(user_input) == 0 and ascii == 32 then -- bad design
      elseif string.len(user_input) <= max_length then
        user_input = user_input .. input
      end
    elseif ascii == 8 then
      user_input = string.sub(user_input, 0, string.len(user_input) - 1)
    elseif ascii == 13 then
      if string.len(user_input) > 0 then
        return true
      end
    end
  end

  return false
end

