net.Receive("tessa_chardata", function()
    local ply = net.ReadEntity()
    local data = net.ReadTable()

    ply.name = data[1].name
    ply.char = tonumber(data[1].slot)
    ply.faction = tonumber(data[1].faction)
    ply.factionname = TessaGameMode.Factions[ply.faction].name
    ply.money = tonumber(data[1].money)
end)




--------------------------------------------------------------------------------[ UI ]-------------------------------------------------
surface.CreateFont( "CharacterText1", {
	font = "Arial",
	extended = false,
	size = ScrW() * 0.04,
} )

surface.CreateFont( "CharacterText2", {
	font = "Arial",
	extended = false,
	size = ScrW() * 0.0125,
} )

surface.CreateFont( "CharacterText3", {
	font = "Arial",
	extended = false,
	size = ScrW() * 0.1,
} )

local camerapos = {
    {
        vec = Vector(-1470.070435, -226.375641, -12735.968750),
        ang = Angle(21.780, -290, 0.000)
    },
    {
        vec = Vector(465.788269, -1232.442261, -12721.906250),
        ang = Angle(73.755, 18.084, 0.000)
    },
}

local anims = {
    "pose_standing_01",
    "pose_standing_02",
    "pose_ducking_01",
}

local frame1
local chardata = {}
local col1 = Color(80, 80, 80, 255)
local col2 = Color(255, 255, 255, 255)
local col3 = Color(40, 40, 40, 245)
local col4 = Color(40, 40, 40, 255)
local logo = Material("tessa/logolarge.png")
local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true
}


