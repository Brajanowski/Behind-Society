CompanyType = {}

CompanyType.Shop          = 0
CompanyType.SocialNetwork = 1
CompanyType.Insurance     = 2
CompanyType.Factory       = 3
CompanyType.MaxTypes      = 4
CompanyType.Story         = 5

CompanyType.ToString = function(company_type) 
  if company_type == CompanyType.Shop then
    return "Shop"
  elseif company_type == CompanyType.SocialNetwork then
    return "Social Network"
  elseif company_type == CompanyType.Insurance then
    return "Insurance"
  elseif company_type == CompanyType.Factory then
    return "Factory"
  elseif company_type == CompanyType.Story then
    return "Part of story"
  else
    return "unknown"
  end
end

CompanyType.GetIconPathByType = function(company_type)
  local path = "./assets/graphics/gui/"

  if company_type == CompanyType.Shop then
    path = path .. "shop.png"
  elseif company_type == CompanyType.SocialNetwork then
    path = path .. "social_network.png"
  elseif company_type == CompanyType.Insurance then
    path = path .. "insurance.png"
  elseif company_type == CompanyType.Factory then
    path = path .. "factory.png"
  elseif company_type == CompanyType.Story then
    path = path .. "story.png"
  end
  
  return path
end

