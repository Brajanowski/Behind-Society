InGameMenu = {}

local current_tab = "Main"
local current_res = 1

local temp_volume = 0.0

InGameMenu.SetTab = function(tab)
  current_tab = tab
end

InGameMenu.Show = function()
  local window_size = Renderer.GetWindowSize()

  -- background
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 128))
  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 0)
  
  Gui.SetNextWindowSize(window_size.x, window_size.y)
  Gui.SetNextWindowPos(0, 0)

  Gui.BeginFlags("InGameMenuBG", GuiStyle.WindowFlags.NoTitleBar .. 
                                 GuiStyle.WindowFlags.NoResize ..
                                 GuiStyle.WindowFlags.NoMove ..
                                 GuiStyle.WindowFlags.NoCollapse ..
                                 GuiStyle.WindowFlags.NoScrollbar .. 
                                 GuiStyle.WindowFlags.NoSavedSettings)
 
  Gui.End()

  Gui.PopStyleVar(1)
  Gui.PopStyleColor(1)
  
  -- buttons
  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, HudPalette.Black)
  Gui.PushStyleColor(GuiStyle.Colors.Border, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.Button, HudPalette.DarkBlue)
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, HudPalette.Blue)
  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 0)
  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(10, 0))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(1, 1))
  
  Gui.SetNextWindowSize(320, 450)
  Gui.SetNextWindowPos(window_size.x / 2.0 - 160, 
                       window_size.y / 2.0 - 225)
  Gui.SetNextWindowFocus()
  Gui.BeginFlags("InGameMenuButtons", GuiStyle.WindowFlags.NoTitleBar .. 
                                      GuiStyle.WindowFlags.NoResize ..
                                      GuiStyle.WindowFlags.NoMove ..
                                      GuiStyle.WindowFlags.NoCollapse ..
                                      GuiStyle.WindowFlags.NoScrollbar ..
                                      GuiStyle.WindowFlags.NoSavedSettings ..
                                      GuiStyle.WindowFlags.ShowBorders)

    Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))
    
    if current_tab == "Main" then
      InGameMenu.ShowMain()
    elseif current_tab == "SaveGame" then
      InGameMenu.ShowSaveGame()
    elseif current_tab == "LoadGame" then
      InGameMenu.ShowLoadGame()
    elseif current_tab == "Options" then
      InGameMenu.ShowOptions()
    end

    Gui.PopStyleColor(1)

  Gui.End()

  Gui.PopStyleVar(3)
  Gui.PopStyleColor(6)
end

InGameMenu.ShowMain = function()
  Gui.SetCursorPosY(32)
  Gui.TextExpandedCentered("P a u s e  M e n u", "h")
  
  Gui.SetCursorPosY(48)
  Gui.SetCursorPosX(Gui.GetWindowWidth() / 2 - 64)
  Gui.Image("group_logo",
            Math.Vector2f(128, 128),
            Math.FloatRect(0, 0, 32, 32))


  Gui.SetCursorPosY(180)

  if Gui.Button("Resume", Math.Vector2f(300, 32)) then
    Gameplay.HideInGameMenu()
  end

  Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
  if Gui.Button("Save game", Math.Vector2f(300, 32)) then
    current_tab = "SaveGame"
  end

  Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
  if Gui.Button("Load game", Math.Vector2f(300, 32)) then
    current_tab = "LoadGame"
  end
  
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
  if Gui.Button("Options", Math.Vector2f(300, 32)) then
    current_tab = "Options"

    temp_volume = Audio.GetVolume()

    local window_size = Renderer.GetWindowSize()
    for i = 1, #Resolutions do
      if window_size.x == Resolutions[i].x then
        current_res = i
        break
      end
    end
  end

  Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
  if Gui.Button("Go to main menu", Math.Vector2f(300, 32)) then
    Gameplay.SetGameState(GameState.MainMenu)
    Gameplay.HideInGameMenu()
  end

  Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
  if Gui.Button("Exit game", Math.Vector2f(300, 32)) then
    Engine.Exit()
  end
end

InGameMenu.ShowSaveGame = function()
  Gui.SetCursorPosY(48)
  Gui.TextExpandedCentered("S a v e  G a m e", "h")

  Gui.SetCursorPosY(160)
  for i = 0, 4 do
    local button_string = "Slot " .. i
    if Game.Data.IsSlotFree(i) then
      button_string = "Empty slot " .. i
    end

    Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
    if Gui.Button(button_string, Math.Vector2f(300, 32)) then
      Game.Data.Save(i)
      Console.Log("Saving game on slot " .. i)
    end
  end

  Gui.SetCursorPosY(Gui.GetCursorPosY() + 16)
  if Gui.Button("Back", Math.Vector2f(300, 32)) then
    current_tab = "Main"
  end
end

local selected_slot = -1
InGameMenu.ShowLoadGame = function()
  Gui.SetCursorPosY(48)
  Gui.TextExpandedCentered("L o a d  G a m e", "h")

  Gui.SetCursorPosY(160)
  for i = 0, 4 do
    local button_string = "Slot " .. i
    if Game.Data.IsSlotFree(i) then
      button_string = "Empty slot " .. i
    end

    Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
    if Gui.Button(button_string, Math.Vector2f(300, 32)) then
      if Game.Data.IsSlotFree(i) == false then
        Effects.FadeIn(0.7)
        selected_slot = i
      end
    end
  end
  
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 16)
  if Gui.Button("Back", Math.Vector2f(300, 32)) then
    current_tab = "Main"
  end

  if Effects.IsFadeDone() and selected_slot >= 0 then
    Gameplay.LoadGame(selected_slot)
    Gameplay.HideInGameMenu()
    Effects.FadeOut(0.7)
    selected_slot = -1
  end
end

InGameMenu.ShowOptions = function()
  Gui.SetCursorPosY(32)
  Gui.TextExpandedCentered("O p t i o n s", "h")
  
  Gui.SetCursorPosY(128)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 16)
  if Gui.Button("<", Math.Vector2f(32, 32)) then
    current_res = current_res - 1
    if current_res < 1 then
      current_res = #Resolutions
    end
  end
  
  Gui.SameLine(0, -1)
  if Gui.Button(math.ceil(Resolutions[current_res].x) .. " x " .. math.ceil(Resolutions[current_res].y), Math.Vector2f(-39, 32)) then
  end
  Hud.SetTooltip("Resolution")
  
  Gui.SameLine(0, -1)
  if Gui.Button(">", Math.Vector2f(32, 32)) then
    current_res = current_res + 1
    if current_res > #Resolutions then
      current_res = 1
    end
  end
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 16)

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

  
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 16)
  if Gui.Button("Apply", Math.Vector2f(300, 32)) then
    Audio.SetVolume(temp_volume)
    Renderer.SetWindowSize(Resolutions[current_res])
    Engine.SaveSettings()
  end

  Gui.SetCursorPosY(Gui.GetCursorPosY() + 16)
  if Gui.Button("Back", Math.Vector2f(300, 32)) then
    current_tab = "Main"
  end
end

