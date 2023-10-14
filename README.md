# Description

A Minetest mod that provides a API to mod developers to track which inventories
items are in.

# API

## Track Item

You Can track a given item across node,detached and player inventories, when
someone puts something in a inventory, or moves the item within the inventory.

```lua
local node_callbacks = {
    on_put = function(pos, listname, index, stack, player)
        minetest.log("action", "Item put in node inventory")
    end,
    on_move = function(pos, from_list, from_index, to_list, to_index, count,
                       player) act("Item moved in node inventory") end
}

local detached_callbacks = {
    on_put = function(inventories, listname, index, stack, player)
        minetest.log("action", "Item put in detached inventory")
    end,
    on_move = function(inv, from_list, from_index, to_list, to_index, count,
                       player) act("Item moved in detached inventory") end
}

local player_callbacks = {
    on_put = function(itemstack, player, inventory, index)
        minetest.log("action", "Item put in players inventory")
    end,
    on_move = function(inventory, from_list, from_index, to_list, to_index,
                       count, player)
        minetest.log("action", "Item is moved in player's inventory")
    end
}

item_tracking.register_tracker({
    name = "modular_computers:motherboard_tier_1",
    meta = {id = "some_unique_id"} -- optional
}, node_callbacks, detached_callbacks, player_callbacks)
```

## Track Items Attached Inventory

You can track the inventories the items are in. To say for example, check if the
item still exists in a inventory.

```lua
item_tracking.track_attached_inventory({
    name = "modular_computers:motherboard_tier_1",
    meta = {id = "ze0ei1beb0Xsz4VuUB4nLPS1BME"} -- meta is optional
}, function(name) minetest.log("action", "Attached to " .. name) end)
```

# License

- [Code License](LICENSE)
