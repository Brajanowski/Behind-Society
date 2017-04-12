local gameplay_input = true
local display_hud = true
local display_ingame_menu = false
local next_day_anim_step = -1
local next_day_timer = 0
local next_day_strength = 0

local screen_tip = ""
local show_screentip = false

local new_game_status = 0

local lerp = function(a, b, t)
  return a + (b - a) * t
end

Gameplay = {}

GameState = {}
GameState.Splash   = 0
GameState.MainMenu = 1
GameState.Intro    = 2
GameState.Game     = 3
GameState.Gameover = 4
GameState.Win      = 5

local current_game_state = GameState.Splash

Gamemode = {}
Gamemode.Game           = 0
Gamemode.PlaceComputer  = 1
Gamemode.NewGame        = 2

local current_game_mode = 0

local computer_place_right = false
local computer_place_id = -1

-- splash screen data
local splash_timer = 0
local splash_state = 0

-- game over
local gameover_state = 0
local gameover_reason = nil

-- win stuff
local win_state = 0

-- fonts
Gameplay.font  = nil
Gameplay.font_medium = nil
Gameplay.font_large = nil
Gameplay.font_xlarge = nil

Gameplay.Init = function()
  Console.Log("Initializing game")

  -- init
  math.randomseed(os.time()) -- TODO: remove that later(?)
  NameGenerator.Init()
  Companies.Init()

  -- Set up clear color
  Renderer.SetClearColor(Math.Color(0, 0, 0, 255))
  
  -- main menu
  MainMenu.Init()
  
  -- new game
  -- Gameplay.NewGame("Brajanowski", "fsociety")
  --Game.Data.draw_gameplay = true
  --Game.Data.place_computer_mode = false
  Effects.DisableFX()
  --Effects.SetFX("blur_daystats")
  --display_hud = false

  Gameplay.SetGameState(GameState.Splash)

  -- font
  Gui.ClearFonts()
  Gameplay.font  = Gui.LoadFontTTF("./assets/fonts/Roboto-Bold.ttf", 18.0)
  Gameplay.font_medium = Gui.LoadFontTTF("./assets/fonts/Roboto-Bold.ttf", 32.0)
  Gameplay.font_large = Gui.LoadFontTTF("./assets/fonts/Roboto-Bold.ttf", 64.0)
  Gameplay.font_xlarge = Gui.LoadFontTTF("./assets/fonts/Roboto-Bold.ttf", 96.0)
  Gui.GenerateFontTexture()

  AbodeGraphics.Init(0)
end

