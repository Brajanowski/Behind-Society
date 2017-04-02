ComputerStore = {}
ComputerStore.computers = {}

ComputerStore.Generate = function()
  -- FIXME: ITS TEMP SOLUTION
  for key, value in pairs(ComputerStore.computers) do
    ComputerStore.computers[key] = nil
  end

  -- red company:

  local max_generation = math.max(Game.Data.red_company_generation, Game.Data.blue_company_generation)

  for i = 1, max_generation do
    if Game.Data.red_company_generation >= max_generation then
      ComputerStore.AddComputer(0, i)
    end

    if Game.Data.blue_company_generation >= max_generation then
      ComputerStore.AddComputer(1, i)
    end
  end
end

ComputerStore.AddComputer = function(company, generation)
  local computer = Game.Computer()
  computer.company = company
  computer.generation = generation
  computer.upgrade_level = 0
  ComputerStore.computers[#ComputerStore.computers + 1] = computer
end

ComputerStore.NextDay = function()
  Game.Data.red_company_tech_points =
    Game.Data.red_company_tech_points + math.random(5, 15)
  Game.Data.blue_company_tech_points =
    Game.Data.blue_company_tech_points + math.random(5, 15)

  local need_to_generate = false

  if Game.Data.red_company_tech_points >= 100 and Game.Data.red_company_generation < GameConfig.MAX_COMPUTER_GENERATION then
    Game.Data.red_company_tech_points = 0
    Game.Data.red_company_generation = Game.Data.red_company_generation + 1
    need_to_generate = true

    Companies.OnNewGeneration(Game.Data.red_company_generation)

    Hud.AddNotification("Red company presents", "Red company announcing a new generation of their computers! It's faster, more portable and more beautiful!\nPrices starts at $" .. Gameplay.GetGenerationCost(Game.Data.red_company_generation), "Ok")
  end
  
  if Game.Data.blue_company_tech_points >= 100 and Game.Data.blue_company_generation < GameConfig.MAX_COMPUTER_GENERATION then
    Game.Data.blue_company_tech_points = 0
    Game.Data.blue_company_generation = Game.Data.blue_company_generation + 1
    need_to_generate = true

    Hud.AddNotification("Blue company presents", "A blue company presents:\n\nNext-gen personal computer. It's more stable, faster and more reliable.\n\nPrices starts at $" .. Gameplay.GetGenerationCost(Game.Data.blue_company_generation), "Ok")
  end

  if need_to_generate then
    ComputerStore.Generate()
  end
end

