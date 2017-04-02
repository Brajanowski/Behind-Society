Hud = {}

local current_tray_position_x = -400
local tray_window_size = Math.Vector2f(400, 480)

local show_logs = false

local current_tray_tab = "Hackers"
local current_window = "nowindow"

local computer_id = -1

local task_to_assign_id = -1

local show_hire_window = false

local notifications = {}

local confirmation = nil

-- hud palette
HudPalette = {}
HudPalette.Red = Math.Color(209, 33, 33, 255)
HudPalette.Blue = Math.Color(47, 65, 84, 255)
HudPalette.DarkBlue = Math.Color(29, 39, 51, 255)
HudPalette.Black = Math.Color(8, 8, 8, 255)
HudPalette.White = Math.Color(210, 210, 210, 255)
HudPalette.Yellow = Math.Color(208, 214, 92, 255)
HudPalette.Green = Math.Color(33, 200, 33, 255)

-- 
local anim_handler_idle = Renderer.AnimationHandler()
anim_handler_idle:SetFrameSize(Math.IntRect(0, 0, 16, 32))
anim_handler_idle:AddAnimation(Renderer.Animation(0, 3, 1.0))
anim_handler_idle:Play(0)

local anim_handler_computer = Renderer.AnimationHandler()
anim_handler_computer:SetFrameSize(Math.IntRect(0, 0, 16, 32))
anim_handler_computer:AddAnimation(Renderer.Animation(0, 3, 1.0))
anim_handler_computer:AddAnimation(Renderer.Animation(0, 3, 1.0))
anim_handler_computer:Play(1)

Hud.Show = function()
  local window_size = Renderer.GetWindowSize()

  anim_handler_idle:Update(Time.delta_time)
  anim_handler_computer:Update(Time.delta_time)

  -- global styles
  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 0)

  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.Yellow)
  Gui.PushStyleColor(GuiStyle.Colors.TitleBg, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.TitleBgActive, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.Border, HudPalette.Blue)

  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarBg, HudPalette.DarkBlue)
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrab, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabHovered, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabActive, HudPalette.Blue)

  Gui.PushStyleColor(GuiStyle.Colors.Button, HudPalette.DarkBlue)
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, HudPalette.Blue)
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, HudPalette.Blue)

  -- hire window
  if show_hire_window == true then
    Hud.ShowHireWindow()
  end
 
  -- Statistics bar
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 0))
  
  Gui.SetNextWindowSize(window_size.x, 32)
  Gui.SetNextWindowPos(0, 0)

  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(0, 0))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(0, 0))
  Gui.BeginFlags("StatisticsBG", GuiStyle.WindowFlags.NoTitleBar .. 
                                 GuiStyle.WindowFlags.NoResize ..
                                 GuiStyle.WindowFlags.NoMove ..
                                 GuiStyle.WindowFlags.NoCollapse ..
                                 GuiStyle.WindowFlags.NoScrollbar ..
                                 GuiStyle.WindowFlags.NoInputs ..
                                 GuiStyle.WindowFlags.NoSavedSettings)
    Gui.Image("./assets/graphics/gui/stats_left.png", Math.Vector2f(32, 32), Math.FloatRect(0, 0, 16, 16))
    Gui.SameLine(0, 0)
    Gui.Image("./assets/graphics/gui/stats_middle.png", Math.Vector2f(window_size.x - 64, 32), Math.FloatRect(0, 0, 16, 16))
    Gui.SameLine(0, 0)
    Gui.Image("./assets/graphics/gui/stats_right.png", Math.Vector2f(32, 32), Math.FloatRect(0, 0, 16, 16))
  Gui.End()
  Gui.PopStyleVar(2)

  Gui.SetNextWindowSize(window_size.x, 32)
  Gui.SetNextWindowPos(0, 0)

  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(0, 0))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(0, 0))

  Gui.BeginFlags("Statistics", GuiStyle.WindowFlags.NoTitleBar .. 
                               GuiStyle.WindowFlags.NoResize ..
                               GuiStyle.WindowFlags.NoMove ..
                               GuiStyle.WindowFlags.NoCollapse ..
                               GuiStyle.WindowFlags.NoScrollbar ..
                               GuiStyle.WindowFlags.NoInputs ..
                               GuiStyle.WindowFlags.NoSavedSettings)
    
    Gui.SetCursorPosX(math.ceil(window_size.x * 0.33))

    Gui.SetCursorPosY(16 - 8)
    Gui.Image("./assets/graphics/gui/fans_icon.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Gui.SameLine(0, 8)

    local fans_str = "fans"

    if Game.Data.fans == 1 then
      fans_str = "fan"
    end

    Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.White) .. 
                             Game.Data.fans .. " " .. fans_str, "v")

    Gui.SameLine(0, 64)
    Gui.SetCursorPosY(16 - 8)
    Gui.Image("./assets/graphics/gui/money.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Gui.SameLine(0, 8)
    Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.White) .. Game.Data.money, "v")
    
    local day_name = ""

    if Game.Data.day % 7 == 0 then
      day_name = "Sunday"
    elseif Game.Data.day % 7 == 1 then
      day_name = "Monday"
    elseif Game.Data.day % 7 == 2 then
      day_name = "Tuesday"
    elseif Game.Data.day % 7 == 3 then
      day_name = "Wednesday"
    elseif Game.Data.day % 7 == 4 then
      day_name = "Thursday"
    elseif Game.Data.day % 7 == 5 then
      day_name = "Friday"
    elseif Game.Data.day % 7 == 6 then
      day_name = "Saturday"
    end

    local suffix = "th"

    if Game.Data.day == 11 or Game.Data.day == 12 or Game.Data.day == 13 then
      suffix = "th"
    else
      local last_digit = string.sub(tostring(Game.Data.day), 1, -1)
      if last_digit == "1" then
        suffix = "st"
      elseif last_digit == "2" then
        suffix = "nd"
      elseif last_digit == "3" then
        suffix = "rd"
      end
    end
    
    Gui.SameLine(0, 64)
    Gui.SetCursorPosY(16 - 8)
    Gui.Image("./assets/graphics/gui/day_icon.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Gui.SameLine(0, 8)
    Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.White) .. 
                             Game.Data.day .. suffix .. " day, " .. day_name, "v")

    Gui.SameLine(0, 64)
    Gui.SetCursorPosY(16 - 8)
    Gui.Image("./assets/graphics/gui/security.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Gui.SameLine(0, 8)
    Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.White) .. Game.Data.security, "v")
    Hud.SetTooltip("Security points")
    
  Gui.End()

  Gui.PopStyleVar(2)
  Gui.PopStyleColor(1)

  -- Group name
  Gui.SetNextWindowSize(200, 32)
  Gui.SetNextWindowPos(window_size.x - 200 - 32, 64)

  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(0, 0))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(0, 0))
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 0))
  Gui.BeginFlags("GroupName", GuiStyle.WindowFlags.NoTitleBar .. 
                              GuiStyle.WindowFlags.NoResize ..
                              GuiStyle.WindowFlags.NoMove ..
                              GuiStyle.WindowFlags.NoCollapse ..
                              GuiStyle.WindowFlags.NoScrollbar ..
                              GuiStyle.WindowFlags.NoInputs ..
                              GuiStyle.WindowFlags.NoSavedSettings)
    Gui.Image("./assets/graphics/gui/group_name_bg.png", Math.Vector2f(200, 32), Math.FloatRect(0, 0, 200, 32))
    Gui.TextExpandedCentered(Game.Data.group_name, "vh")
  Gui.End()
  Gui.PopStyleVar(2)
  Gui.PopStyleColor(1)

  -- Group logo
  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(0, 0))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(0, 0))

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 0))

  Gui.SetNextWindowSize(150, 150)
  Gui.SetNextWindowPos(window_size.x - 150 - 24 - 32, 64 + 40)

  Gui.BeginFlags("GroupLogo", GuiStyle.WindowFlags.NoTitleBar .. 
                              GuiStyle.WindowFlags.NoResize ..
                              GuiStyle.WindowFlags.NoMove ..
                              GuiStyle.WindowFlags.NoCollapse ..
                              GuiStyle.WindowFlags.NoScrollbar ..
                              GuiStyle.WindowFlags.NoInputs ..
                              GuiStyle.WindowFlags.NoSavedSettings)
    Gui.Image("./assets/graphics/logos/" .. Game.Data.logo .. ".png", Math.Vector2f(150, 150), Math.FloatRect(0, 0, 32, 32))
  Gui.End()

  Gui.PopStyleColor(1)
  Gui.PopStyleVar(2)

  -- Buttons
  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(5, 5))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(5, 5))

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 0))
  Gui.PushStyleColor(GuiStyle.Colors.Button, Math.Color(0, 0, 0, 0))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, Math.Color(0, 0, 0, 32))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, Math.Color(0, 0, 0, 32))

  Gui.SetNextWindowSize(148, 48)
  Gui.SetNextWindowPos(window_size.x - 128 - 24 - 64, 24 + 64 + 150 + 40)
  
  Gui.BeginFlags("Buttons", GuiStyle.WindowFlags.NoTitleBar .. 
                            GuiStyle.WindowFlags.NoResize ..
                            GuiStyle.WindowFlags.NoMove ..
                            GuiStyle.WindowFlags.NoCollapse ..
                            GuiStyle.WindowFlags.NoScrollbar ..
                            GuiStyle.WindowFlags.NoSavedSettings)
    if Gui.ImageButton("./assets/graphics/gui/next_day.png", Math.Vector2f(32, 32)) then
      local show_confirmation = false

      if show_confirmation == true then
        Hud.SetConfirmation("Next day warning!", "Are you sure you want to skip this day? Some of your hackers aren't assigned to any task.",
            function() Gameplay.NextDay() end)
      else
        Gameplay.NextDay()
      end
    end
    Hud.SetTooltip("Start new day.")

    Gui.SameLine(0, 8)
    Gui.PushID("hire_show_button")
    if Gui.ImageButton("./assets/graphics/gui/name.png", Math.Vector2f(32, 32)) then
      show_hire_window = not show_hire_window
    end
    Gui.PopID()
    Hud.SetTooltip("Hire")
    
    Gui.SameLine(0, 8)
    if Gui.ImageButton("./assets/graphics/gui/menu.png", Math.Vector2f(32, 32)) then
      Gameplay.SetPauseMenu(true)
    end
    Hud.SetTooltip("Menu")

  Gui.End()

  Gui.PopStyleColor(4)
  Gui.PopStyleVar(2)
  
  -- draw notifications and messages
  if #notifications > 0 then
    Hud.DrawNotification()
  elseif #Messages.msg > 0 then
    Hud.DrawMessages()
  end

  -- show hide tray
  local mouse_position = Math.Vector2f(Input.Mouse.x, Input.Mouse.y)

  if Hud.IsNotification() == false and Hud.IsTrayVisible() == false then
    if mouse_position.x <= 16 and
       mouse_position.y >= window_size.y / 2 - (tray_window_size.y / 2) and
       mouse_position.y <= window_size.y / 2 + (tray_window_size.y / 2) then
     
      -- preview
      current_tray_position_x = -400 + 16
      Hud.ShowTooltip("Press left button to show tray")
      if Input.Mouse.GetMouseButtonDown(Keycode.Mouse.Left) then
        Hud.ShowTray() 
      end
    else
      current_tray_position_x = -400
    end
  end

  if Hud.IsNotification() and Hud.IsTrayVisible() == true then
    Hud.HideTray()
  end

  Hud.UpdateShowHideTrayAnimation()

  -- tray
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 232))--HudPalette.Black)
  -- Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(23, 34, 34, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.TitleBg, Math.Color(23, 34, 34, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.TitleBgActive, Math.Color(23, 34, 34, 255))

  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarBg, Math.Color(14, 20, 20, 255))
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrab, Math.Color(17, 25, 25, 255))
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabHovered, Math.Color(17, 25, 25, 255))
  Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabActive, Math.Color(17, 25, 25, 255))
  
  Gui.PushStyleColor(GuiStyle.Colors.Button, Math.Color(17, 25, 25, 255))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, Math.Color(23, 34, 33, 255))
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, Math.Color(23, 34, 33, 255))
  
  Gui.SetNextWindowSize(tray_window_size.x, tray_window_size.y)
  Gui.SetNextWindowPos(math.floor(current_tray_position_x) - 1, 
                       window_size.y / 2 - (tray_window_size.y / 2))
  
  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.5, 0.5))
  Gui.SetStyleFloat(GuiStyle.Var.ScrollbarRounding, 0)
  Gui.BeginFlags("Tray", GuiStyle.WindowFlags.NoResize ..
                         GuiStyle.WindowFlags.NoCollapse ..
                         GuiStyle.WindowFlags.NoMove ..
                         GuiStyle.WindowFlags.NoSavedSettings --..
                         --GuiStyle.WindowFlags.NoTitleBar ..
                        -- GuiStyle.WindowFlags.ShowBorders
                         )
    Hud.ShowTrayContent()
  Gui.End()
  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.0, 0.5))

  Gui.PopStyleColor(8)

  -- show window
  Hud.ShowWindow()

  if Hud.IsConfirmation() == true then
    Hud.ShowConfirmation()
  end

  -- pop global styles
  Gui.PopStyleColor(11)
  Gui.PopStyleVar(1)
