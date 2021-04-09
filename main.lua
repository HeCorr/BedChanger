G_Plugin = nil

function Initialize(Plugin)
	Plugin:SetName("BedChanger")
	Plugin:SetVersion(1)

	G_Plugin = Plugin

	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_USING_BLOCK, OnPlayerUsingBlock);

	LOG(Plugin:GetName() .. " v" .. Plugin:GetVersion() .. " up and running!")
	return true
end

function OnDisable()
	LOG(G_Plugin:GetName() .. " is shutting down...")
end

function OnPlayerUsingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ, BlockType, BlockMeta)
	if BlockType == 26 then -- bed
		local item = Player:GetEquippedItem()
		if item.m_ItemType == 35 then -- wool
			if not Player:HasPermission('bedchanger.change') then
				Player:SendMessage("[Bed Changer] You don't have permission to change your bed color!")
				return true
			end
			local changed = Player:GetWorld():DoWithBedAt(BlockX, BlockY, BlockZ, function (bed)
				bed:SetColor(item.m_ItemDamage)
				-- this is a workaround for updating the other half of the bed
				-- since SetColor() only updates a single block.
				local nextX = BlockX
				local nextZ = BlockZ
				if BlockMeta == 3 or BlockMeta == 9 then
					nextX = nextX + 1
				elseif BlockMeta == 1 or BlockMeta == 11 then
					nextX = nextX - 1
				elseif BlockMeta == 0 or BlockMeta == 10 then
					nextZ = nextZ + 1
				elseif BlockMeta == 2 or BlockMeta == 8 then
					nextZ = nextZ - 1
				end
				Player:GetWorld():DoWithBedAt(nextX, BlockY, nextZ, function (bed)
					bed:SetColor(item.m_ItemDamage)
				end)
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
