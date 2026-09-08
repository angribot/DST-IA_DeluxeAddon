local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local BUFF_DURATIONS = {
	buff_caffeine = TUNING.FOOD_SPEED_LONG,
	buff_purple_grouper = TUNING.FOOD_SPEED_AVERAGE,
	buff_pierrot_fish = TUNING.FOOD_SPEED_AVERAGE,
	buff_tropicalbouillabaisse = TUNING.FOOD_SPEED_MED,
}

local function with_civi_duration(base_fn, default_duration, attaching)
	return function(inst, target, followsymbol, followoffset, data, ...)
		if target and target.prefab == "civi" then
			local buff_data = shallowcopy(data or {})
			-- Saved timers are restored before attachment. Do not multiply their remaining time again.
			local remaining = attaching and inst.components.timer:GetTimeLeft("buffover") or nil
			buff_data.duration = remaining or ((buff_data.duration or default_duration) * (1 + (target.level or 0) * 0.25))
			data = buff_data
		end

		-- Let IA apply the same duration to its timer and locomotor effects, including refresh rules.
		return base_fn(inst, target, followsymbol, followoffset, data, ...)
	end
end

local function buff_postinit(inst)
	if not TheWorld.ismastersim then
		return
	end

	-- NightStories only hooks buffs whose timers already exist during prefab postinit.
	-- These IA buffs start their timers on attachment, so they need their own adapter.
	local debuff = inst.components.debuff
	local duration = BUFF_DURATIONS[inst.prefab]
	debuff:SetAttachedFn(with_civi_duration(debuff.onattachedfn, duration, true))
	debuff:SetExtendedFn(with_civi_duration(debuff.onextendedfn, duration, false))
end

for prefab in pairs(BUFF_DURATIONS) do
	AddPrefabPostInit(prefab, buff_postinit)
end