end

Hud.ShowWindow = function()
  if current_window == "nowindow" then
    return
  end

  local window_size = Renderer.GetWindowSize()

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 128))
  Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))

  Gui.SetNextWindowSize(window_size.x, window_size.y)
  Gui.SetNextWindowPos(0, 0)
  Gui.BeginFlags("WindowBG", GuiStyle.WindowFlags.NoTitleBar .. 
                             GuiStyle.WindowFlags.NoResize ..
                             GuiStyle.WindowFlags.NoMove ..
                             GuiStyle.WindowFlags.NoCollapse ..
                             GuiStyle.WindowFlags.NoScrollbar ..
                             GuiStyle.WindowFlags.ShowBorders ..
                             GuiStyle.WindowFlags.NoSavedSettings)
  Gui.End()
  
  Gui.PopStyleColor(2)

  -- window
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 222))
  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)
  -- Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(23, 34, 34, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.TitleBg, Math.Color(23, 34, 34, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.TitleBgActive, Math.Color(23, 34, 34, 255))

  -- Gui.PushStyleColor(GuiStyle.Colors.ScrollbarBg, Math.Color(14, 20, 20, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrab, Math.Color(17, 25, 25, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabHovered, Math.Color(17, 25, 25, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.ScrollbarGrabActive, Math.Color(17, 25, 25, 255))
  
  -- Gui.PushStyleColor(GuiStyle.Colors.Button, Math.Color(17, 25, 25, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, Math.Color(23, 34, 33, 255))
  -- Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, Math.Color(23, 34, 33, 255))
  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 8)
  Gui.PushStyleFloat(GuiStyle.Var.FrameRounding, 8)

  Gui.SetNextWindowSize(720, 460)
  Gui.SetNextWindowPos(math.ceil((window_size.x - 720.0) / 2.0),
                       math.ceil((window_size.y - 460.0) / 2.0))

  Gui.SetNextWindowFocus()

  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.5, 0.5))

  Gui.BeginFlags(current_window, --GuiStyle.WindowFlags.NoTitleBar .. 
                                  GuiStyle.WindowFlags.NoResize ..
                                  GuiStyle.WindowFlags.NoMove ..
                                  GuiStyle.WindowFlags.NoCollapse ..
                                  GuiStyle.WindowFlags.NoScrollbar ..
                                  --GuiStyle.WindowFlags.ShowBorders ..
                                  GuiStyle.WindowFlags.NoSavedSettings)


    Gui.BeginChild("Content", Math.Vector2f(0, 460 - 72 - 16), false)
      if current_window == "Computer" then -- computer info
        Hud.ShowWindowComputer()
      elseif current_window == "Choose hacker" then
        Hud.ShowWindowChooseHacker()
      elseif current_window == "Task Assigning" then
        Hud.ShowTaskAssigning()
      end
    Gui.EndChild()

    Gui.SetCursorPosX(Gui.GetWindowWidth() - 132 - 16)
    Gui.SetCursorPosY(Gui.GetWindowHeight() - 32 - 16)
    if Gui.Button("Close", Math.Vector2f(132, 32)) then
      current_window = "nowindow"
    end
  Gui.End()

  Gui.PopStyleColor(2)
  Gui.PopStyleVar(2)
end

Hud.ShowWindowComputer = function()
  if computer_id == -1 then
    current_window = "nowindow"
    return
  end

  local computer = Game.Data.GetComputer(computer_id)

  if computer == nil then
    current_window = "nowindow"
    return
  end

  if computer.abode_id < 0 then
    current_window = "nowindow"
    return
  end

  local hacker_id = Game.Data.GetHackerOnComputer(computer_id)
  local hacker = nil
  
  if hacker_id ~= -1 then
    hacker = Game.Data.GetHacker(hacker_id)
  end

  Gui.SetCursorPosX(Gui.GetWindowWidth() - 96 - 64)
  Gui.SetCursorPosY(Gui.GetWindowHeight() / 2.0 - 96 / 2.0)
  Gui.Image(Gameplay.GetTexturePathOfComputer(computer_id), Math.Vector2f(96, 96), Math.FloatRect(0, 0, 32, 32))

  if hacker_id ~= -1 then
    Gui.SetCursorPosX(Gui.GetWindowWidth() - 96 - 64 + 14)
    Gui.SetCursorPosY(Gui.GetWindowHeight() / 2.0 - 96 / 2.0 - 6)
    Gui.Image(Gameplay.GetTexturePathOfHacker(hacker_id), 
              Math.Vector2f(48, 96), anim_handler_computer:GetBoundsFloat())
  end

  Gui.SetCursorPosY(Gui.GetWindowHeight() / 2.0 - (16 * 4) / 2.0)

  local start_x = 64

  Gui.SetCursorPosX(start_x)
  Gui.Image("./assets/graphics/gui/tray_tab_companies.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
  Hud.SetTooltip("Company")

  Gui.SameLine(0, 16)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
  if computer.company == 0 then
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "red")
  else
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "blue")
  end
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)

  -- Generation
  Gui.SetCursorPosX(start_x)
  Gui.Image("./assets/graphics/gui/generation.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
  Hud.SetTooltip("Generation")

  Gui.SameLine(0, 16)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
  Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. computer.generation)
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
  -- upgrade level
  Gui.SetCursorPosX(start_x)
  Gui.Image("./assets/graphics/gui/upgrade_level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
  Hud.SetTooltip("Upgrade level")

  Gui.SameLine(0, 16)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
  Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. computer.upgrade_level)
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
  -- computing power
  Gui.SetCursorPosX(start_x)
  Gui.Image("./assets/graphics/gui/computing_power.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
  Hud.SetTooltip("Computing power")

  Gui.SameLine(0, 16)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
  Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Gameplay.GetComputingPower(computer))
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
  -- show hacker stats
  if hacker_id ~= -1 then
    Gui.SetCursorPosY(Gui.GetWindowHeight() / 2.0 - (16 * 4) / 2.0)
    
    local begin_x = start_x * 4

    -- name
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/name.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Name")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.name)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- cracking
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/cracking.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Cracking")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.cracking)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- security
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/security.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Security")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.security)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- level
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Level")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.level)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- experience
    local x_distance = 110
    
    Gui.SetCursorPosY(Gui.GetWindowHeight() / 2.0 - (16 * 4) / 2.0 + 12 + 12)
    Gui.SetCursorPosX(begin_x + x_distance)
    Gui.Image("./assets/graphics/gui/exp.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Experience")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.experience .. "/" .. Gameplay.GetExperienceToNextLevel(hacker.level))
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  end

  -- upgrade
  if computer.upgrade_level < 3 and 
     computer.upgrade_level >= 0 then
    local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.SetCursorPosX(Gui.GetWindowWidth() / 2.0 - 16)
    Gui.SetCursorPosY(Gui.GetWindowHeight() - 48)
    if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(32, 32)) then
      Gameplay.UpgradeComputer(computer)
    end
    Hud.SetTooltip("Upgrade ($" .. Gameplay.GetUpgradeCost(computer) .. ")")

    Gui.SetCursorPosX(old_cursor_pos.x)
    Gui.SetCursorPosY(old_cursor_pos.y)
  end

  -- sell
  Gui.SetCursorPosX(Gui.GetWindowWidth() / 2.0 - 16 - 32 - 16)
  Gui.SetCursorPosY(Gui.GetWindowHeight() - 48)
    
  if Gui.ImageButton("./assets/graphics/gui/salary.png", Math.Vector2f(32, 32)) then
    Hud.SetConfirmation("Selling a computer", "Are you sure?", 
      function()
        Gameplay.SellComputer(computer_id)
        current_window = "nowindow"
      end)
  end
  Hud.SetTooltip("Sell for $" .. math.floor(Gameplay.GetComputerCost(computer) / 2))

  -- place hacker
  Gui.SetCursorPosX(Gui.GetWindowWidth() / 2.0 - 16 + 32 + 16)
  Gui.SetCursorPosY(Gui.GetWindowHeight() - 48)
  
  if Gui.ImageButton("./assets/graphics/gui/tray_tab_hackers.png", Math.Vector2f(32, 32)) then
    current_window = "Choose hacker"
  end
  Hud.SetTooltip("Place hacker on this computer")
