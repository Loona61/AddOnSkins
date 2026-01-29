local AS = unpack(AddOnSkins)
if not AS:CheckAddOn('Details') then return end

local ES = AS.EmbedSystem

local _G = _G
local select, type = select, type
local wipe, tinsert  = wipe, tinsert

local Details
local NumberToEmbed

ES.DetailsInstances = {}

local function GetDetailsBaseFrame(window)
	if not window then
		return nil
	end

	return window.baseframe or window.base_frame or window.frame
end

function ES:DetailsWindow(window, width, height, point, relativeFrame, relativePoint, ofsx, ofsy)
	if not window then return end

	local baseframe = GetDetailsBaseFrame(window)
	if not baseframe then
		return
	end

	if (not window:IsEnabled()) then
		window:EnableInstance()
	end

	window._ElvUIEmbed = true

	if window.bars_grow_direction == 2 then
		ofsy = -2
	else
		ofsy = -20
	end

	window:UngroupInstance()

	baseframe:ClearAllPoints()
	baseframe:SetParent(relativeFrame)
	baseframe:SetFrameStrata(relativeFrame:GetFrameStrata())
	baseframe:SetFrameLevel(relativeFrame:GetFrameLevel())

	ofsx = ofsx - 1

	if window.show_statusbar then
		height = height - 13
	end

	if (window.skin == "Forced Square") then
		ofsx = ofsx - 1
		if (window:GetId() == 2) then
			window:SetSize(width + 1, height - 20)
		else
			window:SetSize(width, height - 20)
		end
	elseif (window.skin == "ElvUI Frame Style") then
		if (window:GetId() == 2) then
			window:SetSize(width - 1, height - 20)
		else
			if NumberToEmbed == 1 then
				window:SetSize(width - 2, height - 20)
			else
				window:SetSize(width, height - 20)
			end
		end
	elseif (window.skin == "ElvUI Style II") then
		if (window:GetId() == 2) then
			window:SetSize(width, height - 20)
		else
			if NumberToEmbed == 1 then
				window:SetSize(width - 2, height - 20)
			else
				window:SetSize(width - 1, height - 20)
			end
		end
	else
		window:SetSize(width, height - 20)
	end

	baseframe:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
	window:SaveMainWindowPosition()
	window:RestoreMainWindowPosition()

	window:LockInstance(true)

	if (window:GetId() == 2) then
		window:MakeInstanceGroup({1})
	end

	local windowId = window:GetId()
	if windowId == 1 or windowId == 2 then
		local switchFrame = _G["Details_SwitchButtonFrame"..windowId]
		if switchFrame then
			switchFrame:SetParent(baseframe)
			switchFrame:SetFrameLevel(baseframe:GetFrameLevel() + 3)
		end

		local rowFrame = _G["DetailsRowFrame"..windowId]
		if rowFrame then
			rowFrame:SetParent(baseframe)
			rowFrame:SetFrameLevel(baseframe:GetFrameLevel() + 2)
		end
	end
end

function ES:Details()
	if not Details then
		Details = _G._detalhes
	end

	if not Details then
		return
	end

	if Details.CreateEventListener then
		local listener = Details:CreateEventListener()
		listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
		listener:RegisterEvent("DETAILS_INSTANCE_CLOSE")

		function listener:OnDetailsEvent(event, ...)
			if (event == "DETAILS_INSTANCE_CLOSE") then
				local instance = select(1, ...)
				if (instance and instance._ElvUIEmbed and _G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
					Details:Msg("You just closed a window Embed on ElvUI, if wasn't intended click on Reopen.") --> need localization
				end
			elseif (event == "DETAILS_INSTANCE_OPEN") then
				local instance = select(1, ...)
				if (instance and instance._ElvUIEmbed) then
					if (#ES.DetailsInstances >= 2) then
						ES.DetailsInstances[1]:UngroupInstance()
						ES.DetailsInstances[2]:UngroupInstance()

						local baseframe1 = GetDetailsBaseFrame(ES.DetailsInstances[1])
						local baseframe2 = GetDetailsBaseFrame(ES.DetailsInstances[2])
						if baseframe1 then
							baseframe1:ClearAllPoints()
						end
						if baseframe2 then
							baseframe2:ClearAllPoints()
						end

						ES.DetailsInstances[1]:RestoreMainWindowPosition()
						ES.DetailsInstances[2]:RestoreMainWindowPosition()

						ES.DetailsInstances[2]:MakeInstanceGroup({1})
					end
				end
			end
		end
	end

	wipe(ES.DetailsInstances)

	if Details.ListInstances then
		for _, instance in Details:ListInstances() do
			tinsert(ES.DetailsInstances, instance)
		end
	end

	NumberToEmbed = 0
	if AS:CheckOption('EmbedSystem') then
		NumberToEmbed = 1
	elseif AS:CheckOption('EmbedSystemDual') then
		if AS:CheckOption('EmbedRight') == 'Details' then NumberToEmbed = NumberToEmbed + 1 end
		if AS:CheckOption('EmbedLeft') == 'Details' then NumberToEmbed = NumberToEmbed + 1 end
	end

	if Details.GetMaxInstancesAmount and Details.SetMaxInstancesAmount then
		if (Details:GetMaxInstancesAmount() < NumberToEmbed) then
			Details:SetMaxInstancesAmount(NumberToEmbed)
		end
	end

	local instances_amount = Details.GetNumInstancesAmount and Details:GetNumInstancesAmount() or 0

	for i = instances_amount + 1, NumberToEmbed do
		if not Details.CreateInstance then
			break
		end

		local new_instance = Details:CreateInstance(i)

		if (type(new_instance) == "table") then
			tinsert(ES.DetailsInstances, new_instance)
		end
	end

	if NumberToEmbed == 1 then
		local EmbedParent = ES.Main
		if AS:CheckOption('EmbedSystemDual') then
			EmbedParent = AS:CheckOption('EmbedRight') == 'Details' and ES.Right or ES.Left
		end
		ES:DetailsWindow(ES.DetailsInstances[1], EmbedParent:GetWidth(), EmbedParent:GetHeight(), 'TOPLEFT', EmbedParent, 'TOPLEFT', 2, 0)

		if (ES.DetailsInstances[2]) then
			ES.DetailsInstances[2]._ElvUIEmbed = nil
		end
	elseif NumberToEmbed == 2 then
		ES:DetailsWindow(ES.DetailsInstances[1], ES.Left:GetWidth(), ES.Left:GetHeight(), 'TOPLEFT', ES.Left, 'TOPLEFT', 2, 0)
		ES:DetailsWindow(ES.DetailsInstances[2], ES.Right:GetWidth(), ES.Right:GetHeight(), 'TOPRIGHT', ES.Right, 'TOPRIGHT', -2, 0)
	end
end
