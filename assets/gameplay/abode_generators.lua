AbodeGenerator = {}

AbodeGenerator.Generate = function(abode_level)
  if abode_level == 0 then
    Game.Data.ClearAbodes()
    local abode = Game.Abode("Home")

    abode:SetTile(12, 7, Game.Tile(0, TileType.Floor))
    abode:SetTile(13, 7, Game.Tile(0, TileType.Floor))
    return abode
  elseif abode_level == 1 then
    Game.Data.ClearAbodes()
    
    local abode = Game.Abode("Garage")

    abode:SetTile(4, 10, Game.Tile(0, TileType.Floor))
    abode:SetTile(5, 10, Game.Tile(0, TileType.Floor))
    abode:SetTile(6, 10, Game.Tile(0, TileType.Floor))
    abode:SetTile(7, 10, Game.Tile(0, TileType.Floor))
    abode:SetTile(8, 10, Game.Tile(0, TileType.Floor))
    return abode
  elseif abode_level == 2 then
    Game.Data.ClearAbodes()

    local abode = Game.Abode("Fake church")

    abode:SetTile(6, 9, Game.Tile(0, TileType.Floor))
    abode:SetTile(7, 9, Game.Tile(0, TileType.Floor))
    abode:SetTile(8, 9, Game.Tile(0, TileType.Floor))
    abode:SetTile(9, 9, Game.Tile(0, TileType.Floor))
    abode:SetTile(10, 9, Game.Tile(0, TileType.Floor))
    abode:SetTile(11, 9, Game.Tile(0, TileType.Floor))
    abode:SetTile(12, 9, Game.Tile(0, TileType.Floor))
    abode:SetTile(13, 9, Game.Tile(0, TileType.Floor))
    return abode
  end

  return nil
end
