function IMPULSE:OnSchemaLoaded()
	if not impulse.MainMenu and not IsValid(impulse.MainMenu) then
		vgui.Create("impulseSplash")
	end
end

function IMPULSE:Think()
	if input.IsKeyDown(KEY_F1) and not IsValid(impulse.MainMenu) then
		local mainMenu = vgui.Create("impulseMainMenu")
		mainMenu:SetAlpha(0)
		mainMenu:AlphaTo(255, .3)
		mainMenu.popup = true
	end
end

function IMPULSE:ScoreboardShow()
    impulse_scoreboard = vgui.Create("impulseScoreboard")
end

function IMPULSE:ScoreboardHide()
    impulse_scoreboard:Remove()
end

function IMPULSE:DefineSettings()
	impulse.DefineSetting("hud_vignette", {name="Vignette enabled", category="HUD", type="tickbox", default=true})
end

local loweredAngles = Angle(30, -30, -25)

function IMPULSE:CalcViewModelView(weapon, viewmodel, oldEyePos, oldEyeAng, eyePos, eyeAngles)
	if not IsValid(weapon) then return end

	local vm_origin, vm_angles = eyePos, eyeAngles

	do
		local lp = LocalPlayer()
		local raiseTarg = 0

		if !lp:IsWeaponRaised() then
			raiseTarg = 100
		end

		local frac = (lp.raiseFraction or 0) / 100
		local rot = weapon.LowerAngles or loweredAngles

		vm_angles:RotateAroundAxis(vm_angles:Up(), rot.p * frac)
		vm_angles:RotateAroundAxis(vm_angles:Forward(), rot.y * frac)
		vm_angles:RotateAroundAxis(vm_angles:Right(), rot.r * frac)

		lp.raiseFraction = Lerp(FrameTime() * 2, lp.raiseFraction or 0, raiseTarg)
	end

	--The original code of the hook.
	do
		local func = weapon.GetViewModelPosition
		if (func) then
			local pos, ang = func( weapon, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end

		func = weapon.CalcViewModelView
		if (func) then
			local pos, ang = func( weapon, viewModel, oldEyePos*1, oldEyeAngles*1, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end
	end

	return vm_origin, vm_angles
end