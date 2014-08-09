-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

local cams = {}

function CAddonTemplateGameMode:InitGameMode()
	print('LoZ started!')

	local gameEnt = GameRules:GetGameModeEntity()
	gameEnt:SetThink( "OnThink", self, "GlobalThink", 2 )

	-- Disable FOW
	gameEnt:SetFogOfWarDisabled(true)

	-- Fix camera height
	gameEnt:SetCameraDistanceOverride(1250)

	-- Set times up
	GameRules:SetHeroSelectionTime(30.0)
	GameRules:SetPreGameTime(0.0)
end

local snapWidth = 2048
local snapHeight = 1408
local camOffsetY = 200

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()


	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- Loop over all players
		for i=0,9 do
			-- Grab their hero, and check if it's valid
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			if IsValidEntity(hero) then
				-- Grab the position of their hero, and adjust it to a grid
				local pos = hero:GetOrigin()
				pos.x = math.floor(pos.x/snapWidth)*snapWidth + snapWidth/2
				pos.y = math.floor(pos.y/snapHeight)*snapHeight + snapHeight/2 - camOffsetY

				-- Has our origin changed?
				if IsValidEntity(cams[i]) and cams[i]:GetOrigin() ~= pos then
					cams[i]:Kill()
				end

				if not IsValidEntity(cams[i]) then
					cams[i] = Entities:CreateByClassname('info_target')
					cams[i]:SetOrigin(pos)
					PlayerResource:SetCameraTarget(i, cams[i])
				end
			end
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 0.1
end