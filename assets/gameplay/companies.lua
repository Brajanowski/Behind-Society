Companies = {}
Companies.shops_prefix = {}
Companies.shops_postfix = {}
Companies.insurance_prefix = {}
Companies.insurance_postfix = {}
Companies.social_prefix = {}
Companies.social_postfix = {}
Companies.factory_prefix = {}
Companies.factory_postfix = {}

Companies.Min = 6
Companies.Max = 30

local day_of_new_company = 0

Companies.Init = function()
  -- shops
  for line in io.lines("./assets/dictionaries/companies_shops_prefix.txt") do
    Companies.shops_prefix[#Companies.shops_prefix + 1] = line
  end

  for line in io.lines("./assets/dictionaries/companies_shops_postfix.txt") do
    Companies.shops_postfix[#Companies.shops_postfix + 1] = line
  end

  -- insurance
  for line in io.lines("./assets/dictionaries/companies_insurance_prefix.txt") do
    Companies.insurance_prefix[#Companies.insurance_prefix + 1] = line
  end

  for line in io.lines("./assets/dictionaries/companies_insurance_postfix.txt") do
    Companies.insurance_postfix[#Companies.insurance_postfix + 1] = line
  end

  -- social
  for line in io.lines("./assets/dictionaries/companies_social_prefix.txt") do
    Companies.social_prefix[#Companies.social_prefix + 1] = line
  end

  for line in io.lines("./assets/dictionaries/companies_social_postfix.txt") do
    Companies.social_postfix[#Companies.social_postfix + 1] = line
  end

  -- factories
  for line in io.lines("./assets/dictionaries/companies_factory_prefix.txt") do
    Companies.factory_prefix[#Companies.factory_prefix + 1] = line
  end

  for line in io.lines("./assets/dictionaries/companies_factory_postfix.txt") do
    Companies.factory_postfix[#Companies.factory_postfix + 1] = line
  end

  day_of_new_company = math.random(3, 10)
end

Companies.NextDay = function()
  if Game.Data.GetCompaniesNumber() >= Companies.Max then
    if day_of_new_company <= Game.Data.day then
      day_of_new_company = Game.Data.day + math.random(5, 10)

      local company = Companies.CreateCompany()
      Hud.AddNotification("Company debut", "Today a new company debuts!\n\nAnd it will be called " .. company.name, "Ok")
    end
  end

  Companies.Update()
end

Companies.Update = function()
  Companies.CreateNextDayEvents()
  
  for i = 0, Game.Data.GetCompaniesNumber() - 1 do
    local company = Game.Data.GetCompany(i)

    if company.type ~= CompanyType.Story then
      if company.break_time > 0 then
        local popularity_lost = 0
        
        if math.floor(company.popularity * 0.6) > 10 then 
          popularity_lost = math.random(math.floor(company.popularity * 0.6))
          company.popularity = company.popularity - popularity_lost
          company.break_time = company.break_time - 1
        else
          Game.Data.RemoveCompany(i)
          Gameplay.CompanyRemoved(i)
        end
      end
    end
  end

  if Game.Data.GetCompaniesNumber() < Companies.Min then
    local how_much_is_missing = Companies.Min - Game.Data.GetCompaniesNumber()
    for i = 0, how_much_is_missing do
      Companies.CreateCompany()
    end
  end
end

Companies.CreateNextDayEvents = function()
  if Game.Data.GetCompaniesNumber() == 0 then
    return
  end

  for i = 0, math.random(1, 2) do
    local which_company = math.random(0, Game.Data.GetCompaniesNumber() - 1)
    local company = Game.Data.GetCompany(which_company)
    
    if company.type ~= CompanyType.Story then
      if company.break_time == 0 then
        -- 60% for good event, %40 for bad
        local good_or_bad = math.random(0, 100)

        if good_or_bad > 60 then -- good
          company.popularity = company.popularity + math.random(5, 20)
          company.people_love = company.people_love + math.random(1, 2)
        else -- bad
          company.people_love = company.people_love - math.random(1, 3)
        end
      end
    end
  end
end

Companies.CreateCompany = function()
  local company_type = math.random(0, CompanyType.MaxTypes - 1)
  local company = Game.Company(Companies.GenerateName(company_type))
  company.popularity = math.random(20, 40)
  company.type = company_type

  local which_computer_company = math.random(0, 1)

  local current_generation = 0

  if which_computer_company == 0 then
    current_generation = Game.Data.blue_company_generation
  else
    local current_generation = Game.Data.blue_company_generation
  end

  company.security = math.random(current_generation * 8, current_generation * 12)

  company.people_love = 50 + math.random(-10, 10)
  Game.Data.PushCompany(company)
  return company
end

Companies.GenerateStarting = function()
  for i = 0, math.random(Companies.Min, Companies.Min + 2) do
    local company_type = math.random(0, CompanyType.MaxTypes - 1)
    local company = Game.Company(Companies.GenerateName(company_type))
    company.popularity = math.random(20, 40)
    company.security = math.random(3, 6)
    company.type = company_type
    company.people_love = 50 + math.random(-10, 10)
    Game.Data.PushCompany(company)
  end
end

Companies.Hacked = function(companyid)
  local company = Game.Data.GetCompany(companyid)
  company.break_time = math.random(1, 4)
end

Companies.GenerateName = function(company_type)
  local name = ""

  if company_type == CompanyType.Shop then
    name = Companies.shops_prefix[math.random(#Companies.shops_prefix)] .. " " .. Companies.shops_postfix[math.random(#Companies.shops_postfix)]
  elseif company_type == CompanyType.Insurance then
    name = Companies.insurance_prefix[math.random(#Companies.insurance_prefix)] .. " " .. Companies.insurance_postfix[math.random(#Companies.insurance_postfix)]
  elseif company_type == CompanyType.SocialNetwork then
    name = Companies.social_prefix[math.random(#Companies.social_prefix)] .. " " .. Companies.social_postfix[math.random(#Companies.social_postfix)]
  elseif company_type == CompanyType.Factory then
    name = Companies.factory_prefix[math.random(#Companies.factory_prefix)] .. " " .. Companies.factory_postfix[math.random(#Companies.factory_postfix)]
  else
    name = "undefined"
  end

  return name
end

Companies.OnNewGeneration = function(generation)
  for i = 0, Game.Data.GetCompaniesNumber() - 1 do
    local company = Game.Data.GetCompany(i)

    -- 50% chance
    if math.random(0, 100) > 50 then
      company.security = generation * 3 + math.random(0, 4)
      
      for j = 0, Game.Data.GetTaskNumber() - 1 do
        local task = Game.Data.GetTask(i)

        if task.company_id == i then
          task.points_to_finish = task.points_to_finish + (generation * 2) + math.random(0, 2)
        end
      end
    end
  end
end
