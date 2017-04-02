AbodeGraphics = {}

local home_clouds = {}
local home_room_visibility = 0.0
local home_room_showing = false

AbodeGraphics.Init = function(id)
  if id == nil then
    return
  end
  
  if id == 0 then
    AbodeGraphics.HomeInit()
  elseif id == 1 then
    AbodeGraphics.GarageInit()
  elseif id == 2 then
    AbodeGraphics.FakeChurchInit()
  end
end

AbodeGraphics.Draw = function(id)
  if id == 0 then
    AbodeGraphics.Home()
  elseif id == 1 then
    AbodeGraphics.Garage()
  elseif id == 2 then
    AbodeGraphics.FakeChurch()
  end
end

AbodeGraphics.HomeInit = function()
  local cloud = {}
  cloud.speed = 20
  cloud.x = 12
  cloud.y = 45
  cloud.scale = 1

  home_clouds[#home_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 16
  cloud.x = -12
  cloud.y = 55
  cloud.scale = 0.75
  home_clouds[#home_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 14
  cloud.x = 180
  cloud.y = 65
  cloud.scale = 0.55
  home_clouds[#home_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 20
  cloud.x = 140
  cloud.y = 79
  cloud.scale = 1
  home_clouds[#home_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 17
  cloud.x = -59
  cloud.y = 95
  cloud.scale = 0.8
  home_clouds[#home_clouds + 1] = cloud

  home_room_showing = true
end

AbodeGraphics.Home = function()
  Renderer.Draw(0, "sky",
                "./assets/graphics/abodes/home/sky.png", Math.Color(255, 255, 255, 255),
                Math.IntRect(0, 0, 320, 180),
                Math.Vector2f(0, 0),
                Math.Vector2f(1, 1), "default")


  for i = 1, #home_clouds do
    if home_clouds[i] ~= nil then
      home_clouds[i].x = (home_clouds[i].x + (Time.delta_time * home_clouds[i].speed))

      Renderer.Draw(1, "cloud_" .. i,
                  "./assets/graphics/abodes/home/cloud.png", Math.Color(255, 255, 255, 255),
                  Math.IntRect(0, 0, 56, 18),
                  Math.Vector2f(home_clouds[i].x, home_clouds[i].y),
                  Math.Vector2f(home_clouds[i].scale, home_clouds[i].scale), "default")

      if home_clouds[i].x > 320 then
        home_clouds[i] = {}
        home_clouds[i].scale = math.random(5, 10) / 10.0
        home_clouds[i].speed = 22 * home_clouds[i].scale
        home_clouds[i].x = math.random(-70, -60)
        home_clouds[i].y = math.random(16, 90)
      end
    end
  end

  Renderer.Draw(2, "base",
              "./assets/graphics/abodes/home/base.png", Math.Color(255, 255, 255, 255),
              Math.IntRect(0, 0, 320, 180),
              Math.Vector2f(0, 0),
              Math.Vector2f(1, 1), "default")

  if home_room_showing == true then
    home_room_visibility = home_room_visibility + (Time.delta_time * 2.0)
    if home_room_visibility > 1.0 then
      home_room_visibility = 1.0
      home_room_showing = false
    end
  end

  Renderer.Draw(2, "room",
              "./assets/graphics/abodes/home/room.png", Math.Color(255, 255, 255, math.ceil(home_room_visibility * 255)),
              Math.IntRect(0, 0, 320, 180),
              Math.Vector2f(0, 0),
              Math.Vector2f(1, 1), "default")
end

AbodeGraphics.GarageInit = function()

end

AbodeGraphics.Garage = function()
  Renderer.Draw(0, "sky_garage",
                "./assets/graphics/abodes/garage/sky.png", Math.Color(255, 255, 255, 255),
                Math.IntRect(0, 0, 320, 180),
                Math.Vector2f(0, 0),
                Math.Vector2f(1, 1), "default")
  
  -- TODO: change that to use proper variables
  --[[for i = 1, #home_clouds do
    if home_clouds[i] ~= nil then
      home_clouds[i].x = (home_clouds[i].x + (Time.delta_time * home_clouds[i].speed))

      Renderer.Draw(1, "cloud_" .. i,
                  "./assets/graphics/abodes/home/cloud.png", Math.Color(255, 255, 255, 255),
                  Math.IntRect(0, 0, 56, 18),
                  Math.Vector2f(home_clouds[i].x, home_clouds[i].y),
                  Math.Vector2f(home_clouds[i].scale, home_clouds[i].scale), "default")

      if home_clouds[i].x > 320 then
        home_clouds[i] = {}
        home_clouds[i].scale = math.random(5, 10) / 10.0
        home_clouds[i].speed = 22 * home_clouds[i].scale
        home_clouds[i].x = math.random(-70, -60)
        home_clouds[i].y = math.random(16, 90)
      end
    end
  end]]--

  Renderer.Draw(2, "base_garage",
              "./assets/graphics/abodes/garage/base.png", Math.Color(255, 255, 255, 255),
              Math.IntRect(0, 0, 320, 180),
              Math.Vector2f(0, 0),
              Math.Vector2f(1, 1), "default")
end

local church_clouds = {}

AbodeGraphics.FakeChurchInit = function()
  local cloud = {}
  cloud.speed = 12
  cloud.x = 12
  cloud.y = 45
  cloud.id = 0
  cloud.scale = 1

  church_clouds[#church_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 13
  cloud.x = -12
  cloud.y = 55
  cloud.scale = 0.75
  cloud.id = 0
  church_clouds[#church_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 7
  cloud.x = 180
  cloud.y = 65
  cloud.scale = 0.55
  cloud.id = 1
  church_clouds[#church_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 12
  cloud.x = 140
  cloud.y = 79
  cloud.scale = 1
  cloud.id = 0
  church_clouds[#church_clouds + 1] = cloud

  cloud = {}
  cloud.speed = 10
  cloud.x = -59
  cloud.y = 95
  cloud.scale = 0.8
  cloud.id = 1
  church_clouds[#church_clouds + 1] = cloud
end

AbodeGraphics.FakeChurch = function()
  for i = 1, #church_clouds do
    if church_clouds[i] ~= nil then
      church_clouds[i].x = (church_clouds[i].x + (Time.delta_time * church_clouds[i].speed))

      Renderer.Draw(1, "cloud_" .. i,
                  "./assets/graphics/abodes/fakechurch/cloud_" .. church_clouds[i].id .. ".png", Math.Color(255, 255, 255, 255),
                  Math.IntRect(0, 0, 41, 12),
                  Math.Vector2f(church_clouds[i].x, church_clouds[i].y),
                  Math.Vector2f(church_clouds[i].scale, church_clouds[i].scale), "default")

      if church_clouds[i].x > 320 then
        church_clouds[i] = {}
        church_clouds[i].scale = math.random(5, 10) / 10.0
        church_clouds[i].speed = 7 * church_clouds[i].scale
        church_clouds[i].x = math.random(-70, -60)
        church_clouds[i].y = math.random(16, 90)
        church_clouds[i].id = math.random(0, 2)
      end
    end
  end

  Renderer.Draw(0, "sky_skyscraper",
                "./assets/graphics/abodes/fakechurch/sky.png", Math.Color(255, 255, 255, 255),
                Math.IntRect(0, 0, 320, 180),
                Math.Vector2f(0, 0),
                Math.Vector2f(1, 1), "default")

  Renderer.Draw(2, "base_skyscraper",
              "./assets/graphics/abodes/fakechurch/base.png", Math.Color(255, 255, 255, 255),
              Math.IntRect(0, 0, 320, 180),
              Math.Vector2f(0, 0),
              Math.Vector2f(1, 1), "default")
end

