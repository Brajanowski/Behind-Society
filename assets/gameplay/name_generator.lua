local female_names = {}
local male_names = {}
local surnames = {}

NameGenerator = {}

NameGenerator.Init = function()
  for line in io.lines("./assets/dictionaries/names_female.txt") do
    female_names[#female_names + 1] = line
  end

  for line in io.lines("./assets/dictionaries/names_male.txt") do
    male_names[#male_names + 1] = line
  end

  for line in io.lines("./assets/dictionaries/surnames.txt") do
    surnames[#surnames + 1] = line
  end
end

NameGenerator.GenerateMale = function()
  local name = male_names[math.random(#male_names)] .. " " ..
               surnames[math.random(#surnames)]
  return name
end

NameGenerator.GenerateFemale = function()
  local name = female_names[math.random(#female_names)] .. " " ..
               surnames[math.random(#surnames)]
  return name
end