Gameplay.Update = function()
  Gameplay.DrawScreenTip()

  if current_game_state == GameState.Game then
    AbodeGraphics.Draw(Game.Data.current_abode)
    --AbodeGraphics.Draw(2)

    if current_game_mode == Gamemode.Game then
      Game.Data.place_computer_mode = false

      if Hud.IsAnyWindowOnScreen() == false and #Messages.msg == 0 and Hud.IsNotification() == false and next_day_anim_step == -1 then
        if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) == true then
          Gameplay.NextDay()
        end

        local mpos = Input.GetWorldMousePosition()
        local tile_pos = Math.Vector2f(math.floor(mpos.x / 16), math.floor(mpos.y / 16))
        local pc_id = Game.Data.GetComputerId(Game.Data.current_abode, tile_pos.x, tile_pos.y)

        if pc_id >= 0 then
          Gameplay.SetScreenTip("Press [Mouse left button] to show computer info")
          if Input.Mouse.GetMouseButtonDown(Keycode.Mouse.Left) then
            Hud.ShowComputerInfo(pc_id)
          end
        end
      end
    elseif current_game_mode == Gamemode.PlaceComputer then
      Game.Data.place_computer_mode = true
      Gameplay.PlaceComputerMode()
    elseif current_game_mode == Gamemode.Intro then
      Intro.Show()
    elseif current_game_mode == Gamemode.NewGame then
      Gameplay.NewGameUpdate()
    end

    -- Hud
    if display_hud then
      Hud.Show()
    end

    -- In game menu
    if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Escape) then
      display_ingame_menu = not display_ingame_menu
      InGameMenu.SetTab("Main")
    end

    if display_ingame_menu then
      InGameMenu.Show()
    end

    -- Next day animation
    if next_day_anim_step == 0 then
      next_day_timer = 0.0
      display_hud = false
      Effects.SetFX("blur_daystats")
      next_day_anim_step = 1
    elseif next_day_anim_step > 0 then
      if next_day_anim_step == 1 then
        next_day_timer = next_day_timer + Time.delta_time * 8
      
        if next_day_timer >= 1.0 then
          next_day_anim_step = 2
          next_day_timer = 0.0
        end

        next_day_strength = next_day_strength + Time.delta_time * 8
        if next_day_strength > 1.0 then
          next_day_strength = 1.0
        end
      elseif next_day_anim_step == 10 then
        next_day_timer = next_day_timer + Time.delta_time * 8
      
        if next_day_timer >= 1.0 then
          next_day_timer = 0.0
          next_day_anim_step = -1
          display_hud = true
          Effects.DisableFX()
        end

        next_day_strength = next_day_strength - Time.delta_time * 8
        if next_day_strength < 0.0 then
          next_day_strength = 0.0
        end

        DayLog.Reset()
      end

      Effects.SetFloat("strength", next_day_strength)

      local window_size = Renderer.GetWindowSize()

      Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 0.0)

      Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, math.floor(200 * next_day_strength)))
      Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))

      Gui.SetNextWindowSize(window_size.x, window_size.y)
      Gui.SetNextWindowPos(0, 0)
      Gui.BeginFlags("NextDayBackground", GuiStyle.WindowFlags.NoTitleBar .. 
                                     GuiStyle.WindowFlags.NoResize ..
                                     GuiStyle.WindowFlags.NoMove ..
                                     GuiStyle.WindowFlags.NoCollapse ..
                                     GuiStyle.WindowFlags.NoScrollbar ..
                                     GuiStyle.WindowFlags.ShowBorders ..
                                     GuiStyle.WindowFlags.NoSavedSettings)

        Gui.PushFont(Gameplay.font_xlarge)
        if next_day_anim_step == 2 then
          next_day_timer = next_day_timer + Time.delta_time * 3

          local timer = next_day_timer
          if next_day_timer >= 1.0 then
            next_day_anim_step = 3
            next_day_timer = 0.0
            timer = 1.0
          end

          local text_to_show = "DAY    " .. Game.Data.day
          local text_size = Gui.CalcTextSize(text_to_show)

          Gui.SetCursorPosX(math.floor(lerp(window_size.x, window_size.x / 2.0 - text_size.x / 2.0, timer)))
          Gui.SetCursorPosY(math.floor(window_size.y / 2.0 - text_size.y / 2.0))
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. text_to_show)
        elseif next_day_anim_step == 3 then
          next_day_timer = next_day_timer + Time.delta_time

          if next_day_timer >= 0.6 or Input.Mouse.GetMouseButtonDown(Keycode.Mouse.Left) or Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) == true then
            next_day_anim_step = 4
            next_day_timer = 0.0
          end

          local text_to_show = "DAY    " .. Game.Data.day
          local text_size = Gui.CalcTextSize(text_to_show)

          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 - text_size.x / 2.0))
          Gui.SetCursorPosY(math.floor(window_size.y / 2.0 - text_size.y / 2.0))
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. text_to_show)
       elseif next_day_anim_step == 4 then
          next_day_timer = next_day_timer + Time.delta_time * 3
          
          local timer = next_day_timer
          if next_day_timer >= 1.0 or Input.Mouse.GetMouseButtonDown(Keycode.Mouse.Left) or Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) == true then
            next_day_anim_step = 5
            next_day_timer = 0.0
            timer = 1.0
          end

          local text_to_show = "DAY    " .. Game.Data.day
          local text_size = Gui.CalcTextSize(text_to_show)

          Gui.SetCursorPosX(math.floor(lerp(window_size.x / 2.0 - text_size.x / 2.0, -text_size.x, timer)))
          Gui.SetCursorPosY(math.floor(window_size.y / 2.0 - text_size.y / 2.0))
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. text_to_show)

          text_to_show = "DAILY REPORT"
          text_size = Gui.CalcTextSize(text_to_show)

          Gui.SetCursorPosX(math.floor(lerp(window_size.x, window_size.x / 2.0 - text_size.x / 2.0, timer)))
          Gui.SetCursorPosY(math.floor(window_size.y / 2.0 - text_size.y / 2.0))
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. text_to_show)
        elseif next_day_anim_step == 5 then
          next_day_timer = next_day_timer + Time.delta_time * 3
          
          local timer = next_day_timer
          if next_day_timer >= 1.0 then
            next_day_anim_step = 6
            next_day_timer = 0.0
            timer = 1.0
          end

          local text_to_show = "DAILY REPORT"
          local text_size = Gui.CalcTextSize(text_to_show)

          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 - text_size.x / 2.0))
          Gui.SetCursorPosY(math.floor(lerp(window_size.y / 2.0 - text_size.y / 2.0, window_size.y / 2.0 - text_size.y / 2.0 - 250, timer)))
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. text_to_show)
        elseif next_day_anim_step == 6 then
          if Input.Mouse.GetMouseButtonDown(Keycode.Mouse.Left) or Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) == true then
            next_day_anim_step = 10
          end

          local text_to_show = "DAILY REPORT"
          local text_size = Gui.CalcTextSize(text_to_show)

          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 - text_size.x / 2.0))
          Gui.SetCursorPosY(math.floor(window_size.y / 2.0 - text_size.y / 2.0 - 250))
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. text_to_show)

          Gui.PushFont(Gameplay.font_medium)

          -- money
          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 - text_size.x / 2.0))
          Gui.SetCursorPosY(math.floor(window_size.y / 2.0 - text_size.y / 2.0))

          local old_y = Gui.GetCursorPosY()
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "Money")

          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 + text_size.x / 2.0))
          Gui.SetCursorPosY(old_y)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. DayLog.money)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 24)

          -- fans
          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 - text_size.x / 2.0))
          old_y = Gui.GetCursorPosY()
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "Fans")

          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 + text_size.x / 2.0))
          Gui.SetCursorPosY(old_y)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. DayLog.fans)
          Gui.SetCursorPosY(Gui.GetCursorPosY() + 24)

          -- security points
          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 - text_size.x / 2.0))
          old_y = Gui.GetCursorPosY()
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "Security points")

          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 + text_size.x / 2.0))
          Gui.SetCursorPosY(old_y)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. DayLog.security_points)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 24)
          
          -- points
          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 - text_size.x / 2.0))
          old_y = Gui.GetCursorPosY()
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "Points generated")

          Gui.SetCursorPosX(math.floor(window_size.x / 2.0 + text_size.x / 2.0))
          Gui.SetCursorPosY(old_y)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. DayLog.points)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 24)

          Gui.PopFont()

          Gui.PushFont(Gameplay.font)
          Gui.SetCursorPosY(window_size.y - 120)
          Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.White) .. "Press LMB to continue...", "h")
          Gui.PopFont()
        end
        Gui.PopFont()
      Gui.End()

      Gui.PopStyleColor(2)
      Gui.PopStyleVar(1)
    end
  elseif current_game_state == GameState.MainMenu then
    MainMenu.Show()
  elseif current_game_state == GameState.Intro then
    Intro.Show()
  elseif current_game_state == GameState.Splash then
    Renderer.Draw(0, "splash",
              "./assets/graphics/splash/splash_screen_author.png", Math.Color(255, 255, 255, 255),
              Math.IntRect(0, 0, 320, 180),
              Math.Vector2f(0, 0),
              Math.Vector2f(1, 1), "default")

    if splash_state == 0 then
      Effects.FadeOut(2)
      splash_state = 1
    elseif splash_state == 1 then
      if Effects.IsFadeDone() then
        splash_timer = splash_timer + Time.delta_time

        if splash_timer > 1.5 then
          splash_state = 2
        end
      end
    elseif splash_state == 2 then
      Effects.FadeIn(1.5)
      splash_state = 3
    elseif splash_state == 3 then
      if Effects.IsFadeDone() then
        Effects.FadeOut(1)
        splash_state = 4
        Gameplay.SetGameState(GameState.MainMenu)
      end
    end
  elseif current_game_state == GameState.Gameover then
    if gameover_state ~= 0 then
      Renderer.Draw(0, "gameover",
                    "./assets/graphics/splash/splash_screen_gameover.png", Math.Color(255, 255, 255, 255),
                    Math.IntRect(0, 0, 320, 180),
                    Math.Vector2f(0, 0),
                    Math.Vector2f(1, 1), "default")
    end

    if gameover_state == 0 then
      if Effects.IsFadeDone() then
        gameover_state = 1
        Effects.FadeOut(0.5)
      end
    elseif gameover_state == 1 then
      if Effects.IsFadeDone() then
        gameover_state = 2
      end
    elseif gameover_state == 2 then
      if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) then
        gameover_state = 3
        Effects.FadeIn(1.0)
      end

      local window_size = Renderer.GetWindowSize()

      Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 64))
      Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))

      Gui.SetNextWindowSize(window_size.x, 320)
      Gui.SetNextWindowPos(0, window_size.y / 2 + 180)
      Gui.BeginFlags("gameover statistics",  GuiStyle.WindowFlags.NoTitleBar .. 
                                             GuiStyle.WindowFlags.NoResize ..
                                             GuiStyle.WindowFlags.NoMove ..
                                             GuiStyle.WindowFlags.NoCollapse ..
                                             GuiStyle.WindowFlags.NoScrollbar ..
                                             GuiStyle.WindowFlags.ShowBorders ..
                                             GuiStyle.WindowFlags.NoSavedSettings)

        if gameover_reason ~= nil then
          Gui.TextExpandedCentered(gameover_reason, "h")
          Gui.SetCursorPosY(72)
        end

        Gui.TextExpandedCentered("Press (space) to continue", "h")

      Gui.End()
      
      Gui.PopStyleColor(2)
    elseif gameover_state == 3 then
      if Effects.IsFadeDone() then
        Gameplay.SetGameState(GameState.MainMenu)
      end
    end
  elseif current_game_state == GameState.Win then
    if win_state ~= 0 then
      Renderer.Draw(0, "win",
                    "./assets/graphics/splash/splash_screen_won.png", Math.Color(255, 255, 255, 255),
                    Math.IntRect(0, 0, 320, 180),
                    Math.Vector2f(0, 0),
                    Math.Vector2f(1, 1), "default")
    end

    if win_state == 0 then
      if Effects.IsFadeDone() then
        win_state = 1
        Effects.FadeOut(0.5)
      end
    elseif win_state == 1 then
      if Effects.IsFadeDone() then
        win_state = 2
      end
    elseif win_state == 2 then
      if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Space) then
        win_state = 3
        Effects.FadeIn(1.0)
      end

      local window_size = Renderer.GetWindowSize()

      Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 64))
      Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))

      Gui.SetNextWindowSize(window_size.x, 320)
      Gui.SetNextWindowPos(0, window_size.y / 2 + 180)
      Gui.BeginFlags("win game statistics",  GuiStyle.WindowFlags.NoTitleBar .. 
                                             GuiStyle.WindowFlags.NoResize ..
                                             GuiStyle.WindowFlags.NoMove ..
                                             GuiStyle.WindowFlags.NoCollapse ..
                                             GuiStyle.WindowFlags.NoScrollbar ..
                                             GuiStyle.WindowFlags.ShowBorders ..
                                             GuiStyle.WindowFlags.NoSavedSettings)

        Gui.TextExpandedCentered("{255, 255, 255, " .. (math.sin(Time.time) * 128 + 128) .. "}Press (space) to continue", "h")

      Gui.End()
      
      Gui.PopStyleColor(2)
    elseif win_state == 3 then
      if Effects.IsFadeDone() then
        Gameplay.SetGameState(GameState.MainMenu)
      end
    end
  end
  
  -- i really dont know why i have to use that
  collectgarbage()