end

Hud.ShowWindowChooseHacker = function()
  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)

    local cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())
    local begin_y = Gui.GetCursorPosY()

    Gui.SetCursorPosX(Gui.GetWindowWidth() / 2.0 - math.floor(357 / 2.0))
    Gui.SetCursorPosY(begin_y + 6)
    Gui.Image("./assets/graphics/gui/hacker_bg.png", Math.Vector2f(357, 111), Math.FloatRect(0, 0, 357, 111))
    
    Gui.SetCursorPosX(cursor_pos.x)
    Gui.SetCursorPosY(cursor_pos.y)

    if hacker.computer >= 0 then
      Gui.SetCursorPosX(180)
      Gui.SetCursorPosY(cursor_pos.y + 12)
      Gui.Image(Gameplay.GetTexturePathOfHacker(i), 
                Math.Vector2f(48, 96), anim_handler_computer:GetBoundsFloat())
      
      Gui.SetCursorPosX(-16 + 180)
      Gui.SetCursorPosY(cursor_pos.y + 6 + 12)
      Gui.Image(Gameplay.GetTexturePathOfComputer(hacker.computer), 
                Math.Vector2f(96, 96), Math.FloatRect(0, 0, 32, 32))
    else
      Gui.SetCursorPosX(200)
      Gui.SetCursorPosY(cursor_pos.y + 12)
      Gui.Image(Gameplay.GetTexturePathOfHacker(i), 
                Math.Vector2f(48, 96), anim_handler_idle:GetBoundsFloat())
    end
    
    local begin_x = 286
    
    -- name
    Gui.SetCursorPosY(begin_y + 12)
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/name.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Name")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)

    if hacker.computer == -1 then
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.name)
      Hud.SetTooltip("This guy is free.")
    elseif hacker.computer == computer_id then
      Gui.TextExpanded(Gui.ColorToString(HudPalette.Blue) .. hacker.name)
      Hud.SetTooltip("This guy is already assigned to this computer.")
    elseif hacker.computer >= 0 then
      Gui.TextExpanded(Gui.ColorToString(HudPalette.Red) .. hacker.name)
      Hud.SetTooltip("This guy is already assigned to another computer.")
    end

    Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

    -- cracking
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/cracking.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Cracking")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.cracking)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- security
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/security.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Security")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.security)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- level
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Level")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.level)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- experience
    local x_distance = 110
    
    Gui.SetCursorPosY(begin_y + 24 + 12 + 8)
    Gui.SetCursorPosX(begin_x + x_distance)
    Gui.Image("./assets/graphics/gui/exp.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Experience")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.experience .. "/" .. Gameplay.GetExperienceToNextLevel(hacker.level))
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- science points
    Gui.SetCursorPosX(begin_x + x_distance)
    Gui.Image("./assets/graphics/gui/science_points.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Science points")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.science_points)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
    -- salary
    if hacker.salary > 0 then
      Gui.SetCursorPosX(begin_x + x_distance) 
      Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Salary")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.salary)
    end

    local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.SetCursorPosX(480)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 24)

    Gui.PushID("place " .. i)
    if Gui.ImageButton("./assets/graphics/gui/out.png", Math.Vector2f(32, 32)) then
      Gameplay.RemoveHackerFromComputer(computer_id)
      hacker.computer = computer_id
      computer_id = -1
      current_window = "nowindow"
    end
    Gui.PopID()

    Hud.SetTooltip("Place him")

    Gui.SetCursorPosX(old_cursor_pos.x)
    Gui.SetCursorPosY(old_cursor_pos.y)

    Gui.SetCursorPosY(begin_y + 128)
  end
end

Hud.ShowTaskAssigning = function()
  if task_to_assign_id < 0 and task_to_assign_id ~= -2 then
    current_window = "nowindow"
    return
  end

  if task_to_assign_id >= Game.Data.GetTaskNumber() then
    current_window = "nowindow"
    return  
  end

  Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.Red) .. "No one is available.", "hv")

  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)

    if hacker.computer >= 0 then
      local cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())
      local begin_y = Gui.GetCursorPosY()

      Gui.SetCursorPosX(Gui.GetWindowWidth() / 2.0 - math.floor(357 / 2.0))
      Gui.SetCursorPosY(begin_y + 6)
      Gui.Image("./assets/graphics/gui/hacker_bg.png", Math.Vector2f(357, 111), Math.FloatRect(0, 0, 357, 111))
      
      Gui.SetCursorPosX(cursor_pos.x)
      Gui.SetCursorPosY(cursor_pos.y)

      -- 
      local begin_x = 286

      -- gfx
      Gui.SetCursorPosX(180)
      Gui.SetCursorPosY(cursor_pos.y + 12)
      Gui.Image(Gameplay.GetTexturePathOfHacker(i), Math.Vector2f(48, 96), anim_handler_computer:GetBoundsFloat())
      
      Gui.SetCursorPosX(-16 + 180)
      Gui.SetCursorPosY(cursor_pos.y + 6 + 12)
      Gui.Image(Gameplay.GetTexturePathOfComputer(hacker.computer), Math.Vector2f(96, 96), Math.FloatRect(0, 0, 32, 32))
    
      -- name
      Gui.SetCursorPosY(begin_y + 12)
      Gui.SetCursorPosX(begin_x)
      Gui.Image("./assets/graphics/gui/name.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Name")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)

      if hacker.task == -1 then
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.name)
        Hud.SetTooltip("This guy is without a job.")
      elseif hacker.task ~= task_to_assign_id then
        Gui.TextExpanded(Gui.ColorToString(HudPalette.Red) .. hacker.name)
        Hud.SetTooltip("This guy is assigned to another task.")
      elseif hacker.task == task_to_assign_id then
        Gui.TextExpanded(Gui.ColorToString(HudPalette.Blue) .. hacker.name)
        Hud.SetTooltip("This guy is already assigned to this task.")
      end

      Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

      -- cracking
      Gui.SetCursorPosX(begin_x)
      Gui.Image("./assets/graphics/gui/cracking.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Cracking")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.cracking)
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
      -- security
      Gui.SetCursorPosX(begin_x)
      Gui.Image("./assets/graphics/gui/security.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Security")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.security)
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
      -- level
      Gui.SetCursorPosX(begin_x)
      Gui.Image("./assets/graphics/gui/level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Level")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 4)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.level)
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
      -- experience
      local x_distance = 110
      
      Gui.SetCursorPosY(begin_y + 24 + 12 + 8)
      Gui.SetCursorPosX(begin_x + x_distance)
      Gui.Image("./assets/graphics/gui/exp.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Experience")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.experience .. "/" .. Gameplay.GetExperienceToNextLevel(hacker.level))
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)
  
      -- assign
      local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

      Gui.SetCursorPosX(480)
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

      Gui.PushID("assign " .. i)
      if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(32, 32)) then
        hacker.task = task_to_assign_id
      end
      Gui.PopID()

      Hud.SetTooltip("Assign")

      Gui.SetCursorPosX(old_cursor_pos.x)
      Gui.SetCursorPosY(old_cursor_pos.y)

      Gui.SetCursorPosY(begin_y + 128)
    end
  end
end

Hud.IsAnyWindowOnScreen = function()
  if show_hire_window == true then
    return true
  elseif current_window ~= "nowindow" then
    return true
  end
  return false
end

local is_animation_playing = false
local is_showing = true
local timer = 0.0
local animation_time = 0.28

Hud.ShowTray = function() 
  if is_animation_playing == true then
    return
  end
  
  is_animation_playing = true
  is_showing = true
  timer = 0.0
end

Hud.HideTray = function()
  is_animation_playing = true
  is_showing = false
  timer = 0.0
end

