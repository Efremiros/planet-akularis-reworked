local max_spill = 60

local rock_yield = {
    ['big-rock'] = 1,
    ['huge-rock'] = 2,
    ['big-sand-rock'] = 1
}
local rocks_yield_ore_distance_modifier = 0.25
local rocks_yield_ore_base_amount = 15
local rocks_yield_ore_maximum_amount = 150

local function shuffle_table(t)
    local iterations = #t
    if iterations == 0 then
        error('Not a sequential table')
        return
    end
    local j

    for i = iterations, 2, -1 do
        j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

local function get_chances() 
    local randomValue = math.random(0,99)
    
    if randomValue < 50 then
        return 'iron-ore'
    end
    if ( randomValue < 70) then
        return 'copper-ore'
    end
    if ( randomValue < 80) then
        return 'stone'
    end
    
    return 'coal'
end

local function get_amount(entity)
    local distance_to_center = math.floor(math.sqrt(entity.position.x ^ 2 + entity.position.y ^ 2))

    local amount = rocks_yield_ore_base_amount + (distance_to_center * rocks_yield_ore_distance_modifier)
    if amount > rocks_yield_ore_maximum_amount then
        amount = rocks_yield_ore_maximum_amount
    end

    local m = (70 + math.random(0, 60)) * 0.01

    amount = math.floor(amount * rock_yield[entity.name] * m)
    if amount < 1 then
        amount = 1
    end

    return amount
end

local function get_vamount(position)
    local distance_to_center = math.sqrt(position.x ^ 2 + position.y ^ 2) * 2 + 100
    distance_to_center = distance_to_center * 1
    local m = (10 + math.random(0, 50)) * 0.01
    return distance_to_center * m
end

local function draw_chain(surface, count, ore, ore_entities, ore_positions)
    local vectors = { { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } }
    local r = math.random(1, #ore_entities)
    local position = { x = ore_entities[r].position.x, y = ore_entities[r].position.y }
    for _ = 1, count, 1 do
        shuffle_table(vectors)
        for i = 1, 4, 1 do
            local p = { x = position.x + vectors[i][1], y = position.y + vectors[i][2] }
            if surface.can_place_entity({ name = 'coal', position = p, amount = 1 }) then
                if not ore_positions[p.x .. '_' .. p.y] then
                    position.x = p.x
                    position.y = p.y
                    ore_positions[p.x .. '_' .. p.y] = true
                    local name = ore
                    ore_entities[#ore_entities + 1] = { name = name, position = p, amount = get_vamount(position) }
                    break
                end
            end
        end
    end
end

local function ore_vein(event, ore)
    local surface = event.entity.surface
    local size = math.random(1, 96)
    local icon
    

    local player = game.players[event.player_index]

    local ore_entities = { { name = ore, position = { x = event.entity.position.x, y = event.entity.position.y }, amount = get_vamount(event.entity.position) } }
   
    local ore_positions = { [event.entity.position.x .. '_' .. event.entity.position.y] = true }
    local count = size

    for _ = 1, 128, 1 do
        local c = math.random(math.floor(size * 0.25) + 1, size)
        if count < c then
            c = count
        end

        local placed_ore_count = #ore_entities

        draw_chain(surface, c, ore, ore_entities, ore_positions)

        count = count - (#ore_entities - placed_ore_count)

        if count <= 0 then
            break
        end
    end

    for _, e in pairs(ore_entities) do
        surface.create_entity(e)
    end
end

local function on_player_mined_entity(event)
    local entity = event.entity
    if not entity.valid then
        return
    end
    if not rock_yield[entity.name] then
        return
    end
    if entity.surface.name ~= 'akularis' then
        return
    end
    

    event.buffer.clear()

    local ore = get_chances()
    local player = game.players[event.player_index]

    local position = { x = entity.position.x, y = entity.position.y }

    local count = get_amount(entity)
    local ore_amount = math.floor(count * 0.85) + 1
    local stone_amount = math.floor(count * 0.15) + 1
    if math.random(0, 100) < 8  then
        ore_vein(event, ore)
    end
    entity.destroy()
    
    if ore_amount > max_spill then
        player.surface.spill_item_stack({position = position, stack = { name = ore, count = max_spill }, enable_looted = true})
        ore_amount = ore_amount - max_spill
        local inserted_count = player.insert({ name = ore, count = ore_amount })
        ore_amount = ore_amount - inserted_count
        if ore_amount > 0 then
            player.surface.spill_item_stack({position = position, stack = { name = ore, count = ore_amount }, enable_looted=true})
        end
    else
        player.surface.spill_item_stack({position=position, stack = { name = ore, count = ore_amount }, enable_looted=true})
    end

    if stone_amount > max_spill then
        player.surface.spill_item_stack({position=position, stack = { name = 'stone', count = max_spill }, enable_looted=true})
        stone_amount = stone_amount - max_spill
        local inserted_count = player.insert({ name = 'stone', count = stone_amount })
        stone_amount = stone_amount - inserted_count
        if stone_amount > 0 then
            player.surface.spill_item_stack({position=position, stack = { name = 'stone', count = stone_amount }, enable_looted=true})
        end
    else
        player.surface.spill_item_stack({position=position, stack = { name = 'stone', count = stone_amount }, enable_looted = true})
    end
end

script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity)