end

Gameplay.HideInGameMenu = function()
  display_ingame_menu = false
  display_hud = true
end

Gameplay.SetGameState = function(state)
  current_game_state = state

  if state == GameState.Game then
    Game.Data.draw_gameplay = true
    Effects.FadeOut(0.7)
    Audio.PlayMusic("./assets/music/Too cool.ogg")
    Effects.DisableFX()
  elseif state == GameState.MainMenu then
    Effects.FadeOut(0.7)
    --AbodeGraphics.HomeInit()
    Game.Data.draw_gameplay = false
    Audio.PlayMusic("./assets/music/Voltaic.ogg")
    Effects.SetFX("blur_daystats")
    Effects.SetFloat("strength", 1.0)
  elseif state == GameState.Intro then
    Game.Data.draw_gameplay = false
    Audio.PlayMusic("./assets/music/Plaint.ogg")
  else
    Game.Data.draw_gameplay = false
  end
end

Gameplay.WinGame = function()
  Gameplay.SetGameState(GameState.Win)
  Effects.FadeIn(0.5)
  win_state = 0
end

Gameplay.Gameover = function(reason)
  Gameplay.SetGameState(GameState.Gameover)
  Effects.FadeIn(0.5)
  gameover_state = 0
  gameover_reason = reason
end