Hud.IsTrayVisible = function()
  if current_tray_position_x >= 0 then
    return true
  end

  return false
end

Hud.IsTrayAnimationPlaying = function()
  return is_animation_playing
end

Hud.UpdateShowHideTrayAnimation = function()
  if is_animation_playing == false then
    return
  end

  local begin_x = -tray_window_size.x
  local end_x = 0

  if is_showing == false then
    begin_x = 0
    end_x = -tray_window_size.x
  end

  local t = timer / animation_time
  current_tray_position_x = begin_x + (end_x - begin_x) * t 

  timer = timer + Time.delta_time

  if timer >= animation_time then
    is_animation_playing = false
    current_tray_position_x = begin_x + (end_x - begin_x)
  end
end

Hud.ShowTrayContent = function()
  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(1, 1))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(1, 1))

  Gui.PushStyleColor(GuiStyle.Colors.Button, Math.Color(0, 0, 0, 0));
  Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, Math.Color(0, 0, 0, 0));
  Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, Math.Color(0, 0, 0, 0));

  local current_tab_color = HudPalette.Blue
  local tab_border_color = Math.Color(17, 17, 17, 255)
  local tabs_numbers_color = Gui.ColorToString(Math.Color(0, 0, 0, 0))--HudPalette.White)

  local active_tab_color = Math.Color(26, 26, 26, 255)
  local tab_color = Math.Color(0, 0, 0, 0)

  -- hackers
  local last_cursor_pos_x = Gui.GetCursorPosX()
  local last_cursor_pos_y = Gui.GetCursorPosY()

  if current_tray_tab == "Hackers" then
    Gui.PushStyleColor(GuiStyle.Colors.Button, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, active_tab_color)
  else
    Gui.PushStyleColor(GuiStyle.Colors.Button, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, tab_color)
  end

  if Gui.ImageButton("./assets/graphics/gui/tray_tab_hackers.png", 
                     Math.Vector2f(32, 32)) then
    current_tray_tab = "Hackers"
  end
  Hud.SetTooltip("Hackers")

  Gui.PopStyleColor(3)

  Gui.SetCursorPosX(last_cursor_pos_x + 24)
  Gui.SetCursorPosY(last_cursor_pos_y + 16)

  Gui.TextExpanded(tabs_numbers_color .. tostring(Game.Data.GetHackersNumber()))

  Gui.SetCursorPosX(last_cursor_pos_x + 40)
  Gui.SetCursorPosY(last_cursor_pos_y)

  -- companies
  last_cursor_pos_x = Gui.GetCursorPosX()
  last_cursor_pos_y = Gui.GetCursorPosY()

  if current_tray_tab == "Companies" then
    Gui.PushStyleColor(GuiStyle.Colors.Button, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, active_tab_color)
  else
    Gui.PushStyleColor(GuiStyle.Colors.Button, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, tab_color)
  end

  if Gui.ImageButton("./assets/graphics/gui/tray_tab_companies.png", 
                     Math.Vector2f(32, 32)) then
    current_tray_tab = "Companies"
  end
  Hud.SetTooltip("Companies")
  
  Gui.PopStyleColor(3)
 
  Gui.SetCursorPosX(last_cursor_pos_x + 24)
  Gui.SetCursorPosY(last_cursor_pos_y + 24)

  Gui.TextExpanded(tabs_numbers_color .. tostring(Game.Data.GetCompaniesNumber()))

  Gui.SetCursorPosX(last_cursor_pos_x + 40)
  Gui.SetCursorPosY(last_cursor_pos_y)

  -- computers
  last_cursor_pos_x = Gui.GetCursorPosX()
  last_cursor_pos_y = Gui.GetCursorPosY()

  if current_tray_tab == "Computers" then
    Gui.PushStyleColor(GuiStyle.Colors.Button, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, active_tab_color)
  else
    Gui.PushStyleColor(GuiStyle.Colors.Button, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, tab_color)
  end

  if Gui.ImageButton("./assets/graphics/gui/tray_tab_computers.png", 
                     Math.Vector2f(32, 32)) then
    current_tray_tab = "Computers"
  end
  Hud.SetTooltip("Computers")

  Gui.PopStyleColor(3)
  
  Gui.SetCursorPosX(last_cursor_pos_x + 24)
  Gui.SetCursorPosY(last_cursor_pos_y + 24)

  Gui.TextExpanded(tabs_numbers_color .. tostring(Game.Data.GetComputersNumber()))

  Gui.SetCursorPosX(last_cursor_pos_x + 40)
  Gui.SetCursorPosY(last_cursor_pos_y)

  -- store
  last_cursor_pos_x = Gui.GetCursorPosX()
  last_cursor_pos_y = Gui.GetCursorPosY()

  if current_tray_tab == "Store" then
    Gui.PushStyleColor(GuiStyle.Colors.Button, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, active_tab_color)
  else
    Gui.PushStyleColor(GuiStyle.Colors.Button, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, tab_color)
  end

  if Gui.ImageButton("./assets/graphics/gui/tray_tab_store.png", 
                     Math.Vector2f(32, 32)) then
    current_tray_tab = "Store"
  end
  Hud.SetTooltip("Store")
  
  Gui.PopStyleColor(3)
  
  Gui.SetCursorPosX(last_cursor_pos_x + 24)
  Gui.SetCursorPosY(last_cursor_pos_y + 24)

  Gui.TextExpanded(tabs_numbers_color .. tostring(#ComputerStore.computers))

  Gui.SetCursorPosX(last_cursor_pos_x + 40)
  Gui.SetCursorPosY(last_cursor_pos_y)

  -- tasks
  last_cursor_pos_x = Gui.GetCursorPosX()
  last_cursor_pos_y = Gui.GetCursorPosY()
  
  if current_tray_tab == "Tasks" then
    Gui.PushStyleColor(GuiStyle.Colors.Button, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, active_tab_color)
  else
    Gui.PushStyleColor(GuiStyle.Colors.Button, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, tab_color)
  end
  
  if Gui.ImageButton("./assets/graphics/gui/tray_tab_tasks.png", 
                     Math.Vector2f(32, 32)) then
    current_tray_tab = "Tasks"
  end
  Hud.SetTooltip("Tasks")
  
  Gui.PopStyleColor(3)

  Gui.SetCursorPosX(last_cursor_pos_x + 24)
  Gui.SetCursorPosY(last_cursor_pos_y + 24)

  Gui.TextExpanded(tabs_numbers_color .. tostring(Game.Data.GetTaskNumber()))

  Gui.SetCursorPosX(last_cursor_pos_x + 40)
  Gui.SetCursorPosY(last_cursor_pos_y)

  -- group
  last_cursor_pos_x = Gui.GetCursorPosX()
  last_cursor_pos_y = Gui.GetCursorPosY()
    
  if current_tray_tab == "Group" then
    Gui.PushStyleColor(GuiStyle.Colors.Button, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, active_tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, active_tab_color)
  else
    Gui.PushStyleColor(GuiStyle.Colors.Button, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonHovered, tab_color)
    Gui.PushStyleColor(GuiStyle.Colors.ButtonActive, tab_color)
  end
  
  if Gui.ImageButton("./assets/graphics/logos/" .. Game.Data.logo .. ".png", 
                     Math.Vector2f(32, 32)) then
    current_tray_tab = "Group"
  end
  Hud.SetTooltip("Group")
  
  Gui.PopStyleColor(3)

  Gui.SetCursorPosX(last_cursor_pos_x + 40)
  Gui.SetCursorPosY(last_cursor_pos_y)

  -- hide tray
  if Gui.ImageButton("./assets/graphics/gui/tray_hide.png", 
                     Math.Vector2f(32, 32)) then
    Hud.HideTray()
  end
  Hud.SetTooltip("Hide Tray")
  
  Gui.PopStyleColor(3)
  Gui.PopStyleVar(2)

  Gui.PushStyleColor(GuiStyle.Colors.ChildWindowBg, Math.Color(26, 26, 26, 255))

  Gui.SetCursorPosY(Gui.GetCursorPosY() - 5)
  Gui.BeginChild("TrayContent", Math.Vector2f(385, 410), false)
    Hud.ShowTrayContentTab()
  Gui.EndChild()

  Gui.PopStyleColor(1)
end

Hud.ShowTrayContentTab = function()
  if current_tray_tab == "Hackers" then
    Hud.ShowTrayContentTabHacker()
  elseif current_tray_tab == "Companies" then
    Hud.ShowTrayContentTabCompanies()
  elseif current_tray_tab == "Computers" then
    Hud.ShowTrayContentTabComputers()
  elseif current_tray_tab == "Store" then
    Hud.ShowTrayContentTabStore()
  elseif current_tray_tab == "Group" then
    Hud.ShowTrayContentGroup()
  elseif current_tray_tab == "Tasks" then
    Hud.ShowTrayContentTabTasks()
  elseif current_tray_tab == "ComputerInfo" then
    Hud.ShowTrayContentTabComputerInfo()
  elseif current_tray_tab == "PlaceHacker" then
    Hud.ShowTrayContentTabPlaceHacker()
  elseif current_tray_tab == "TaskAssigning" then
    Hud.ShowTrayContentTabTaskAssigning()
  elseif current_tray_tab == "Messages" then
    Hud.ShowTrayContentTabMessages()
  end
end

Hud.ShowTrayContentTabHacker = function()
  if Gameplay.IsAnyoneToPay() then
    local total_money = Gameplay.GetTotalMoneyToPay()
    if Game.Data.money >= total_money then
      Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)
      Gui.SetCursorPosY(8)
      Gui.SetCursorPosX(8)
      if Gui.Button("Pay for all ($" .. total_money .. ")", Math.Vector2f(-16, 32)) then
        Gameplay.PayToAll()
      end
      Gui.PopStyleColor(1)
    end
  end

  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)

    local cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())
    local begin_y = Gui.GetCursorPosY()

    Gui.SetCursorPosX(5)
    Gui.SetCursorPosY(begin_y + 6)
    Gui.Image("./assets/graphics/gui/hacker_bg.png", Math.Vector2f(357, 111), Math.FloatRect(0, 0, 357, 111))
    
    Gui.SetCursorPosX(cursor_pos.x)
    Gui.SetCursorPosY(cursor_pos.y)

    if hacker.computer >= 0 then
      Gui.SetCursorPosX(cursor_pos.x + 8)
      Gui.SetCursorPosY(cursor_pos.y + 12)
      Gui.Image(Gameplay.GetTexturePathOfHacker(i), 
                Math.Vector2f(48, 96), anim_handler_computer:GetBoundsFloat())
      
      Gui.SetCursorPosX(-8)
      Gui.SetCursorPosY(cursor_pos.y + 6 + 12)
      Gui.Image(Gameplay.GetTexturePathOfComputer(hacker.computer), 
                Math.Vector2f(96, 96), Math.FloatRect(0, 0, 32, 32))
    else
      Gui.SetCursorPosX(cursor_pos.x + 16)
      Gui.SetCursorPosY(cursor_pos.y + 12)
      Gui.Image(Gameplay.GetTexturePathOfHacker(i), 
                Math.Vector2f(48, 96), anim_handler_idle:GetBoundsFloat())
    end
    
    local begin_x = 115
    
    -- name
    Gui.SetCursorPosY(begin_y + 12)
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/name.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Name")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.name)

    Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

    -- cracking
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/cracking.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Cracking")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY())
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.cracking)

    if hacker.science_points > 0 then
      Gui.SameLine(0, 24)
      Gui.SetCursorPosY(Gui.GetCursorPosY())
      Gui.PushID("crackingadd" .. i)
      if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(16, 16)) then
        hacker.science_points = hacker.science_points - 1
        hacker.cracking = hacker.cracking + 1
      end
      Gui.PopID()
      Hud.SetTooltip("Increase cracking statistic")
    end

    -- security
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/security.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Security")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY())
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.security)

    if hacker.science_points > 0 then
      Gui.SameLine(0, 24)
      Gui.SetCursorPosY(Gui.GetCursorPosY())
      Gui.PushID("securityadd" .. i)
      if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(16, 16)) then
        hacker.science_points = hacker.science_points - 1
        hacker.security = hacker.security + 1
      end
      Gui.PopID()
      Hud.SetTooltip("Increase security statistic")
    end

    -- level
    Gui.SetCursorPosX(begin_x)
    Gui.Image("./assets/graphics/gui/level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Level")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY())
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.level)

    -- experience
    local x_distance = 110
    
    Gui.SetCursorPosY(begin_y + 24 + 12 + 8)
    Gui.SetCursorPosX(begin_x + x_distance)
    Gui.Image("./assets/graphics/gui/exp.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Experience")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY())
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.experience
                     .. "/" .. Gameplay.GetExperienceToNextLevel(hacker.level))

    -- science points
    Gui.SetCursorPosX(begin_x + x_distance)
    Gui.Image("./assets/graphics/gui/science_points.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Science points")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY())
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.science_points)

    -- salary
    if hacker.salary > 0 then 
      if hacker.days_to_quit > 0 then
        local y_pos = Gui.GetCursorPosY()
        Gui.SetCursorPosX(begin_x + x_distance - 4)
        Gui.SetCursorPosY(y_pos - 4)
        if Gui.Button("##" .. i, Math.Vector2f(72, 24)) then
          Gameplay.PaySalary(i)
        end
        
        Gui.SameLine(0, 0)
        Hud.SetTooltip("Pay him cashmoney.")

        Gui.SetCursorPosX(begin_x + x_distance)
        Gui.SetCursorPosY(y_pos)
        Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 5)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.Red) .. hacker.salary)

      elseif hacker.days_to_quit == -1 then
        Gui.SetCursorPosX(begin_x + x_distance) 
        Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("Salary")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY())
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hacker.salary)
      end

    end

    Gui.SetCursorPosY(begin_y + 128)
  end
