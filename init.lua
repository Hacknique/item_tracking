item_tracking = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath .. "/src/track.lua")

-- logging functions
function log(level, text) minetest.log(level, "[item_tracking]:\t" .. text) end

function err(text) log("error", text) end

function warn(text) log("warning", text) end

function act(text) log("action", text) end

function info(text) log("info", text) end

function verbose(text) log("verbose", text) end

function is_inventory_empty(inv)
    local lists = inv:get_lists()
    for listname, list in pairs(lists) do
        if not inv:is_empty(listname) then
            return false -- At least one list is not empty
        end
    end
    return true -- All lists are empty
end

function override_detached_inventory(inventory_name, on_put, on_move)
    core.detached_inventories[inventory_name].on_put = on_put
    core.detached_inventories[inventory_name].on_move = on_move
    verbose("Overriding detached inventory: " .. inventory_name)
end

function item_tracking.register_tracker(item, node_callbacks,
                                        detached_callbacks, player_callbacks)
    minetest.register_on_mods_loaded(function()
        verbose("Detached Callbacks: " .. minetest.serialize(detached_callbacks))

        verbose("Node Callbacks: " .. minetest.serialize(node_callbacks))

        verbose("Player Callbacks: " .. minetest.serialize(player_callbacks))

        -- Override all storage nodes if callbacks are provided
        if node_callbacks then
            for name, def in pairs(minetest.registered_nodes) do
                if def.on_metadata_inventory_put or
                    def.on_metadata_inventory_move then
                    track_node(item, name, node_callbacks.on_put,
                               node_callbacks.on_move)
                end
            end
        end
        -- Override all detached inventories if callbacks are provided
        if detached_callbacks then
            act("Detached callbacks provided")

            for name, _ in pairs(core.detached_inventories) do
                track_detached(item, name, detached_callbacks.on_put,
                               detached_callbacks.on_move)
            end
        end

        -- Track all players if callback is provided
        if player_callbacks then
            act("register_tracker: Item Meta" .. minetest.serialize(item.meta))
            track_player(item, player_callbacks.on_put, player_callbacks.on_move)
        end
    end)
end

function item_tracking.track_attached_inventory(item, on_change)

    local node_callbacks = {
        on_put = function(pos, listname, index, stack, player)

            local name = string.format("nodemeta:%s,%s,%s", pos.x, pos.y, pos.z)
            on_change(name)
        end,
        on_move = function(pos, from_list, from_index, to_list, to_index, count,
                           player)
            local name = string.format("nodemeta:%s,%s,%s", pos.x, pos.y, pos.z)
            on_change(name)
        end
    }

    local detached_callbacks = {
        on_put = function(inv, listname, index, stack, player)
            on_change("detached:" .. inv:get_location().name)
        end,
        on_move = function(inv, from_list, from_index, to_list, to_index, count,
                           player)

            on_change("detached:" .. inv:get_location().name)
        end
    }

    local player_callbacks = {
        on_put = function(inv, listname, index, stack, player)
            -- print the keys of the player object
            on_change("player:" .. player:get_player_name())
            -- minetest.log("action", "Player put item" .. player_name)
        end,
        on_move = function(inventory, from_list, from_index, to_list, to_index,
                           count, player)
            -- Assuming `player` argument provides the player's name
            minetest.log("action",
                         "Player put item" .. minetest.serialize(player))
            minetest.log("action", "Player moved item")
            on_change("player:" .. player:get_player_name())
        end
    }

    item_tracking.register_tracker(item, node_callbacks, detached_callbacks,
                                   player_callbacks)

end
