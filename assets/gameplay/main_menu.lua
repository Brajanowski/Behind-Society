MainMenu = {}

local credits_timer = 0.0
local current_tab = "Main"
local new_game_tab = "Name"
local temp_volume = 0.0
local abode_in_background = 0
local current_res = 1

local preview_slot = -1

local credits = {}

MainMenu.Init = function()
  for line in io.lines("./assets/credits.txt") do
    credits[#credits + 1] = line
  end
end

MainMenu.Show = function()
  local window_size = Renderer.GetWindowSize()

  if current_tab ~= "Credits" then
    AbodeGraphics.Home()

    local window_size = Renderer.GetWindowSize()

    Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 192))
    Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))
    Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 0)

    Gui.SetNextWindowSize(window_size.x, window_size.y)
    Gui.SetNextWindowPos(0, 0)
    Gui.BeginFlags("DarkTransparentBG", GuiStyle.WindowFlags.NoTitleBar .. 
                                        GuiStyle.WindowFlags.NoResize ..
                                        GuiStyle.WindowFlags.NoMove ..
                                        GuiStyle.WindowFlags.NoCollapse ..
                                        GuiStyle.WindowFlags.NoScrollbar ..
                                        GuiStyle.WindowFlags.ShowBorders ..
                                        GuiStyle.WindowFlags.NoSavedSettings)
      Gui.SetCursorPosX(170)
      Gui.SetCursorPosY(55)
      Gui.Image("./assets/graphics/menu_logo.png", Math.Vector2f(47 * 6, 27 * 6), Math.FloatRect(0, 0, 47, 27))
    Gui.End()
    
    Gui.PopStyleVar(1) 
    Gui.PopStyleColor(2)
    Gui.SetNextWindowFocus()
  end

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 0))
  Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))
  Gui.PushStyleColor(GuiStyle.Colors.Button, Math.Color(0, 0, 0, 0))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, Math.Color(32, 32, 32, 32))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, Math.Color(64, 64, 64, 32))

  if current_tab == "NewGame" then
    if Effects.IsFadeDone() then
      Intro.Start()
      Gameplay.SetGameState(GameState.Intro)
      current_tab = "Main"
    end
  elseif current_tab == "Main" then
    MainMenu.ShowMain()
  elseif current_tab == "Credits" then
    MainMenu.ShowCredits()
  elseif current_tab == "LoadGame" then
    MainMenu.ShowLoadGame()
  elseif current_tab == "Options" then
    MainMenu.ShowOptions()
  end

  Gui.PopStyleColor(5)
end

MainMenu.ShowMain = function()
  local window_size = Renderer.GetWindowSize()

  local height = 32 * 5 + 8 * 4
  Gui.SetNextWindowSize(400, height)
  Gui.SetNextWindowPos(window_size.x / 2 - 200, window_size.y / 2 - height / 2)
  Gui.BeginFlags("MainButtons",  GuiStyle.WindowFlags.NoTitleBar .. 
                                 GuiStyle.WindowFlags.NoResize ..
                                 GuiStyle.WindowFlags.NoMove ..
                                 GuiStyle.WindowFlags.NoCollapse ..
                                 GuiStyle.WindowFlags.NoScrollbar ..
                                 GuiStyle.WindowFlags.ShowBorders ..
                                 GuiStyle.WindowFlags.NoSavedSettings)

    if Gui.Button("NEW GAME", Math.Vector2f(-1, 32)) then
      current_tab = "NewGame"
      Effects.FadeIn(1)
    end

    if Gui.Button("LOAD GAME", Math.Vector2f(-1, 32)) then
      current_tab = "LoadGame"
      preview_slot = -1
    end

    if Gui.Button("OPTIONS", Math.Vector2f(-1, 32)) then
      current_tab = "Options"
      temp_volume = Audio.GetVolume()
      for i = 1, #Resolutions do
        if Renderer.GetWindowSize().x == Resolutions[i].x then
          current_res = i
          break
        end
      end
    end

    if Gui.Button("CREDITS", Math.Vector2f(-1, 32)) then
      current_tab = "Credits"
      credits_timer = 0.0
    end
    
    if Gui.Button("EXIT", Math.Vector2f(-1, 32)) then
      Engine.Exit()
    end

  Gui.End()
end


