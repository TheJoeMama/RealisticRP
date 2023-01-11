----------------------------------------------------- SQL
function TessaGameMode:InitiliazeCharacterSQL()
    if sql.TableExists("tessa_char") then return end
    sql.Query([[CREATE TABLE tessa_char (
        slot varchar(255) NOT NULL,
        steamid varchar(255) NOT NULL,
        name varchar(255),
        faction varchar(255),
        money varchar(255),
        CONSTRAINT char PRIMARY KEY (slot,steamid)
    )]])
end
TessaGameMode:InitiliazeCharacterSQL()

function TessaGameMode:LoadSQLData(steamid, slot)
    if slot then
        local result = sql.Query("SELECT * from tessa_char WHERE steamid = " .. sql.SQLStr(steamid) .. " AND slot = " .. sql.SQLStr(slot) .. " ")
        return result or {}
    else
        local result = sql.Query("SELECT * from tessa_char WHERE steamid = " .. sql.SQLStr(steamid) .. " ")
        return result or {}
    end
end

function TessaGameMode:SaveSQLData(steamid, slot)
    sql.Query("INSERT OR REPLACE INTO tessa_char (slot,steamid,name,faction,money) VALUES(" .. sql.SQLStr(slot) .. ", " .. sql.SQLStr(steamid) .. ", " .. sql.SQLStr("test") .. ",  " .. sql.SQLStr(1) .. ", " .. sql.SQLStr(200) .." ) ")
end

-----------------------------------------------------------------------------------