Gameplay.SetAbode = function(id)
  Game.Data.ClearAbodes()
  Game.Data.PushAbode(AbodeGenerator.Generate(id))
  AbodeGraphics.Init(id)
end

Gameplay.NewGame = function(name, group_name)
  Effects.FadeOut(1.0)
  
  Game.Data.Clear()

  local hacker = Game.Hacker(name)
  hacker.age = 17
  hacker.cracking = 1
  hacker.security = 1
  hacker.level = 1
  hacker.science_points = 0
  Game.Data.PushHacker(hacker)
  
  Game.Data.PushComputer(Game.Computer())
  Gameplay.SetAbode(0)
  Game.Data.rent = 5
  Game.Data.rent_paid = true

  Game.Data.group_name = group_name;
  Game.Data.day = 1
  Game.Data.money = math.random(2, 5)
  Game.Data.fans = 1
  Game.Data.current_abode = 0
  Game.Data.red_company_generation = 1
  Game.Data.blue_company_generation = 1
  Game.Data.red_company_tech_points = 0
  Game.Data.blue_company_tech_points = 0
  Game.Data.security = 0
  Game.Data.seed = os.time()
  Game.Data.logo = 1

  current_game_mode = Gamemode.NewGame
  Effects.DisableFX()
  new_game_status = 0

  Hud.AddNotification("Tutorial", Tutorial.prepare, "OK")
  Hud.AddNotification("Welcome", Tutorial.hello, "OK")
  
  Messages.Add(
      "matthias", 
      "Matthias", 
      "Yo bro", 
      GameEvents.matthias,
      {
        yes = {
          msg = "No problem.",
          func = function()
            local task = Game.Task()
            task.type = 2
            task.name = "Removing a toolbars"
            task.points = 0
            task.points_to_finish = 1
            task.reward = 2
            task.days_to_finish = 1
            Game.Data.PushTask(task)
          end
        },
        no = nil
      }         
  )

  ComputerStore.Generate()
  DayLog.Reset()
  Companies.GenerateStarting()
end

Gameplay.LoadGame = function(slot)
  Console.Log("Loading game from slot: " .. slot)
  Game.Data.Load(slot)

  Gameplay.SetAbode(Game.Data.current_abode)
  
  Messages.Clear()
  Hud.ClearNotifications()
  ComputerStore.Generate()
  DayLog.Reset()

  new_game_status = 3
  Gameplay.SetGameState(GameState.Game)

  Effects.DisableFX()
end