MainMenu.ShowLoadGame = function()
  local window_size = Renderer.GetWindowSize()

  local pos_x = window_size.x / 2 - 200

  if preview_slot > -1 then
    pos_x = window_size.x / 2 + 225
  end

  local height = 32 * 6 + 8 * 5
  Gui.SetNextWindowSize(400, height)
  Gui.SetNextWindowPos(pos_x, window_size.y / 2 - height / 2)
  Gui.BeginFlags("LoadGame",  GuiStyle.WindowFlags.NoTitleBar .. 
                              GuiStyle.WindowFlags.NoResize ..
                              GuiStyle.WindowFlags.NoMove ..
                              GuiStyle.WindowFlags.NoCollapse ..
                              GuiStyle.WindowFlags.NoScrollbar ..
                              GuiStyle.WindowFlags.ShowBorders ..
                              GuiStyle.WindowFlags.NoSavedSettings)

    for i = 0, 4 do
      local button_string = "SLOT " .. i
      if Game.Data.IsSlotFree(i) then
        button_string = "EMPTY"
      end

      if Gui.Button(button_string, Math.Vector2f(-1, 32)) then
        if button_string ~= "EMPTY" then
          Game.Data.Load(i)
          Game.Data.ClearAbodes()
          Game.Data.PushAbode(AbodeGenerator.Generate(Game.Data.current_abode))
          preview_slot = i
        end
      end
    end
    
    if Gui.Button("BACK", Math.Vector2f(-1, 32)) then
      current_tab = "Main"
    end

  Gui.End()

  if preview_slot == -1 then
    return
  end

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 128))

  Gui.SetNextWindowSize(400, 440)
  Gui.SetNextWindowPos(window_size.x / 2 - 200, window_size.y / 2 - 220)
  Gui.BeginFlags("LoadGamePreview", GuiStyle.WindowFlags.NoTitleBar .. 
                                    GuiStyle.WindowFlags.NoResize ..
                                    GuiStyle.WindowFlags.NoMove ..
                                    GuiStyle.WindowFlags.NoCollapse ..
                                    GuiStyle.WindowFlags.NoScrollbar ..
                                    GuiStyle.WindowFlags.ShowBorders ..
                                    GuiStyle.WindowFlags.NoSavedSettings)
    Gui.TextExpandedCentered(Game.Data.group_name, "h")
    Gui.SetCursorPosY(32)
    Gui.SetCursorPosX(Gui.GetWindowWidth() / 2 - 75)
    Gui.Image("./assets/graphics/logos/" .. Game.Data.logo .. ".png", Math.Vector2f(150, 150), Math.FloatRect(0, 0, 32, 32))
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 16)
    
    Gui.TextExpanded("Abode: " .. Game.Data.GetAbode(0).name)
    Gui.TextExpanded("Day: " .. Game.Data.day)
    Gui.TextExpanded("Hackers: " .. Game.Data.GetHackersNumber())
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

    Gui.TextExpanded("Name: " .. Game.Data.GetHacker(0).name)
    Gui.TextExpanded("Level: " .. Game.Data.GetHacker(0).level)

    if Gui.Button("Load", Math.Vector2f(-1, 32)) then
      Gameplay.LoadGame(preview_slot)
      Gameplay.SetGameState(GameState.Game)
      preview_slot = -1
    end 

    Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.Red)
    if Gui.Button("Remove", Math.Vector2f(-1, 32)) then
      Game.Data.DeleteSlot(preview_slot)
      preview_slot = -1
    end  
    Gui.PopStyleColor(1)

    if Gui.Button("Back", Math.Vector2f(-1, 32)) then
      preview_slot = -1
    end

    abode_in_background = Game.Data.current_abode
  Gui.End()

  Gui.PopStyleColor(1)
end

MainMenu.ShowOptions = function()
  local window_size = Renderer.GetWindowSize()

  local height = 32 * 4 + 8 * 3
  Gui.SetNextWindowSize(400, height)
  Gui.SetNextWindowPos(window_size.x / 2 - 200, window_size.y / 2 - height / 2)
  Gui.BeginFlags("Options",   GuiStyle.WindowFlags.NoTitleBar .. 
                              GuiStyle.WindowFlags.NoResize ..
                              GuiStyle.WindowFlags.NoMove ..
                              GuiStyle.WindowFlags.NoCollapse ..
                              GuiStyle.WindowFlags.NoScrollbar ..
                              GuiStyle.WindowFlags.ShowBorders ..
                              GuiStyle.WindowFlags.NoSavedSettings)

    local res_button_string = math.ceil(Resolutions[current_res].x) .. " x " .. math.ceil(Resolutions[current_res].y)
    if Gui.Button(res_button_string, Math.Vector2f(-1, 32)) then
      current_res = current_res + 1
      if current_res > #Resolutions then
        current_res = 1
      end
    end
    Hud.SetTooltip("Resolution")

    if Gui.Button("-", Math.Vector2f(32, 32)) then
      temp_volume = temp_volume - 10.0
      if temp_volume > 100.0 then
        temp_volume = 100.0
      elseif temp_volume < 0.0 then
        temp_volume = 0.0
      end
      Audio.SetVolume(temp_volume)
    end

    Gui.SameLine(0, -1)

    if Gui.Button(tostring(temp_volume), Math.Vector2f(-39, 32)) then
    end
    Hud.SetTooltip("Volume")
    Gui.SameLine(0, -1)

    if Gui.Button("+", Math.Vector2f(32, 32)) then
      temp_volume = temp_volume + 10.0
      if temp_volume > 100.0 then
        temp_volume = 100.0
      elseif temp_volume < 0.0 then
        temp_volume = 0.0
      end
      Audio.SetVolume(temp_volume)
    end

    if Gui.Button("APPLY", Math.Vector2f(-1, 32)) then
      Audio.SetVolume(temp_volume)
      Renderer.SetWindowSize(Resolutions[current_res])
      Engine.SaveSettings()
    end
    
    if Gui.Button("BACK", Math.Vector2f(-1, 32)) then
      current_tab = "Main"
    end

  Gui.End()
end

MainMenu.ShowCredits = function()
  local window_size = Renderer.GetWindowSize()

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 0))
  
  Gui.SetNextWindowSize(window_size.x, window_size.y)
  Gui.SetNextWindowPos(0, 0)

  Gui.BeginFlags("Credits", GuiStyle.WindowFlags.NoTitleBar .. 
                            GuiStyle.WindowFlags.NoResize ..
                            GuiStyle.WindowFlags.NoMove ..
                            GuiStyle.WindowFlags.NoCollapse ..
                            GuiStyle.WindowFlags.NoScrollbar ..
                            GuiStyle.WindowFlags.NoSavedSettings)
    Gui.SetCursorPosY(-math.ceil(credits_timer * 50) + (window_size.y / 2.0))
    for i = 1, #credits do
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 24)
      Gui.TextExpandedCentered(credits[i], "h")
    end

    if Gui.GetCursorPosY() < -16 then
      current_tab = "Main"
    end
  Gui.End()

  Gui.PopStyleColor(1)

  if Input.Keyboard.GetKeyDown(Keycode.Keyboard.Escape) then
    current_tab = "Main"
  end

  credits_timer = credits_timer + Time.delta_time
end