net.Receive("tessa_request_chardata", function() chardata = net.ReadTable() TessaGameMode:CharacterSelectionMenu() end)
function TessaGameMode:CharacterSelectionMenu()
    
    if IsValid(frame1) then frame1:Remove() end
    
    local curselect = 0
    local cld = 0
    hook.Add("CalcView", "TessaGameMode:CameraView", function( ply, pos, angles, fov )
        if cld < CurTime() then 
            curselect = curselect + 1 <= #camerapos and curselect + 1 or 1
            cld = CurTime() + 5
        end


        local view = {
            origin = camerapos[curselect].vec,
            angles = camerapos[curselect].ang,
            fov = fov,
            drawviewer = true
        }

        return view
    end )

    hook.Add( "HUDShouldDraw", "TessaGameMode:JoinHUD", function( name ) -- remove when final hud is done
        if ( hide[ name ] ) then
            return false
        end
    end )

    frame1 = vgui.Create("DFrame")
    frame1:SetSize(ScrW(), ScrH())
    frame1:Center()
    frame1:SetTitle("")
    frame1:ShowCloseButton(false)
    frame1.Paint = function(s,w,h) 
        surface.SetDrawColor(col3) -- blur
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(logo)
        surface.DrawTexturedRect(ScrW() * -0.045, ScrH() * -0.08, ScrW() * 0.57 / 2, ScrH() * 0.53 / 2)

        draw.SimpleText("Choose your Character", "CharacterText1", ScrW() * 0.5, ScrH() * 0.2, col2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(color_white)
        surface.DrawRect(ScrW() * 0.3, ScrH() * 0.24, ScrW() * 0.4, ScrH() * 0.01)

    end

    local selected = false
    local charselects = {}
    local infoframe = vgui.Create("DFrame", frame1)
    infoframe:SetVisible(false)
    infoframe:SetPos(0,0)
    infoframe:SetTitle("")
    infoframe:ShowCloseButton(false)
    infoframe:SetSize(ScrW() * 0.1, ScrH() * 0.25)
    infoframe.Paint = function(s, w, h)
        surface.SetDrawColor(col1)
        surface.DrawRect(0, 0, w, h)
        if not infoframe.selected then return end
        draw.SimpleText("Name: " .. chardata[infoframe.selected].name, "CharacterText2", ScrW() * 0, ScrH() * 0, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Faction: " .. TessaGameMode.Factions[tonumber(chardata[infoframe.selected].faction)].name or "LOADING", "CharacterText2", ScrW() * 0, ScrH() * 0.1, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Money: " .. chardata[infoframe.selected].money, "CharacterText2", ScrW() * 0, ScrH() * 0.15, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    end
    
    for i=1,3 do
        if chardata[i] then
            local pose = table.Random(anims)
            local character = vgui.Create("DModelPanel", frame1)
            character:SetSize(ScrW() * 0.15, ScrH() * 0.5)
            character:SetPos(i == 1 and ScrW() * 0.175 or  ScrW() * (0.175 + 0.250 * (i - 1) ), ScrH() * 0.3)
            character:SetModel("models/player/swat.mdl")
            character.selected = false
            character.LayoutEntity = function(s, ent)
                ent:SetSequence(pose)
                character:RunAnimation()
            end
            character.DoClick = function(s)
                s.selected = true
                selected = i
                for _,v in ipairs(charselects) do
                    if v == character then continue end
                    v:SetAmbientLight(color_white)
                    v.selected = false
                end
                character:SetAmbientLight(Color(255, 0, 0, 255))
                LocalPlayer():EmitSound("tessa/click.wav")
            end
            character.OnCursorEntered = function(s)
                infoframe:SetVisible(true)
                infoframe.selected = i
                local x,y = character:GetPos()
                infoframe:SetPos(x + ScrW() * 0.125,y + ScrH() * 0.1)

                LocalPlayer():EmitSound("tessa/hover.wav")

                if s.selected then return end
                character:SetAmbientLight(Color(0, 255, 0, 255))
            end
            character.OnCursorExited = function(s)
                infoframe:SetVisible(false)
                infoframe:SetPos(0,0)
                infoframe.selected = nil

                if s.selected then return end
                character:SetAmbientLight(color_white)
            end
            local ent = character.Entity
            local _,modelbounds = ent:GetModelRenderBounds()
            character:SetLookAt( Vector(0,0, modelbounds.z / 2 ) )
            character:SetLookAng(Angle(0,-180,0))
            character:SetCamPos( Vector(modelbounds.z / 2,0, modelbounds.z / 2 ) )
            character.Entity:SetEyeTarget(  character:GetCamPos() )

            table.insert(charselects, character)
        else
            local character_add = vgui.Create("DButton", frame1)
            character_add:SetSize(ScrW() * 0.15, ScrH() * 0.5)
            character_add:SetPos(i == 1 and ScrW() * 0.175 or  ScrW() * (0.175 + 0.250 * (i - 1) ), ScrH() * 0.3)
            character_add:SetText("")
            character_add.Paint = function(s, w, h)
                surface.SetDrawColor(col1)
                surface.DrawRect(ScrW() * 0.05, ScrH() * 0.2, w - ScrW() * 0.05 * 2, h - ScrH() * 0.4)
                draw.SimpleText("+", "CharacterText3", ScrW() * 0.075, ScrH() * 0.25, col2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            character_add.DoClick = function()
                frame1:Remove()
                TessaGameMode:CharacterCreationMenu()
            end
        end
    end


    local button = vgui.Create("DButton", frame1)
    button:SetSize(ScrW() * 0.1, ScrH() * 0.05)
    button:SetPos(ScrW() * 0.375, ScrH() * 0.9)
    button:SetText("")
    button:MakePopup()
    button.Paint = function(s,w,h)
        if s:IsHovered() and selected then
            surface.SetDrawColor(col4)
        else
            surface.SetDrawColor(col1)
        end
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("SELECT", "CharacterText2", ScrW() * 0.05, ScrH() * 0.0225, col2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    button.OnCursorEntered = function()
        LocalPlayer():EmitSound("tessa/hover.wav")
    end
    button.DoClick = function()
        if not selected then return end
        LocalPlayer():EmitSound("tessa/click.wav")

        net.Start("tessa_request_selectchar")
        net.WriteInt(selected, 32)
        net.SendToServer()

        frame1:Remove()
        hook.Remove("CalcView", "TessaGameMode:CameraView")
        hook.Remove("HUDShouldDraw", "TessaGameMode:JoinHUD")
    end

    local button = vgui.Create("DButton", frame1)
    button:SetSize(ScrW() * 0.1, ScrH() * 0.05)
    button:SetPos(ScrW() * 0.525, ScrH() * 0.9)
    button:SetText("")
    button:MakePopup()
    button.Paint = function(s,w,h)
        if s:IsHovered() and selected then
            surface.SetDrawColor(col4)
        else
            surface.SetDrawColor(col1)
        end
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("DELETE", "CharacterText2", ScrW() * 0.05, ScrH() * 0.0225, col2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    button.OnCursorEntered = function()
        LocalPlayer():EmitSound("tessa/hover.wav")
    end
    button.DoClick = function()
        if not selected then return end
        LocalPlayer():EmitSound("tessa/click.wav")

        net.Start("tessa_request_deletechar")
        net.WriteInt(selected, 32)
        net.SendToServer()

        frame1:Remove()
        hook.Remove("CalcView", "TessaGameMode:CameraView")
        hook.Remove("HUDShouldDraw", "TessaGameMode:JoinHUD")

        net.Start("tessa_request_chardata")
        net.SendToServer()
    end

end

--net.Start("tessa_request_chardata")
--net.SendToServer()

local frame2
function TessaGameMode:CharacterCreationMenu()
    if IsValid(frame2) then frame2:Remove() end
    
end