Gameplay.NextDay = function()
  Game.Data.day = Game.Data.day + 1
  display_hud = false
  next_day_anim_step = 0
 
  -- save previous stats for logs
  DayLog.money = Game.Data.money
  DayLog.fans = Game.Data.fans

  Messages.Clear()
  GameEvents.Update()
  Tasks.Update()
  ComputerStore.NextDay()
  Companies.NextDay()

  local money_from_fans = 0
  for i = 0, Game.Data.fans - 1 do
    if math.random(0, 100) <= 75 then
      money_from_fans = money_from_fans + math.random(0, 2)
    end
  end

  Game.Data.money = Game.Data.money + money_from_fans
  if money_from_fans > 0 then
    Console.Log("You got $" .. money_from_fans .. " donates from your fans!")
  end

  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)

    if hacker.days_to_quit > 0 then
      hacker.days_to_quit = hacker.days_to_quit - 1

      if hacker.days_to_quit > 0 then
        Messages.Add(hacker.skin_id, hacker.name, "Where is my salary?",
                     "You have " .. hacker.days_to_quit .. 
                     " days to pay my salary. Or I left and we never meet again")
      end
    end
  end

  local names_quit = {}

  local done = false
  while done == false do
    local was_break = false
    for i = 0, Game.Data.GetHackersNumber() - 1 do
      local hacker = Game.Data.GetHacker(i)
      
      if hacker.days_to_quit == 0 then
        names_quit[#names_quit + 1] = hacker.name
        Messages.Add(-1, hacker.name, "Cya",
                     "I told ya. I gave for you a few days but you did nothing.")
        Game.Data.RemoveHacker(i)
        was_break = true
        break
      end
    end

    if was_break == false then
      done = true
    end
  end

  -- notification about hackers who quits your group
  if #names_quit > 0 then
    local message = "This is guys left your group today: \n\n"

    for i = 1, #names_quit do
      message = message .. "  - " .. names_quit[i] .. "\n\n"
    end

    Hud.AddNotification("List", message, "I got it")
  end

  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)
    if Game.Data.day % 7 == 0 then
      if hacker.salary > 0 then
        hacker.days_to_quit = math.random(2, 4)
      end
    end
  end

  -- set up daily logs
  DayLog.money = Game.Data.money - DayLog.money
  DayLog.fans = Game.Data.fans - DayLog.fans
  DayLog.security_points = Game.Data.security - DayLog.security_points

  -- rent
  if (Game.Data.day - 1) % 7 == 0 then
    if Game.Data.rent_paid == false then
      if Game.Data.money >= Game.Data.rent * 2 then
        Game.Data.money = Game.Data.money - (Game.Data.rent * 2)
      else
        Gameplay.Gameover("You were kicked out.")
      end
    elseif Game.Data.money >= Game.Data.rent then
      Game.Data.money = Game.Data.money - Game.Data.rent
      Game.Data.rent_paid = true
    else
      Messages.Add(-1, "Landlord", "Rent", "Now listen here, if you don't pay double for your rent in a week, you're going to get kicked out.", nil)
      Game.Data.rent_paid = false
    end
  end
end

Gameplay.GetExperienceToNextLevel = function(current_level)
  return current_level * 10
end

Gameplay.HackerLevelUp = function(hackerid)
  local hacker = Game.Data.GetHacker(hackerid)
  
  if hacker.experience >= Gameplay.GetExperienceToNextLevel(hacker.level) then
    hacker.level = hacker.level + 1
    hacker.experience = 0
    hacker.science_points = hacker.science_points + 1
  end
end

Gameplay.GetNumOfReadyHackersToWork = function()
  local num = 0
  
  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)
    
    if hacker.task == -1 and hacker.computer >= 0 then
      num = num + 1
    end
  end

  return num
end

Gameplay.BuyComputer = function(cost, computer)
  if Game.Data.money < cost then
    Console.Log("You do not have enough money for this purchase. You need " .. 
                cost .. "$")
  else
    current_game_mode = Gamemode.PlaceComputer
    Game.Data.money = Game.Data.money - cost
    computer_place_id = Game.Data.PushComputer(computer)
  end
end

Gameplay.SellComputer = function(computerid)
  if computerid >= 0 then
    for i = 0, Game.Data.GetHackersNumber() - 1 do
      local hacker = Game.Data.GetHacker(i)

      if hacker.computer == computerid then
        hacker.computer = -1
      elseif hacker.computer > computerid then
        hacker.computer = hacker.computer - 1
      end
    end
  end

  Game.Data.money = Game.Data.money + math.floor(Gameplay.GetComputerCost(Game.Data.GetComputer(computerid)) / 2)
  Game.Data.RemoveComputer(computerid)
end

Gameplay.TurnOnPlaceComputerMode = function(computer_id)
  computer_place_id = computer_id
  current_game_mode = Gamemode.PlaceComputer

  if Hud.IsTrayVisible() then
    Hud.HideTray()
  end
end

Gameplay.CanComputerBePlacedThere = function(x, y, right)
  local tile = Game.Data.GetAbode(0):GetTile(x, y)

  local second_tile_pos_x = x - 1

  if right then
    second_tile_pos_x = x + 1
  end

  local second_tile = Game.Data.GetAbode(0):GetTile(second_tile_pos_x, y)

  if tile.type == TileType.Floor and second_tile.type == TileType.Floor and
     Game.Data.IsComputerHere(Game.Data.current_abode, x, y) == false and
     Game.Data.IsComputerHere(Game.Data.current_abode, second_tile_pos_x, y) == false then
     return true
   end

   return false
end

