util.AddNetworkString("tessa_chardata")
util.AddNetworkString("tessa_request_chardata")
util.AddNetworkString("tessa_request_selectchar")
util.AddNetworkString("tessa_request_createchar")
util.AddNetworkString("tessa_request_deletechar")


function TessaGameMode:SetCharacter(ply,slot)
    local data = self:LoadSQLData(ply:SteamID64(), slot)

    ply.name = data[1].name
    ply.char = tonumber(data[1].slot)
    ply.faction = tonumber(data[1].faction)
    ply.factionname = TessaGameMode.Factions[ply.faction].name
    ply.money = tonumber(data[1].money)
    
    net.Start("tessa_chardata")
    net.WriteEntity(ply)
    net.WriteTable(data)
    net.Broadcast()

    ply:Spawn()
end

function TessaGameMode:GetAllCharacterData(ply)
    for k,v in ipairs(player.GetHumans()) do
        if not IsValid(v) then continue end
        if v == ply then continue end
        if not v.char then continue end
        local data = {
            [1] = {
                name = v.name,
                char = v.slot,
                faction = v.faction,
                money = v.money
            }
        }
        
        net.Start("tessa_chardata")
        net.WriteEntity(v)
        net.WriteTable(data)
        net.Send(ply)
    end
end

net.Receive("tessa_chardata", function(_, ply) 
    TessaGameMode:GetAllCharacterData(ply) 
end)

net.Receive("tessa_request_chardata", function(_, ply)
    local data = TessaGameMode:LoadSQLData(ply:SteamID64())
    for k,v in pairs(data) do
        data[k] = nil
        data[tonumber(v.slot)] = v
    end
    net.Start("tessa_request_chardata")
    net.WriteTable(data)
    net.Send(ply)
end)

net.Receive("tessa_request_selectchar", function(_, ply)
    local slot = net.ReadInt(32)
    TessaGameMode:SetCharacter(ply, slot)
end)

net.Receive("tessa_request_deletechar", function(_, ply)
    local slot = net.ReadInt(32)
    if ply.char and ply.char == slot then return end
    sql.Query("DELETE from tessa_char WHERE steamid = " .. sql.SQLStr(ply:SteamID64()) .. " AND slot = " .. sql.SQLStr(slot) .. " ")
end)