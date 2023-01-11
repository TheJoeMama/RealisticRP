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

surface.CreateFont( "joinscreen", {
	font = "Arial",
	extended = false,
	size = ScrW() * 0.0125,
} )
local frame 
function TessaGameMode:JoinScreen()
    if IsValid(frame) then frame:Remove() end
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

    local hide = {
        ["CHudHealth"] = true,
        ["CHudBattery"] = true
    }
    hook.Add( "HUDShouldDraw", "TessaGameMode:JoinHUD", function( name ) -- remove when final hud is done
        if ( hide[ name ] ) then
            return false
        end
    end )

    local col1 = Color(80, 80, 80, 255)
    local col2 = Color(255, 255, 255, 255)
    local col3 = Color(40, 40, 40, 245)
    local col4 = Color(40, 40, 40, 255)
    local logo = Material("tessa/logolarge.png")
    frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:Center()
    --frame:SetBackgroundBlur(true)
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame.Paint = function(s,w,h) 
        surface.SetDrawColor(col3)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(logo)
        surface.DrawTexturedRect(ScrW() * 0.5 - ( ScrW() * 0.57 / 2 ), 0, ScrW() * 0.57, ScrH() * 0.53)
    end

    local button = vgui.Create("DButton", frame)
    button:SetSize(ScrW() * 0.1, ScrH() * 0.05)
    button:Center()
    button:SetText("")
    button:MakePopup()
    button.Paint = function(s,w,h)
        if s:IsHovered() then
            surface.SetDrawColor(col4)
        else
            surface.SetDrawColor(col1)
        end
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Click to start playing", "joinscreen", ScrW() * 0.05, ScrH() * 0.0225, col2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    button.OnCursorEntered = function()
        LocalPlayer():EmitSound("tessa/hover.wav")
    end
    button.DoClick = function()
        LocalPlayer():EmitSound("tessa/click.wav")
        frame:Remove()
        hook.Remove("CalcView", "TessaGameMode:CameraView")
        hook.Remove("HUDShouldDraw", "TessaGameMode:JoinHUD")
    end
end