end

Hud.ShowTrayContentTabCompanies = function()
  local padding_y = 8

  Gui.SetCursorPosY(4)
  for i = 0, Game.Data.GetCompaniesNumber() - 1 do
    local company = Game.Data.GetCompany(i)

    local begin_cursor = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.SetCursorPosX(5)
    Gui.SetCursorPosY(begin_cursor.y + 6)
    Gui.Image("./assets/graphics/gui/stats_bg.png", Math.Vector2f(357, 111), Math.FloatRect(0, 0, 357, 111))
    
    Gui.SetCursorPosX(begin_cursor.x + 12)
    Gui.SetCursorPosY(begin_cursor.y + 28)
    Gui.Image(CompanyType.GetIconPathByType(company.type), Math.Vector2f(64, 64), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip(CompanyType.ToString(company.type))

    Gui.SetCursorPosY(begin_cursor.y)

    local start_x = 116

    -- name
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 16) Gui.SetCursorPosX(start_x) if company.break_time > 0 then Gui.TextExpanded(Gui.ColorToString(HudPalette.Red) .. company.name) Hud.SetTooltip("This company is disabled because of a technical break.") else Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. company.name) end
    -- security
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/security.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Security")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. company.security)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

    -- popularity
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/fans_icon.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Popularity (number of fans)")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. company.popularity)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
    -- people love
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/love.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("People love")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. (company.people_love - 50))
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
    if company.break_time <= 0 then
      local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

      Gui.SetCursorPosX(312)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 44)
      if Gameplay.IsCompanyInTask(i) == false then
        Gui.PushID("company_hack " .. i)
        if Gui.ImageButton("./assets/graphics/gui/cracking.png", Math.Vector2f(32, 32)) then
          Gameplay.HackCompany(i)
        end
        Gui.PopID()
      end
      Hud.SetTooltip("Press this button to add \"" .. company.name .. "\" to your tasks list.")

      Gui.SetCursorPosX(old_cursor_pos.x)
      Gui.SetCursorPosY(old_cursor_pos.y)
    end

    Gui.SetCursorPosY(begin_cursor.y + 64 + 64)
  end
end

Hud.ShowTrayContentTabComputers = function()
  if Game.Data.GetComputersNumber() == 0 then
    Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.Red) .. "Empty...", "hv")
    return
  end
  local padding_y = 8
  for i = 0, Game.Data.GetComputersNumber() - 1 do
    local computer = Game.Data.GetComputer(i)
    
    local begin_cursor = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())
    
    Gui.SetCursorPosX(5)
    Gui.SetCursorPosY(begin_cursor.y + 6)
    Gui.Image("./assets/graphics/gui/stats_bg.png", Math.Vector2f(357, 111), Math.FloatRect(0, 0, 357, 111))
    
    Gui.SetCursorPosX(begin_cursor.x - 4)
    Gui.SetCursorPosY(begin_cursor.y + 16)
    Gui.Image(Gameplay.GetTexturePathOfComputer(i), Math.Vector2f(96, 96), Math.FloatRect(0, 0, 32, 32))
    
    Gui.SetCursorPosY(begin_cursor.y + 16)

    -- company
    local start_x = 132
    
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/tray_tab_companies.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Company")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    if computer.company == 0 then
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "red")
    else
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "blue")
    end
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

    -- Generation
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/generation.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Generation")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. computer.generation)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

    -- upgrade level
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/upgrade_level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Upgrade level")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. computer.upgrade_level)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

    -- computing power
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/computing_power.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Computing power")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Gameplay.GetComputingPower(computer))
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
    -- upgrade
    if computer.upgrade_level < 3 and 
       computer.upgrade_level >= 0 then
      local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

      Gui.SetCursorPosX(312)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 38)
      Gui.PushID("upgrade_computer " .. i)
      if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(32, 32)) then
        Gameplay.UpgradeComputer(computer)
      end
      Gui.PopID()
      Hud.SetTooltip("Upgrade ($" .. Gameplay.GetUpgradeCost(computer) .. ")")

      Gui.SetCursorPosX(old_cursor_pos.x)
      Gui.SetCursorPosY(old_cursor_pos.y)
    end

    -- sell
    local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.SetCursorPosX(312 - 42)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 38)
      
    Gui.PushID("sell_computer " .. i)
    if Gui.ImageButton("./assets/graphics/gui/salary.png", Math.Vector2f(32, 32)) then
      Hud.SetConfirmation("Selling a computer", "Are you sure?", function() Gameplay.SellComputer(i) end)
    end
    Gui.PopID()
    Hud.SetTooltip("Sell for $" .. math.floor(Gameplay.GetComputerCost(computer) / 2))
    
    Gui.SetCursorPosX(old_cursor_pos.x)
    Gui.SetCursorPosY(old_cursor_pos.y)

    if computer.abode_id == -1 then
      Gui.SetCursorPosX(312 - 42 * 2.0)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 38)
      Gui.PushID("place_computer " .. i)
      if Gui.ImageButton("./assets/graphics/gui/out.png", Math.Vector2f(32, 32)) then
        Gameplay.TurnOnPlaceComputerMode(i)
      end
      Gui.PopID()
      Hud.SetTooltip("Place on current abode")
      
      Gui.SetCursorPosX(old_cursor_pos.x)
      Gui.SetCursorPosY(old_cursor_pos.y)
    elseif computer.abode_id >= 0 then
      Gui.SetCursorPosX(312 - 42 * 2.0)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 38)
      Gui.PushID("hide_computer " .. i)
      if Gui.ImageButton("./assets/graphics/gui/home.png", Math.Vector2f(32, 32)) then
        computer.abode_id = -1
        Gameplay.RemoveHackerFromComputer(i)
      end
      Gui.PopID()

      Hud.SetTooltip("Take it bake to the warehouse")
      Gui.SetCursorPosX(old_cursor_pos.x)
      Gui.SetCursorPosY(old_cursor_pos.y)
    end

    -- end
    Gui.SetCursorPosY(begin_cursor.y + 64 + 64)
  end
