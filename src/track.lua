function track_node(item, node_name, on_put, on_move)
    -- Override node inventory callbacks
    local original_node_def = minetest.registered_nodes[node_name]
    if original_node_def then
        local original_on_put = original_node_def.on_metadata_inventory_put
        local original_on_move = original_node_def.on_metadata_inventory_move

        minetest.override_item(node_name, {
            on_metadata_inventory_put = function(pos, listname, index, stack,
                                                 player)
                if original_on_put then
                    original_on_put(pos, listname, index, stack, player)
                end
                -- Get Item Name
                local item_name = stack:get_name()
                -- Get item Metadata
                local item_meta = stack:get_meta()
                if item.name == item_name and
                    (item.meta == nil or item.meta == item_meta) then
                    on_put(pos, listname, index, stack, player)
                end
            end,
            on_metadata_inventory_move = function(pos, from_list, from_index,
                                                  to_list, to_index, count,
                                                  player)
                if original_on_move then
                    original_on_move(pos, from_list, from_index, to_list,
                                     to_index, count, player)
                end
                -- Access the inventory at the specified position
                local inv = minetest.get_meta(pos):get_inventory()
                -- Get the stack that's being moved
                local stack = inv:get_stack(to_list, to_index)
                -- Get Item Name
                local item_name = stack:get_name()
                -- Get item Metadata
                local item_meta = stack:get_meta()
                act("NODE")
                act("Item name: " .. item_name)
                act("Item meta: " .. minetest.serialize(item_meta:to_table()))

                if item.name == item_name and
                    (item.meta == nil or item.meta == item_meta) then
                    on_move(pos, from_list, from_index, to_list, to_index,
                            count, player)
                end
            end
        })
    else
        log:warn("No node registered with name: " .. node_name)
    end
end

function track_detached(item, inventory_name, on_put, on_move)
    -- Override detached inventory callbacks
    local inv = minetest.get_inventory({
        type = "detached",
        name = inventory_name
    }) -- Fixed variable name to match the function argument
    if is_inventory_empty(inv) == false then
        local original_on_put = inv.on_put
        local original_on_move = inv.on_move

        local new_on_put = function(inv, listname, index, stack, player)
            if original_on_put then
                original_on_put(inv, listname, index, stack, player)
            end
            -- Get Item Name
            local item_name = stack:get_name()
            -- Get item Metadata
            local item_meta = stack:get_meta()
            if item.name == item_name and
                (item.meta == nil or item.meta == item_meta) then
                on_put(inv, listname, index, stack, player)
            end
        end

        local new_on_move = function(inv, from_list, from_index, to_list,
                                     to_index, count, player)
            if original_on_move then
                original_on_move(inv, from_list, from_index, to_list, to_index,
                                 count, player)
            end
            -- Access the inventory
            -- Get the stack that's being moved
            local stack = inv:get_stack(to_list, to_index)
            -- Get Item Name
            local item_name = stack:get_name()
            -- Get item Metadata
            local item_meta = stack:get_meta()

            act("DETATCHED")
            act("Item name: " .. item_name)
            act("Item meta: " .. minetest.serialize(item_meta:to_table()))
            if item.name == item_name and
                (item.meta == nil or item.meta == item_meta) then
                on_move(inv, from_list, from_index, to_list, to_index, count,
                        player)
            end
        end

        override_detached_inventory(inventory_name, new_on_put, new_on_move)
    else
        warn("No detached inventory found with name: " .. inventory_name)
    end
end

function track_player(item, on_put, on_move)

    act("track_player: Item Meta" .. minetest.serialize(item.meta))

    item = {fields = item}

    act("track_player: Item Meta Fields" .. minetest.serialize(item.fields.meta))

    minetest.register_on_player_inventory_action(
        function(player, action, inventory, inventory_info)
            local stack
            local item_name
            local item_meta

            -- Determine which stack to use based on the action
            if action == "put" then
                stack = inventory_info.stack
                -- Get Item Name
                item_name = stack:get_name()
                -- Get item Metadata
                item_meta = stack:get_meta()

            elseif action == "move" then
                -- For 'move' action, you can use the from_list and from_index to access the stack
                stack = inventory:get_stack(inventory_info.to_list,
                                            inventory_info.to_index)
                -- Get Item Name
                item_name = stack:get_name()
                -- Get item Metadata
                item_meta = stack:get_meta()
            else
                -- For other actions, you might not want to proceed
                return
            end

            local item_meta_table = item_meta:to_table()

            -- Check if the item being acted upon matches the item name and metadata

            local serialized_item_meta = minetest.serialize(item.fields.meta)
            local serialized_item_meta_table =
                minetest.serialize(item_meta_table)

            local serialized_item_moved_meta = minetest.serialize(
                                                   item_meta:to_table().fields)

            if item.fields.name == item_name and
                (item.fields.meta == nil or serialized_item_meta ==
                    serialized_item_moved_meta) then
                if action == "put" then
                    on_put(inventory, inventory_info.listname,
                           inventory_info.index, stack, player)
                elseif action == "move" then
                    on_move(inventory, inventory_info.from_list,
                            inventory_info.from_index, inventory_info.to_list,
                            inventory_info.to_index, stack:get_count(), player)
                end
            end
        end)
end
