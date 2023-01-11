GM.Name = "RealisticRP"
GM.Author = "Joe"
GM.Email = ""
GM.Website = ""
DeriveGamemode( "sandbox" )
RealisticRP = {}
RealisticRP.Config = RealisticRP.Config or {}

local mainfolder = GM.FolderName .. "/gamemode/modules/"
local configfolder = GM.FolderName .. "/gamemode/config/"

local function loadfiles(startfolder, folder)
    if folder then
        folder = startfolder .. folder .. "/"
    else
        folder = startfolder
    end
    -- sv files
    if SERVER then
        for k,v in SortedPairs(file.Find(folder .. "sv_*", "LUA")) do
            include(folder .. tostring(v))
        end
    end
    -- sh files
    for k,v in SortedPairs(file.Find(folder .. "sh_*", "LUA")) do
        include(folder .. tostring(v))
        if SERVER then AddCSLuaFile(folder .. tostring(v)) end
    end
    -- cl files
    for k,v in SortedPairs(file.Find(folder .. "cl_*", "LUA")) do
        if SERVER then AddCSLuaFile(folder ..  tostring(v))
        else include(folder .. tostring(v))
        end
    end
end

---------------------[MODULES]

local _,direcs = file.Find(mainfolder .. "*", "LUA")

loadfiles(mainfolder) -- for files outside of folders

for _,folders in SortedPairs(direcs) do -- for the module system
    loadfiles(mainfolder, folders)
end

---------------------[Configs]

local _,direcs = file.Find(configfolder .. "*", "LUA")

loadfiles(mainfolder) -- for files outside of folders

for _,folders in SortedPairs(direcs) do -- for the module system
    loadfiles(mainfolder, folders)
end