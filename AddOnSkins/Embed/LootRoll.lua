local AS, L, S, R = unpack(AddOnSkins)
local ES = AS.EmbedSystem

local _G = _G
local LoadAddOn = LoadAddOn

local function GetEmbedParent()
	if AS:CheckOption('EmbedSystemDual') then
		return AS:CheckOption('EmbedRight') == 'LootRoll' and ES.Right or ES.Left
	end

	return ES.Main
end

local function PositionGroupLootHistoryFrame(embedParent)
	local frame = _G.GroupLootHistoryFrame
	if not frame then return end

	frame:SetParent(embedParent)
	frame:SetFrameStrata(embedParent:GetFrameStrata())
	frame:SetFrameLevel(AS:CheckOption('EmbedFrameLevel'))
	frame:ClearAllPoints()
	frame:SetPoint('TOPLEFT', embedParent, 'TOPLEFT', 0, 0)
	frame:SetPoint('BOTTOMRIGHT', embedParent, 'BOTTOMRIGHT', 0, 0)
end

local function PositionGroupLootFrames(embedParent)
	local numFrames = _G.NUM_GROUP_LOOT_FRAMES or 4
	local previousFrame

	for i = 1, numFrames do
		local frame = _G['GroupLootFrame'..i]
		if frame then
			frame:SetParent(embedParent)
			frame:SetFrameStrata(embedParent:GetFrameStrata())
			frame:SetFrameLevel(AS:CheckOption('EmbedFrameLevel'))
			frame:ClearAllPoints()

			if previousFrame then
				frame:SetPoint('TOP', previousFrame, 'BOTTOM', 0, -2)
			else
				frame:SetPoint('TOP', embedParent, 'TOP', 0, -2)
			end

			previousFrame = frame
		end
	end
end

local function PositionGroupLootContainer(embedParent)
	local container = _G.GroupLootContainer
	if not container then return end

	container:SetParent(embedParent)
	container:SetFrameStrata(embedParent:GetFrameStrata())
	container:SetFrameLevel(AS:CheckOption('EmbedFrameLevel'))
	container:ClearAllPoints()
	container:SetPoint('TOPLEFT', embedParent, 'TOPLEFT', 0, 0)
	container:SetPoint('BOTTOMRIGHT', embedParent, 'BOTTOMRIGHT', 0, 0)
end

local function UpdateLootRollPosition()
	local embedParent = GetEmbedParent()

	if _G.GroupLootHistoryFrame then
		PositionGroupLootHistoryFrame(embedParent)
	elseif _G.GroupLootContainer then
		PositionGroupLootContainer(embedParent)
	else
		PositionGroupLootFrames(embedParent)
	end
end

function ES:LootRoll()
	if not _G.GroupLootHistoryFrame and not _G.GroupLootContainer and not _G.GroupLootFrame1 and LoadAddOn then
		pcall(LoadAddOn, 'Blizzard_LootFrames')
	end

	UpdateLootRollPosition()

	if not ES.LootRollHooked then
		ES.LootRollHooked = true

		if _G.GroupLootHistoryFrame then
			_G.GroupLootHistoryFrame:HookScript('OnShow', UpdateLootRollPosition)
		end

		if _G.GroupLootContainer then
			_G.GroupLootContainer:HookScript('OnShow', UpdateLootRollPosition)
		end

		local numFrames = _G.NUM_GROUP_LOOT_FRAMES or 4
		for i = 1, numFrames do
			local frame = _G['GroupLootFrame'..i]
			if frame then
				frame:HookScript('OnShow', UpdateLootRollPosition)
			end
		end
	end
end