end

Hud.ShowTrayContentTabStore = function()
  local padding_y = 8
  for i = #ComputerStore.computers, 1, -1 do
    local computer = ComputerStore.computers[i]
    local begin_cursor = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())
    
    Gui.SetCursorPosX(5)
    Gui.SetCursorPosY(begin_cursor.y + 6)
    Gui.Image("./assets/graphics/gui/stats_bg.png", Math.Vector2f(357, 111), Math.FloatRect(0, 0, 357, 111))
    
    Gui.SetCursorPosX(begin_cursor.x - 4)
    Gui.SetCursorPosY(begin_cursor.y + 16)
    Gui.Image(Gameplay.GetTexturePathOfComputerByData(computer.company, computer.generation), Math.Vector2f(96, 96), Math.FloatRect(0, 0, 32, 32))
    
    Gui.SetCursorPosY(begin_cursor.y + 16)

    -- company
    local start_x = 132

    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/tray_tab_companies.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Company")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    if computer.company == 0 then
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "red")
    else
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. "blue")
    end
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)

    -- Generation
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/generation.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Generation")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. computer.generation)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)

    -- upgrade level
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/upgrade_level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Upgrade level")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. computer.upgrade_level)
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)

    -- computing power
    Gui.SetCursorPosX(start_x)
    Gui.Image("./assets/graphics/gui/computing_power.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Computing power")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Gameplay.GetComputingPower(computer))
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)

    -- price
    local x_distance = 215
    
    Gui.SetCursorPosY(begin_cursor.y + 16)
    Gui.SetCursorPosX(begin_cursor.x + x_distance)
    Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
    Hud.SetTooltip("Price")

    Gui.SameLine(0, 16)
    Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Gameplay.GetComputerCost(computer))
    Gui.SetCursorPosY(Gui.GetCursorPosY() + 6)

    -- buy computer
    local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.SetCursorPosX(312)
    Gui.SetCursorPosY(begin_cursor.y + 64 + 10)
      
    Gui.PushID("buy_computer " .. i)
    if Gui.ImageButton("./assets/graphics/gui/shop.png", Math.Vector2f(32, 32)) then
      Gameplay.BuyComputer(Gameplay.GetComputerCost(computer), computer)
    end
    Gui.PopID()
    Hud.SetTooltip("Buy")
    
    Gui.SetCursorPosX(old_cursor_pos.x)
    Gui.SetCursorPosY(old_cursor_pos.y)

    -- end
    Gui.SetCursorPosY(begin_cursor.y + 64 + 64)
  end
end

Hud.ShowTrayContentGroup = function()
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
  Gui.TextExpandedCentered(Game.Data.group_name, "h")
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 24)

  -- current abode
  Gui.SetCursorPosX(16)
  Gui.Image("./assets/graphics/gui/Home.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
  Hud.SetTooltip("Current abode")

  Gui.SameLine(0, 16)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
  Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Game.Data.GetAbode(0).name)
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
  -- rent
  Gui.SetCursorPosX(16)
  Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
  Hud.SetTooltip("Rent")

  Gui.SameLine(0, 16)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 4)
  Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Game.Data.rent)
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
  
  -- places
  Gui.SetCursorPosX(16)
  Gui.Image("./assets/graphics/gui/tray_tab_computers.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
  Hud.SetTooltip("How much computers you can place.")

  Gui.SameLine(0, 16)
  Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
  Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Gameplay.GetMaxComputerPlaces(Game.Data.current_abode))
  Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
  
  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)

  Gui.SetCursorPosY(Gui.GetCursorPosY() + 12)
  if Game.Data.current_abode < GameConfig.MAX_ABODES - 1 then
    Gui.SetCursorPosX(16)
    if Gui.Button("Upgrade ($" .. Gameplay.GetAbodeCost(Game.Data.current_abode + 1) .. ")", Math.Vector2f(-32, 32)) then
      if Game.Data.money >= Gameplay.GetAbodeCost(Game.Data.current_abode + 1) then
        Gameplay.UpgradeAbode()
      end
    end

    Hud.SetTooltip("You can place " .. Gameplay.GetMaxComputerPlaces(Game.Data.current_abode + 1) .. " desktops on the next abode.\nAnd rent will be $" .. Gameplay.GetAbodeRent(Game.Data.current_abode + 1))
  end

  Gui.SetCursorPosX(16)
  if Gui.Button("Secure", Math.Vector2f(-32, 32)) then
    current_window = "Task Assigning"
    task_to_assign_id = -2
  end
  Gui.PopStyleColor(1)
end

Hud.ShowTrayContentTabTasks = function()
  if Game.Data.GetTaskNumber() == 0 then
    Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.Red) .. "There is no tasks", "hv")
  end

  local padding_y = 8
  for i = 0, Game.Data.GetTaskNumber() - 1 do
    local task = Game.Data.GetTask(i)

    local begin_cursor = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())
    
    Gui.SetCursorPosX(5)
    Gui.SetCursorPosY(begin_cursor.y + 6)
    Gui.Image("./assets/graphics/gui/stats_bg.png", Math.Vector2f(357, 111), Math.FloatRect(0, 0, 357, 111))
    
    Gui.SetCursorPosY(begin_cursor.y + 12)

    -- name
    local start_x = 32
    
    if task.type == 0 then
      -- show company info assigned to this task
      if task.company_id >= 0 then
        local company = Game.Data.GetCompany(task.company_id)
        
        Gui.SetCursorPosX(start_x)
        Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.Red) .. "Hacking company", "h")  

        Gui.SetCursorPosY(Gui.GetCursorPosY() + 22)

        -- name
        Gui.SetCursorPosX(start_x)
        Gui.Image("./assets/graphics/gui/tray_tab_companies.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("Company name")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. company.name)
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
        -- popularity
        local stats_begin_y = Gui.GetCursorPosY()

        Gui.SetCursorPosX(start_x)
        Gui.Image("./assets/graphics/gui/fans_icon.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("Popularity (number of fans)")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. company.popularity)
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
        -- people love
        Gui.SetCursorPosX(start_x)
        Gui.Image("./assets/graphics/gui/love.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("People love")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. (company.people_love - 50))
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
        local x_distance = 110

        -- progress
        Gui.SetCursorPosY(stats_begin_y)
        Gui.SetCursorPosX(begin_cursor.x + x_distance)
        Gui.Image("./assets/graphics/gui/exp.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("Progress")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. task.points
                         .. "/" .. task.points_to_finish)
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
    
        -- days left
        if task.days_to_finish > 0 then
          Gui.SetCursorPosX(start_x)
          Gui.Image("./assets/graphics/gui/day_icon.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
          Hud.SetTooltip("Days to pay")

          Gui.SameLine(0, 16)
          Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. task.days_to_finish)
        end

        local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())
        
        Gui.SetCursorPosX(312 - 48)
        Gui.SetCursorPosY(begin_cursor.y + 111 - 38)
        
        Gui.PushID("remove task " .. i)
        if Gui.ImageButton("./assets/graphics/gui/remove.png", Math.Vector2f(32, 32)) then
          Hud.SetConfirmation("Task removing", "Are you sure that you want to remove a task called " .. task.name .. "?",
                  function()
                    Game.Data.RemoveTask(i)
                    Gameplay.TaskRemoved(i)
                  end)
        end
        Gui.PopID()
        Hud.SetTooltip("Remove a task")

        Gui.SetCursorPosX(312)
        Gui.SetCursorPosY(begin_cursor.y + 111 - 38)
        
        Gui.PushID("assign hacker " .. i)
        if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(32, 32)) then
          current_window = "Task Assigning"
          task_to_assign_id = i
        end
        Gui.PopID()
        Hud.SetTooltip("Assign people to this task (" .. Gameplay.GetNumOfReadyHackersToWork() .. " ready and without a job)")

        Gui.SetCursorPosX(old_cursor_pos.x)
        Gui.SetCursorPosY(old_cursor_pos.y)
      end
    elseif task.type == 1 then
      Gui.SetCursorPosX(start_x)
      Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.White) .. task.name, "h")  

      Gui.SetCursorPosY(Gui.GetCursorPosY() + 24)

      -- how much
      Gui.SetCursorPosX(start_x)
      Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Necessary amount of money")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. task.money)
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

      -- days left
      if task.days_to_finish > 0 then
        Gui.SetCursorPosX(start_x)
        Gui.Image("./assets/graphics/gui/day_icon.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("Days to pay")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. task.days_to_finish)
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
      end

      -- pay
      if Game.Data.money >= task.money then
        local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

        Gui.SetCursorPosX(312)
        Gui.SetCursorPosY(begin_cursor.y + 111 - 38)

        Gui.PushID("pay " .. i)
        if Gui.ImageButton("./assets/graphics/gui/money.png", Math.Vector2f(32, 32)) then
          Game.Data.money = Game.Data.money - task.money
          Tasks.TaskDone(i)
        end
        Gui.PopID()

        Hud.SetTooltip("Pay")

        Gui.SetCursorPosX(old_cursor_pos.x)
        Gui.SetCursorPosY(old_cursor_pos.y)
      end

    elseif task.type == 2 then
      Gui.SetCursorPosX(start_x)
      Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.White) .. task.name, "h")  

      Gui.SetCursorPosY(Gui.GetCursorPosY() + 18)

      local stats_begin_y = Gui.GetCursorPosY()

      -- progress
      Gui.Image("./assets/graphics/gui/exp.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Progress")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. task.points .. "/" .. task.points_to_finish)
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

      -- people assigned
      Gui.SetCursorPosX(start_x)
      Gui.Image("./assets/graphics/gui/tray_tab_hackers.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
      Hud.SetTooltip("Number of people assigned to this task")

      Gui.SameLine(0, 16)
      Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
      Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. Gameplay.GetNumOfPeopleAssignedToTask(i))
      Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)

      -- reward
      if task.reward >= 0 then
        Gui.SetCursorPosX(start_x)
        Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("Reward")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. task.reward)
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
      end

      -- days left
      local x_distance = 110
      if task.days_to_finish > 0 then
        Gui.SetCursorPosY(stats_begin_y)
        Gui.SetCursorPosX(start_x + x_distance)
        Gui.Image("./assets/graphics/gui/day_icon.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
        Hud.SetTooltip("Days to finish")

        Gui.SameLine(0, 16)
        Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
        Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. task.days_to_finish)
        Gui.SetCursorPosY(Gui.GetCursorPosY() + 4)
      end

      local old_cursor_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

      Gui.SetCursorPosX(312)
      Gui.SetCursorPosY(begin_cursor.y + 111 - 38)
      Gui.PushID("assign hacker " .. i)
      if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(32, 32)) then
        current_window = "Task Assigning"
        task_to_assign_id = i
      end
      Gui.PopID()

      Hud.SetTooltip("Assign people to this task (" .. Gameplay.GetNumOfReadyHackersToWork() .. " ready and without a job)")

      Gui.SetCursorPosX(old_cursor_pos.x)
      Gui.SetCursorPosY(old_cursor_pos.y)
    end
    
    -- end
    Gui.SetCursorPosY(begin_cursor.y + 64 + 64)
  end
