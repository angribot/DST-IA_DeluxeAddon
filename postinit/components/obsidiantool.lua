GLOBAL.setfenv(1, GLOBAL)

local function getAnimSuffix(self, percentage)
	if percentage >= self.red_threshold then
		return "_red"
	elseif percentage >= self.orange_threshold then
		return "_orange"
	elseif percentage >= self.yellow_threshold then
		return "_yellow"
	else
		return ""
	end
end

local ObsidianTool = require("components/obsidiantool")
local on_change_delta = ObsidianTool.OnChargeDelta
function ObsidianTool:OnChargeDelta(...)
	on_change_delta(self, ...)
	local skin_build = self.inst:GetSkinBuild()
	local equipper = self.inst.components.equippable
		and self.inst.components.equippable:IsEquipped()
		and self.inst.components.inventoryitem
		and self.inst.components.inventoryitem:GetGrandOwner()
	local suffix = getAnimSuffix(self, self.charge / self.maxcharge)
	self.inst.components.floater:UpdateAnimations((skin_build and "spear_water" or "idle_water") .. suffix, "idle" .. suffix)
	if equipper then
		equipper.AnimState:OverrideSymbol("swap_object", skin_build or "swap_" .. self.tool_type .. "_obsidian", "swap_" .. self.tool_type .. suffix)
	end
end