Gameplay.PlaceComputer = function(x, y, right)
  local tile = Game.Data.GetAbode(0):GetTile(x, y)

  local second_tile_pos_x = x - 1

  if right then
    second_tile_pos_x = x + 1
  end

  local second_tile = Game.Data.GetAbode(0):GetTile(second_tile_pos_x, y)

  if tile.type == TileType.Floor and second_tile.type == TileType.Floor and
     Game.Data.IsComputerHere(x, y) == false and
     Game.Data.IsComputerHere(second_tile_pos_x, y) == false then
    local computer = Game.Data.GetComputer(computer_place_id)
    computer.abode_id = Game.Data.current_abode
    computer.x = x
    computer.y = y
    computer.right = right
    Console.Log("Placed computer at: " .. x .. ", " .. y .. ", tile " .. tile.type)

    -- tutorial stuff
    if Game.Data.GetQuestVariable("tutorial_place_computer") == -1 then
      Hud.AddNotification("Welcome", Tutorial.place_hacker, "OK")
      Game.Data.SetQuestVariable("tutorial_place_computer", 1)
    end

    return true
  else
    Console.Log("You cannot place computer here!")
    return false
  end
end

Gameplay.PlaceComputerMode = function()
  if computer_place_id < 0 then
    current_game_mode = 0
    Console.Log("Place computer mode: wrong computer id")
    Game.Data.place_computer_mode = false
  else
    Game.Data.place_computer_mode = true
    Gameplay.SetScreenTip("Place a computer on the green area.")

    local mpos = Input.GetWorldMousePosition()
    local tile_pos = Math.Vector2f(math.floor(mpos.x / 16), 
                                   math.floor(mpos.y / 16))
    local computer_pos = Math.Vector2f(tile_pos.x * 16 - 16, 
                                       tile_pos.y * 16 - 16)

    if computer_place_right then
      computer_pos.x = tile_pos.x * 16 + 32
    end

    local scale = Math.Vector2f(1, 1)

    if computer_place_right then
      scale.x = -1
    end

    local computer_color = Math.Color(255, 255, 255, 128)

    if Gameplay.CanComputerBePlacedThere(tile_pos.x, tile_pos.y, computer_place_right) == false then
      computer_color = Math.Color(255, 128, 128, 128)
    end

    Renderer.Draw(4, "place computer",
                  Gameplay.GetTexturePathOfComputer(computer_place_id), computer_color,
                  Math.IntRect(0, 0, 32, 32),
                  computer_pos,
                  scale,
                  "default")

    if Input.Mouse.GetMouseButtonDown(Keycode.Mouse.Left) then
      if Gameplay.PlaceComputer(tile_pos.x, tile_pos.y, 
                                computer_place_right) then
        current_game_mode = 0
      end
    end

    if Input.Mouse.GetMouseButtonDown(Keycode.Mouse.Right) then
      current_game_mode = 0
    end

    if Input.Keyboard.GetKeyDown(Keycode.Keyboard.F) then
      computer_place_right = not computer_place_right
    end
  end
end

Gameplay.GetUpgradeCost = function(computer)
  return computer.generation * 10 + computer.upgrade_level * 5
end

Gameplay.GetComputerCost = function(computer)
  return Gameplay.GetGenerationCost(computer.generation)
end

Gameplay.GetGenerationCost = function(generation)
  return generation * 50
end

Gameplay.UpgradeComputer = function(computer)
  if computer.upgrade_level >= 3 then
    Console.Log("This computer is at maximum upgrade level.")
    return
  end

  if Game.Data.money < Gameplay.GetUpgradeCost(computer) then
    Console.Log("You have not enough money for upgrade!")
    return
  end

  Game.Data.money = Game.Data.money - Gameplay.GetUpgradeCost(computer)
  computer.upgrade_level = computer.upgrade_level + 1
end

Gameplay.GetTexturePathOfComputerByData = function(company_num, generation)
  local company = ""

  if company_num == 0 then
    company = "red"
  else
    company = "blue"
  end

  return "./assets/graphics/computers/computer_" .. company .. "_" .. generation .. ".png"
end

Gameplay.GetTexturePathOfComputer = function(computerid)
  local computer = Game.Data.GetComputer(computerid)

  return Gameplay.GetTexturePathOfComputerByData(computer.company, 
                                                 computer.generation)
end

Gameplay.GetTexturePathOfHacker = function(hackerid)
  local hacker = Game.Data.GetHacker(hackerid)
  
  if hackerid == 0 then
    return "./assets/graphics/people/player_" .. hacker.skin_id ..  ".png"
  end

  return "./assets/graphics/people/" .. hacker.skin_id .. ".png"
end

Gameplay.GetComputingPower = function(computer)
  return computer.generation * 10 + computer.upgrade_level * 4
end

Gameplay.PlaceHackerAtComputer = function(hackerid, computerid)
  if Game.Data.GetHackerOnComputer(computerid) == -1 then
    local hacker = Game.Data.GetHacker(hackerid)
    hacker.computer = computerid
  else
    Console.Log("This computer is already in use.")
  end
end

Gameplay.RemoveHackerFromComputer = function(computerid) 
  local hackerid = Game.Data.GetHackerOnComputer(computerid)
  
  if hackerid >= 0 then
    local hacker = Game.Data.GetHacker(hackerid)
    hacker.computer = -1
  end
end