end

Hud.ShowComputerInfo = function(id)
  current_window = "Computer"
  computer_id = id
  --if Hud.IsTrayVisible() == true then
  --  Hud.HideTray()
  --end
end

Hud.SetTooltip = function(tip)
  Gui.PushFont(Gameplay.font)
  if Gui.IsItemHovered() then
    Hud.ShowTooltip(tip)
  end
  Gui.PopFont()
end

Hud.ShowTooltip = function(tip)
  Gui.PushStyleColor(GuiStyle.Colors.PopupBg, Math.Color(32, 29, 29, 220))
  Gui.PushStyleVector2f(GuiStyle.Var.WindowPadding, Math.Vector2f(20, 10))
  Gui.PushStyleVector2f(GuiStyle.Var.FramePadding, Math.Vector2f(20, 10))
  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 8)

  Gui.BeginTooltip()
    Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. tip)
  Gui.EndTooltip()

  Gui.PopStyleVar(3)
  Gui.PopStyleColor(1)
end

local GenerateString = function(l)
  local str = ""

  for i = 0, l do
    local char = math.random(48, 122)
    while char == 96 do
      char = math.random(48, 122)
    end

    str = str .. string.char(char)
  end

  return str
end

-- hiring
local hackers_to_hire_list = {}

Hud.RerollHireList = function()
  hackers_to_hire_list = {}

  local num_to_generate = math.random(1, 3)

  for i = 0, num_to_generate do
    hackers_to_hire_list[#hackers_to_hire_list + 1] = Gameplay.GenerateHacker(Game.Data.GetHacker(0).level, 1, 2)
  end
end

Hud.ShowHireWindow = function()
  local window_size = Renderer.GetWindowSize()

  -- background
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 128))
  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 0)
  
  Gui.SetNextWindowSize(window_size.x, window_size.y)
  Gui.SetNextWindowPos(0, 0)

  Gui.BeginFlags("HiringWindowBackground", GuiStyle.WindowFlags.NoTitleBar .. 
                                           GuiStyle.WindowFlags.NoResize ..
                                           GuiStyle.WindowFlags.NoMove ..
                                           GuiStyle.WindowFlags.NoCollapse ..
                                           GuiStyle.WindowFlags.NoScrollbar .. 
                                           GuiStyle.WindowFlags.NoSavedSettings)
           
  Gui.End()

  Gui.PopStyleVar(1)
  Gui.PopStyleColor(1)

  -- content
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 222))
  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)

  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 8.0)
  Gui.PushStyleFloat(GuiStyle.Var.FrameRounding, 8.0)

  Gui.SetNextWindowSize(720, 460)
  Gui.SetNextWindowPos(math.ceil((window_size.x - 720.0) / 2.0),
                       math.ceil((window_size.y - 460.0) / 2.0))

  Gui.SetNextWindowFocus()

  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.5, 0.5))

  Gui.BeginFlags("Hire people", --GuiStyle.WindowFlags.NoTitleBar .. 
                                  GuiStyle.WindowFlags.NoResize ..
                                  GuiStyle.WindowFlags.NoMove ..
                                  GuiStyle.WindowFlags.NoCollapse ..
                                  GuiStyle.WindowFlags.NoScrollbar ..
                                  --GuiStyle.WindowFlags.ShowBorders ..
                                  GuiStyle.WindowFlags.NoSavedSettings)
    
    Gui.BeginChild("ListOfPeople", Math.Vector2f(0, -48), false)

      if #hackers_to_hire_list == 0 then
        Gui.TextExpandedCentered(Gui.ColorToString(HudPalette.Red) .. "Nothing here, you need atleast $100.", "vh")
      end

      for i = 1, #hackers_to_hire_list do
        if hackers_to_hire_list[i] ~= nil then
          local begin_pos = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY() + 6)

          -- avatar
          Gui.Image("./assets/graphics/avatars/" .. hackers_to_hire_list[i].skin_id .. ".png", Math.Vector2f(128, 128), Math.FloatRect(0, 0, 12, 12))

          -- stats
          Gui.SetCursorPosY(begin_pos.y)

          local start_x = 150

          -- name
          Gui.SetCursorPosX(start_x)

          Gui.Image("./assets/graphics/gui/name.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
          Hud.SetTooltip("Name")

          Gui.SameLine(0, 16)
          Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hackers_to_hire_list[i].name)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

          -- cracking
          Gui.SetCursorPosX(start_x)
          Gui.SetCursorPosY(begin_pos.y + 33)

          Gui.Image("./assets/graphics/gui/cracking.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
          Hud.SetTooltip("Cracking")

          Gui.SameLine(0, 16)
          Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hackers_to_hire_list[i].cracking)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

          -- security
          Gui.SetCursorPosX(start_x)

          Gui.Image("./assets/graphics/gui/security.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
          Hud.SetTooltip("Security")

          Gui.SameLine(0, 16)
          Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hackers_to_hire_list[i].security)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

          -- level
          Gui.SetCursorPosX(start_x)

          Gui.Image("./assets/graphics/gui/level.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
          Hud.SetTooltip("Level")

          Gui.SameLine(0, 16)
          Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hackers_to_hire_list[i].level)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)

          -- salary
          Gui.SetCursorPosX(start_x + 96)
          Gui.SetCursorPosY(begin_pos.y + 33)

          Gui.Image("./assets/graphics/gui/salary.png", Math.Vector2f(16, 16), Math.FloatRect(0, 0, 16, 16))
          Hud.SetTooltip("Salary")

          Gui.SameLine(0, 16)
          Gui.SetCursorPosY(Gui.GetCursorPosY() - 2)
          Gui.TextExpanded(Gui.ColorToString(HudPalette.White) .. hackers_to_hire_list[i].salary)

          Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
          
          -- hire button
          Gui.SetCursorPosX(start_x + 96)

          Gui.PushID("hire " .. i)
          if Gui.ImageButton("./assets/graphics/gui/stat_add.png", Math.Vector2f(32, 32)) then
            Game.Data.PushHacker(hackers_to_hire_list[i])
            hackers_to_hire_list[i] = nil
          end
          Gui.PopID()
          Hud.SetTooltip("Hire")

          Gui.SetCursorPosY(begin_pos.y + 128 + 8)
        end
      end

    Gui.EndChild()

    Gui.SetCursorPosY(Gui.GetCursorPosY() + 8)
    if Gui.Button("Close", Math.Vector2f(120, 32)) then
      show_hire_window = false
    end

    if Game.Data.money >= 100 then
      Gui.SameLine(0, 16)
      if Gui.Button("Reroll ($100)", Math.Vector2f(120, 32)) then
        Hud.RerollHireList()
        Game.Data.money = Game.Data.money - 100
      end  
    end
  Gui.End()

  Gui.PopStyleColor(2)
  Gui.PopStyleVar(2)
end

