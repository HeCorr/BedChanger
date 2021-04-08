G_Plugin = nil

function Initialize(Plugin)
	Plugin:SetName("BedChanger")
	Plugin:SetVersion(1)

	G_Plugin = Plugin

	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_USING_BLOCK, OnPlayerUsingBlock);

	LOG(Plugin:GetName() .. " v." .. Plugin:GetVersion() .. " up and running!")
	return true
end

function OnDisable()
	LOG(G_Plugin:GetName() .. " is shutting down...")
end

function OnPlayerUsingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ, BlockType, BlockMeta)
	if BlockType == 26 then -- bed
		LOG(BlockMeta)
		local item = Player:GetEquippedItem()
		if item.m_ItemType == 35 then -- wool
			if not Player:HasPermission('bedchanger.change') then
				Player:SendMessage("[Bed Changer] You don't have permissions to change your bed color!")
				return true
			end
			local changed = Player:GetWorld():DoWithBedAt(BlockX, BlockY, BlockZ, function (bed)
				bed:SetColor(item.m_ItemDamage)
				-- this monstrosity fixes only half of the bed being updated
				if BlockMeta == 3 or BlockMeta == 9 then
					Player:GetWorld():DoWithBedAt(BlockX+1, BlockY, BlockZ, function (bed)
						bed:SetColor(item.m_ItemDamage)
					end)
				end
				if BlockMeta == 1 or BlockMeta == 11 then
					Player:GetWorld():DoWithBedAt(BlockX-1, BlockY, BlockZ, function (bed)
						bed:SetColor(item.m_ItemDamage)
					end)
				end
				if BlockMeta == 0 or BlockMeta == 10 then
					Player:GetWorld():DoWithBedAt(BlockX, BlockY, BlockZ+1, function (bed)
						bed:SetColor(item.m_ItemDamage)
					end)
				end
				if BlockMeta == 2 or BlockMeta == 8 then
					Player:GetWorld():DoWithBedAt(BlockX, BlockY, BlockZ-1, function (bed)
						bed:SetColor(item.m_ItemDamage)
					end)
				end
				return true
			end)
			if changed then
				Player:GetInventory():RemoveOneEquippedItem()
				Player:SendMessage("[Bed Changer] Bed color changed!")
			end
			return true
		end
	end
end
