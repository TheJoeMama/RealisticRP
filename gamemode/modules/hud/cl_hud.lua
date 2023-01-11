local hide = {
	["CHudAmmo"] = true,
	["CHudBattery"] = true,
	["CHudCrosshair"] = true,
	["CHudDamageIndicator"] = true,
	["CHudGeiger"] = true,
	["CHudHealth"] = true,
	["CHudMenu"] = true,
	["CHudMessage"] = true,
	["CHudPoisonDamageIndicator"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudSquadStatus"] = true,
	["CHudVehicle"] = true,
	["CHudWeapon"] = true,
	["CHudZoom"] = true,
	["CHudSuitPower"] = true,
	["CHUDQuickInfo"] = true,
}

hook.Add( "HUDShouldDraw", "RealisticRP:HideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end
end )

local flashalpha = 0
hook.Add("EntityFireBullets", "RealisticRP:Bullets", function(ent)
    if IsValid(ent) and LocalPlayer() == ent and ( ent:KeyDown(IN_ATTACK) or ent:KeyDown(IN_ATTACK2)) then
        flashalpha = 200
    end
end)

local black = Color(0,0,0,255)
local flash = Color(255,155,0)
hook.Add("HUDPaint", "RealisticRP:HUD", function()
    local scrw,scrh = ScrW(),ScrH()
    if flashalpha > 1 then
        surface.SetDrawColor(0,0,0,flashalpha)
        surface.DrawRect(0, 0, scrw, scrh)
        flashalpha = Lerp(FrameTime() * 5, flashalpha, 0)
    end
end)

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.025,
	["$pp_colour_contrast"] = 0.975,
	["$pp_colour_colour"] = 0.9,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
hook.Add("RenderScreenspaceEffects", "RealisticRP:Shader", function()
	DrawColorModify( tab ) --Draws Color Modify effect
end )

hook.Add( "CalcView", "RealisticRP:MyCalcView", function( ply, pos, angles, fov )
	local view = {
		origin = pos,
		angles = angles,
		fov = fov,
		drawviewer = false
	}

    view.angles = Angle(angles.p + math.abs(math.sin(CurTime() * 1)) + ( math.sin(-CurTime() * 15) * ply:GetVelocity():Length() / 400 * 1), angles.y + ( math.sin(-CurTime() * 10) * ply:GetVelocity():Length() / 400 * 2), angles.r)

    if ply:KeyDown(IN_MOVELEFT) then
        view.angles.r = view.angles.r - 1
        view.angles.p = view.angles.p - 1
    elseif ply:KeyDown(IN_MOVERIGHT) then
        view.angles.r = view.angles.r + 1
        view.angles.p = view.angles.p + 1
    end

	return view
end )