-- draw messages
Hud.DrawMessages = function()
  local window_size = Renderer.GetWindowSize()

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 160))
  Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))

  Gui.SetNextWindowSize(window_size.x, window_size.y)
  Gui.SetNextWindowPos(0, 0)
  Gui.BeginFlags("MessagesBackground", GuiStyle.WindowFlags.NoTitleBar .. 
                                       GuiStyle.WindowFlags.NoResize ..
                                       GuiStyle.WindowFlags.NoMove ..
                                       GuiStyle.WindowFlags.NoCollapse ..
                                       GuiStyle.WindowFlags.NoScrollbar ..
                                       --GuiStyle.WindowFlags.ShowBorders ..
                                       GuiStyle.WindowFlags.NoSavedSettings)
  Gui.End()
  
  Gui.PopStyleColor(2) 

  -- message
  local msg = Messages.msg[#Messages.msg]

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(7, 7, 7, 200))
  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)
  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 8)
  Gui.PushStyleFloat(GuiStyle.Var.FrameRounding, 8)

  Gui.SetNextWindowSize(512, 320)
  Gui.SetNextWindowPos(math.ceil((window_size.x - 512.0) / 2.0),
                       math.ceil((window_size.y - 300.0) / 2.0))

  Gui.SetNextWindowFocus()

  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.5, 0.5))

  Gui.BeginFlags(msg.from, --GuiStyle.WindowFlags.NoTitleBar .. 
                           GuiStyle.WindowFlags.NoResize ..
                           GuiStyle.WindowFlags.NoMove ..
                           GuiStyle.WindowFlags.NoCollapse ..
                           GuiStyle.WindowFlags.NoScrollbar ..
                           --GuiStyle.WindowFlags.ShowBorders ..
                           GuiStyle.WindowFlags.NoSavedSettings)

    Gui.Image("./assets/graphics/avatars/" .. msg.avatarid .. ".png", Math.Vector2f(48, 48), Math.FloatRect(0, 0, 12, 12))
    Gui.SameLine(0, 12)

    local cursor_next_to_avatar = Math.Vector2f(Gui.GetCursorPosX(), Gui.GetCursorPosY())

    Gui.TextExpanded(Gui.ColorToString(HudPalette.Yellow) .. "From: " .. Gui.ColorToString(HudPalette.White) .. msg.from)

    Gui.SetCursorPosX(cursor_next_to_avatar.x)
    Gui.SetCursorPosY(cursor_next_to_avatar.y + 16)
    Gui.TextExpanded(Gui.ColorToString(HudPalette.Yellow) .. "Title: " .. Gui.ColorToString(HudPalette.White) .. msg.title)

    Gui.SetCursorPosY(90)

    -- content
    Gui.BeginChild("MessageContent", Math.Vector2f(0, -36), false)
      Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)
      Gui.TextWrapped(msg.content)
      Gui.PopStyleColor(1)
    Gui.EndChild()

    -- replies/close button
    Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))
    if msg.replies then
      local pressed = false

      if msg.replies.yes then
        local button_width = math.floor(Gui.GetWindowWidth() / 2 - 12)
        if msg.replies.no == nil then
          Gui.SetCursorPosX(math.floor(Gui.GetWindowWidth() / 2.0 - button_width / 2.0))
        end

        if Gui.Button(msg.replies.yes.msg,
                      Math.Vector2f(button_width, 32)) then
          if msg.replies.yes.func ~= nil then
            msg.replies.yes.func()
          else
            Console.Log("ERROR: replies.yes.func == nil")
          end
          pressed = true
        end
      end
      
      if msg.replies.no then
        local button_width = math.floor(Gui.GetWindowWidth() / 2 - 12)
        if msg.replies.yes == nil then
          Gui.SetCursorPosX(math.floor(Gui.GetWindowWidth() / 2.0 - button_width / 2.0))
        else
          Gui.SameLine(0, 8)
        end

        if Gui.Button(msg.replies.no.msg, Math.Vector2f(button_width, 32)) then
          msg.replies.no.func()
          pressed = true
        end
      end

      if pressed == true then
        msg.replies = nil
        -- close and remove message
        Messages.msg[#Messages.msg] = nil
      end
    else
      local button_width = math.floor(Gui.GetWindowWidth() / 2 - 12)
      Gui.SetCursorPosX(math.floor(Gui.GetWindowWidth() / 2.0 - button_width / 2.0))

      if Gui.Button("Close", Math.Vector2f(button_width, 32)) then
        Messages.msg[#Messages.msg] = nil
      end
    end
    Gui.PopStyleColor(1)

  Gui.End()

  Gui.PopStyleColor(2)
  Gui.PopStyleVar(2)
end

-- notifications
Hud.DrawNotification = function()
  local window_size = Renderer.GetWindowSize()

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 160))
  Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))

  Gui.SetNextWindowSize(window_size.x, window_size.y)
  Gui.SetNextWindowPos(0, 0)
  Gui.BeginFlags("NotificationBG", GuiStyle.WindowFlags.NoTitleBar .. 
                                 GuiStyle.WindowFlags.NoResize ..
                                 GuiStyle.WindowFlags.NoMove ..
                                 GuiStyle.WindowFlags.NoCollapse ..
                                 GuiStyle.WindowFlags.NoScrollbar ..
                                 GuiStyle.WindowFlags.ShowBorders ..
                                 GuiStyle.WindowFlags.NoSavedSettings)
  Gui.End()
  
  Gui.PopStyleColor(2)

  -- notification
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(7, 7, 7, 200))
  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)

  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 8.0)
  Gui.PushStyleFloat(GuiStyle.Var.FrameRounding, 8.0)

  Gui.SetNextWindowSize(512, 320)
  Gui.SetNextWindowPos(math.ceil((window_size.x - 512.0) / 2.0),
                       math.ceil((window_size.y - 300.0) / 2.0))

  Gui.SetNextWindowFocus()

  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.5, 0.5))

  Gui.BeginFlags(notifications[#notifications].title, GuiStyle.WindowFlags.NoResize ..
                                                      GuiStyle.WindowFlags.NoMove ..
                                                      GuiStyle.WindowFlags.NoCollapse ..
                                                      GuiStyle.WindowFlags.NoScrollbar ..
                                                      --GuiStyle.WindowFlags.ShowBorders ..
                                                      GuiStyle.WindowFlags.NoSavedSettings)

    Gui.BeginChild("NotificationContent", Math.Vector2f(0, -48), false)

      Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)

      Gui.TextWrapped(notifications[#notifications].message)

      Gui.PopStyleColor(1)

    Gui.EndChild()

    Gui.SetCursorPosX(Gui.GetWindowWidth() / 2.0 - 128)
    Gui.SetCursorPosY(Gui.GetWindowHeight() - 32 - 12)
  
    local button = "Close"

    if notifications[#notifications].button then
      button = notifications[#notifications].button
    end

    Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))
    
    if Gui.Button(button, Math.Vector2f(256, 32)) then
      notifications[#notifications] = nil
    end
    
    Gui.PopStyleColor(1)

  Gui.End()

  Gui.PopStyleColor(2)
  Gui.PopStyleVar(2)
end

Hud.AddNotification = function(title, message, button)
  if title == nil or message == nil or button == nil then
    return
  end

  notifications[#notifications + 1] = {}
  notifications[#notifications].title = title
  notifications[#notifications].message = message
  notifications[#notifications].button = button
end

Hud.ClearNotifications = function()
  notifications = {}
end

Hud.IsNotification = function()
  if #notifications > 0 then
    return true
  end
  return false
end

Hud.SetConfirmation = function(title, message, confirmed_action)
  confirmation = {}
  confirmation.title = title
  confirmation.message = message
  confirmation.confirmed_action = confirmed_action
end

Hud.ShowConfirmation = function()
  if confirmation == nil then
    return
  end

  local window_size = Renderer.GetWindowSize()

  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(0, 0, 0, 160))
  Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))

  Gui.SetNextWindowSize(window_size.x, window_size.y)
  Gui.SetNextWindowPos(0, 0)
  Gui.BeginFlags("ConfirmationBG", GuiStyle.WindowFlags.NoTitleBar .. 
                                 GuiStyle.WindowFlags.NoResize ..
                                 GuiStyle.WindowFlags.NoMove ..
                                 GuiStyle.WindowFlags.NoCollapse ..
                                 GuiStyle.WindowFlags.NoScrollbar ..
                                 GuiStyle.WindowFlags.ShowBorders ..
                                 GuiStyle.WindowFlags.NoSavedSettings)
  Gui.End()
  
  Gui.PopStyleColor(2)

  -- notification
  Gui.PushStyleColor(GuiStyle.Colors.WindowBg, Math.Color(7, 7, 7, 200))
  Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)

  Gui.PushStyleFloat(GuiStyle.Var.WindowRounding, 8.0)
  Gui.PushStyleFloat(GuiStyle.Var.FrameRounding, 8.0)

  Gui.SetNextWindowSize(512, 320)
  Gui.SetNextWindowPos(math.ceil((window_size.x - 512.0) / 2.0),
                       math.ceil((window_size.y - 300.0) / 2.0))

  Gui.SetNextWindowFocus()

  Gui.SetStyleVector2f(GuiStyle.Var.WindowTitleAlign, Math.Vector2f(0.5, 0.5))

  Gui.BeginFlags(confirmation.title, GuiStyle.WindowFlags.NoResize ..
                                    GuiStyle.WindowFlags.NoMove ..
                                    GuiStyle.WindowFlags.NoCollapse ..
                                    GuiStyle.WindowFlags.NoScrollbar ..
                                  --GuiStyle.WindowFlags.ShowBorders ..
                                    GuiStyle.WindowFlags.NoSavedSettings)

    Gui.BeginChild("ConfirmationContent", Math.Vector2f(0, -48), false)

      Gui.PushStyleColor(GuiStyle.Colors.Text, HudPalette.White)

      Gui.TextWrapped(confirmation.message)

      Gui.PopStyleColor(1)

    Gui.EndChild()

    Gui.SetCursorPosX(Gui.GetWindowWidth() / 2.0 - 128)
    Gui.SetCursorPosY(Gui.GetWindowHeight() - 32 - 12)
  
    Gui.PushStyleColor(GuiStyle.Colors.Border, Math.Color(0, 0, 0, 0))
    
    if Gui.Button("Yes", Math.Vector2f(128, 32)) then
      if confirmation.confirmed_action ~= nil then
        confirmation.confirmed_action()
      end
      confirmation = nil
    end
    Gui.SameLine(0, -1)

    if Gui.Button("No", Math.Vector2f(128, 32)) then
      confirmation = nil
    end
    
    Gui.PopStyleColor(1)

  Gui.End()

  Gui.PopStyleColor(2)
  Gui.PopStyleVar(2)
end

Hud.IsConfirmation = function()
  if confirmation == nil then
    return false
  else 
    return true 
  end
end

