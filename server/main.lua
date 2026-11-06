local function getJobState(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return nil, 'Your character could not be found.'
    end

    local job = player.PlayerData.job
    if not job or job.name ~= Config.Job then
        return nil, 'You need to be working at the pub to do that.'
    end

    local grade = type(job.grade) == 'table' and job.grade.level or job.grade
    if (tonumber(grade) or 0) < Config.MinimumGrade then
        return nil, 'Your job grade is too low to do that.'
    end

    if Config.RequireDuty and not job.onduty then
        return nil, 'Clock in before working at the pub.'
    end

    return player
end

local function getKeg(kegId)
    local index = tonumber(kegId)
    if not index then return nil end
    return Config.Kegs[index]
end

lib.callback.register('ender_pub:server:pourPint', function(source, kegId)
    local player, errorMessage = getJobState(source)
    if not player then
        return false, errorMessage
    end

    local keg = getKeg(kegId)
    if not keg then
        return false, 'That drink is not available.'
    end

    if exports.ox_inventory:GetItemCount(source, keg.item) < 1 then
        return false, ('The bar is out of %s.'):format(keg.label:lower())
    end

    if not exports.ox_inventory:CanCarryItem(source, keg.glass, 1) then
        return false, 'You do not have room to carry a pint.'
    end

    if not exports.ox_inventory:RemoveItem(source, keg.item, 1) then
        return false, 'The keg stock could not be used.'
    end

    if not exports.ox_inventory:AddItem(source, keg.glass, 1) then
        exports.ox_inventory:AddItem(source, keg.item, 1)
        return false, 'The pint could not be added to your inventory.'
    end

    return true, ('Poured a %s.'):format(keg.label:lower())
end)

lib.callback.register('ender_pub:server:servePint', function(source, kegId, targetId)
    local player, errorMessage = getJobState(source)
    if not player then
        return false, errorMessage
    end

    local keg = getKeg(kegId)
    local target = tonumber(targetId)
    if not keg or not target or target == source or not GetPlayerName(target) then
        return false, 'Choose a nearby customer.'
    end

    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(target)
    if sourcePed == 0 or targetPed == 0 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        return false, 'That customer is too far away.'
    end

    if exports.ox_inventory:GetItemCount(source, keg.glass) < 1 then
        return false, ('You do not have a %s to serve.'):format(keg.label:lower())
    end

    if not exports.ox_inventory:CanCarryItem(target, keg.glass, 1) then
        return false, 'That customer cannot carry another pint.'
    end

    if not exports.ox_inventory:RemoveItem(source, keg.glass, 1) then
        return false, 'The pint could not be removed from your inventory.'
    end

    if not exports.ox_inventory:AddItem(target, keg.glass, 1) then
        exports.ox_inventory:AddItem(source, keg.glass, 1)
        return false, 'The pint could not be delivered.'
    end

    return true, ('Served a %s to %s.'):format(keg.label:lower(), GetPlayerName(target))
end)

lib.callback.register('ender_pub:server:getStock', function(source)
    local _, errorMessage = getJobState(source)
    if errorMessage then return nil, errorMessage end

    local stock = {}
    for index, keg in ipairs(Config.Kegs) do
        stock[index] = {
            label = keg.label,
            item = keg.item,
            count = exports.ox_inventory:GetItemCount(source, keg.item),
            price = keg.price
        }
    end

    return stock
end)