Gameplay.HackCompany = function(companyid)
  if Gameplay.IsCompanyInTask(companyid) then
    return
  end
  
  local task = Game.Task()
  local company = Game.Data.GetCompany(companyid)

  task.name = "Hacking " .. company.name
  task.company_id = companyid
  task.points = 0
  task.points_to_finish = company.security
  task.type = 0

  Game.Data.PushTask(task)
end

Gameplay.IsCompanyInTask = function(companyid)
  for i = 0, Game.Data.GetTaskNumber() - 1 do
    local task = Game.Data.GetTask(i)
    if task.company_id == companyid then
      return true
    end
  end

  return false
end

Gameplay.UnassignHackersFromTask = function(taskid)
  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)

    if hacker.task == taskid then
      hacker.task = -1
    end
  end
end

Gameplay.GetNumOfPeopleAssignedToTask = function(taskid)
  local num = 0

  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)

    if hacker.task == taskid then
      num = num + 1
    end
  end

  return num
end

Gameplay.TaskRemoved = function(taskid)
  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)

    if hacker.task == taskid then
      hacker.task = -1
    elseif hacker.task > taskid then
      hacker.task = hacker.task - 1
    end
  end
end

Gameplay.CompanyRemoved = function(companyid)
  for i = 0, Game.Data.GetTaskNumber() - 1 do
    local task = Game.Data.GetTask(i)

    if task.company_id > companyid then
      task.company_id = task.company_id - 1
    end
  end
end

Gameplay.PushFrontCompany = function(company)
  Game.Data.PushFrontCompany(company)

  for i = 0, Game.Data.GetTaskNumber() - 1 do
    local task = Game.Data.GetTask(i)
    if task.company_id >= 0 then
      task.company_id = task.company_id + 1
    end
  end
end

Gameplay.SetPauseMenu = function(active)
  display_ingame_menu = active
end

Gameplay.PaySalary = function(hackerid)
  local hacker = Game.Data.GetHacker(hackerid)

  if Game.Data.money < hacker.salary then
    return false
  end

  if hacker.days_to_quit == -1 then
    return false
  end

  hacker.days_to_quit = -1
  Game.Data.money = Game.Data.money - hacker.salary

  return true
end

Gameplay.PayToAll = function()
  local money_to_pay = Gameplay.GetTotalMoneyToPay()

  if Game.Data.money < money_to_pay then
    return false
  end

  Game.Data.money = Game.Data.money - money_to_pay

  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)
    hacker.days_to_quit = -1
  end

  return true
end

Gameplay.IsAnyoneToPay = function()
  for i = 0, Game.Data.GetHackersNumber() - 1 do  
    if Game.Data.GetHacker(i).days_to_quit ~= -1 then
      return true
    end
  end
  return false
end

Gameplay.GetTotalMoneyToPay = function()
  local money = 0
  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)
    if hacker.days_to_quit ~= -1 then
      money = money + hacker.salary
    end
  end
  return money
end

Gameplay.GenerateHacker = function(base_level, max_above_level, max_under_level)
  local hacker = Game.Hacker(NameGenerator.GenerateMale())
  hacker.level = math.random(math.max(1, base_level - max_under_level), base_level + max_above_level)

  -- points
  local points = hacker.level - 1
  while points > 0 do
    if math.random(100) > 50 then
      hacker.security = hacker.security + 1
    else
      hacker.cracking = hacker.cracking + 1
    end

    points = points - 1
  end

  -- 20% chance for hacker being cop
  if math.random(100) >= 80 then
    hacker.is_cop = true
  else
    hacker.is_cop = false
  end

  hacker.age = math.random(18, 45)
  hacker.skin_id = math.random(0, 9)
  hacker.personality = Personality.Crazy

  hacker.salary = hacker.level * 10 - math.random(-5, 5)

  return hacker
end

Gameplay.UpgradeAbode = function()
  Game.Data.money = Game.Data.money - Gameplay.GetAbodeCost(Game.Data.current_abode + 1)
  Game.Data.rent = Gameplay.GetAbodeRent(Game.Data.current_abode + 1)
  
  Game.Data.current_abode = Game.Data.current_abode + 1
  Gameplay.SetAbode(Game.Data.current_abode)

  for i = 0, Game.Data.GetComputersNumber() - 1 do
    local computer = Game.Data.GetComputer(i)
    computer.abode_id = -1
  end

  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)
    hacker.computer = -1
    hacker.task = -1
  end
end

Gameplay.GetMaxComputerPlaces = function(abode_level)
  if abode_level == 0 then
    return 1
  elseif abode_level == 1 then
    return 2
  elseif abode_level == 2 then
    return 4
  elseif abode_level == 3 then
    return 8
  end

  return -1
end

Gameplay.GetAbodeRent = function(abode_level)
  if abode_level == 1 then
    return 30
  elseif abode_level == 2 then
    return 123
  elseif abode_level == 3 then
    return 666
  end

  return -1
end

Gameplay.GetAbodeCost = function(abode_level)
  if abode_level == 1 then
    return 250 
  elseif abode_level == 2 then
    return 1337
  elseif abode_level == 3 then
    return 2137
  end

  return -1
end

Gameplay.SetScreenTip = function(tip)
  show_screentip = true
  screen_tip = tip
end

Gameplay.DrawScreenTip = function()
  if show_screentip == false then
    return
  end

  local window_size = Renderer.GetWindowSize()

  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(0, 0))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(0, 0))

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 0))

  Gui.SetNextWindowSize(300, 24)
  Gui.SetNextWindowPos(window_size.x - 300 - 24 - 32,
                       window_size.y - 24 - 32)
  
  Gui.BeginFlags("ScreenTip", GuiStyle.WindowFlags.NoTitleBar .. 
                              GuiStyle.WindowFlags.NoResize ..
                              GuiStyle.WindowFlags.NoMove ..
                              GuiStyle.WindowFlags.NoCollapse ..
                              GuiStyle.WindowFlags.NoScrollbar ..
                              GuiStyle.WindowFlags.NoInputs ..
                              GuiStyle.WindowFlags.NoSavedSettings)
    Gui.TextExpanded(screen_tip)
  Gui.End()

  Gui.PopStyleColor(1)
  Gui.PopStyleVar(2)

  show_screentip = false
end

-- new game
Gameplay.NewGameUpdate = function()
  display_hud = false

  local window_size = Renderer.GetWindowSize()

  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 0)

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, HudPalette.Black)
  Gui.PushStyleColor(GuiStyle.Colors.TitleBg, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.TitleBgActive, HudPalette.Blue)
  
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarBg, HudPalette.DarkBlue)
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrab, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabHovered, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabActive, HudPalette.Blue)

  Gui.PushStyleColor(GuiStyle.Colors.Button, HudPalette.DarkBlue)
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, HudPalette.Blue)

  Gui.SetNextWindowSize(800, 500)
  Gui.SetNextWindowPos((window_size.x / 2.0 - 800 / 2.0), (window_size.y / 2.0 - 500 / 2.0))
  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.5, 0.5))

  Gui.BeginFlags("New game", --GuiStyle.WindowFlags.NoTitleBar .. 
                             GuiStyle.WindowFlags.NoResize ..
                             GuiStyle.WindowFlags.NoMove ..
                             GuiStyle.WindowFlags.NoCollapse ..
                             GuiStyle.WindowFlags.NoScrollbar ..
                             --GuiStyle.WindowFlags.ShowBorders .. 
                             GuiStyle.WindowFlags.NoSavedSettings)

    --[[Gui.PushFont(Gameplay.font16)
    Gui.TextExpandedCentered("Group", "h")
    Gui.PopFont()--]]

    Gui.SetCursorPosY(32)
    --Gui.Separator()
    --Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

    if new_game_status == 0 then
      Gameplay.NewGameGroup()
    elseif new_game_status == 1 then
      Gameplay.NewGamePlayerSkin()
    elseif new_game_status == 2 then
      current_game_mode = Gamemode.Game
      display_hud = true
      Effects.DisableFX()
    end

  Gui.End()

  Gui.PopStyleColor(10)
  Gui.PopStyleVar(1)
end

Gameplay.NewGameGroup = function()
  Gui.TextExpandedCentered("Choose your logo", "h")
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 32)

  for i = 0, GameConfig.LOGOS_NUMBER - 1 do
    if i > 0 then
      if i % 4 ~= 0 then
        Gui.SameLine(0, 50)
      else
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 64)
      end
    end

    if Gui.ImageButton("./assets/graphics/logos/" .. i .. ".png", Math.Vector2f(150, 150)) then
      Game.Data.logo = i
      new_game_status = 1
    end
  end
end

local anim_handler_skin_preview = Renderer.AnimationHandler()
anim_handler_skin_preview:SetFrameSize(Math.IntRect(0, 0, 16, 32))
anim_handler_skin_preview:AddAnimation(Renderer.Animation(0, 3, 1.0))
anim_handler_skin_preview:Play(0)

Gameplay.NewGamePlayerSkin = function()
  anim_handler_skin_preview:Update(Time.delta_time)
  
  Gui.PushStyleColor(GuiStyle.Colors.Button, Math.Color(0, 0, 0, 0))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, Math.Color(24, 24, 24, 32))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, Math.Color(48, 48, 48, 32))

  Gui.TextExpandedCentered("Choose your skin", "h")
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 32)

  Gui.SetCursorPosX(432 / 2.0)
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 100)
  for i = 0, GameConfig.PLAYER_SKINS - 1 do
    if i > 0 then
      Gui.SameLine(0, 64)
    end

    local cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.PushID("choose" .. i)
    if Gui.Button("", Math.Vector2f(80, 160)) then
      new_game_status = 2
      Game.Data.GetHacker(0).skin_id = i
    end
    Gui.PopID()

    local temp_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.SetCursorPosX(cursor_pos.x)
    Gui.SetCursorPosY(cursor_pos.y)

    Gui.Image("./assets/graphics/people/player_" .. i .. ".png", 
          Math.Vector2f(80, 160), anim_handler_skin_preview:GetBoundsFloat())

    Gui.SetCursorPosX(temp_pos.x)
    Gui.SetCursorPosY(temp_pos.y)
  end

  Gui.PopStyleColor(3)
end
