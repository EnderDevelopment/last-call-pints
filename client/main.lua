local function isWorking()
    local job = exports.qbx_core:GetPlayerData().job
    if not job or job.name ~= Config.Job then return false end
    if Config.RequireDuty and not job.onduty then return false end

    local grade = type(job.grade) == 'table' and job.grade.level or job.grade
    return (tonumber(grade) or 0) >= Config.MinimumGrade
end

local function loadAnimation(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local timeout = GetGameTimer() + 5000
        while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
            Wait(10)
        end
    end
    return HasAnimDictLoaded(dict)
end

local function playAction(label, duration, animation)
    if not loadAnimation(animation.dict) then
        Config.Notify('Could not load the work animation.', 'error')
        return false
    end

    local completed = lib.progressCircle({
        duration = duration,
        label = label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = animation.dict, clip = animation.clip }
    })

    ClearPedTasks(cache.ped)
    return completed == true
end

local function chooseDrink(title, description)
    local choices = {}
    for index, keg in ipairs(Config.Kegs) do
        choices[#choices + 1] = { value = index, label = description(keg) }
    end

    local result = lib.inputDialog(title, {
        {
            type = 'select',
            label = 'Drink',
            required = true,
            options = choices
        }
    })

    return result and tonumber(result[1]) or nil
end

local function pourPint()
    local kegId = chooseDrink('Pour a pint', function(keg)
        return ('%s | $%d'):format(keg.label, keg.price)
    end)
    if not kegId then return end

    if not playAction('Pouring pint...', Config.PourDuration, Config.PourAnimation) then
        Config.Notify('Pouring cancelled.', 'error')
        return
    end

    local success, message = lib.callback.await('ender_pub:server:pourPint', false, kegId)
    Config.Notify(message or 'The pour could not be completed.', success and 'success' or 'error')
end

local function getNearbyPlayers()
    local players = {}
    local myCoords = GetEntityCoords(cache.ped)

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local serverId = GetPlayerServerId(playerId)
            local ped = GetPlayerPed(playerId)
            if serverId > 0 and DoesEntityExist(ped) and #(myCoords - GetEntityCoords(ped)) <= 4.0 then
                players[#players + 1] = {
                    value = serverId,
                    label = ('%s (%d)'):format(GetPlayerName(playerId), serverId)
                }
            end
        end
    end

    return players
end

local function servePint()
    local drinkChoices = {}
    for index, keg in ipairs(Config.Kegs) do
        drinkChoices[#drinkChoices + 1] = { value = index, label = keg.label }
    end

    local playerChoices = getNearbyPlayers()
    if #playerChoices == 0 then
        Config.Notify('No customers are close enough to serve.', 'error')
        return
    end

    local result = lib.inputDialog('Serve a customer', {
        { type = 'select', label = 'Pint', options = drinkChoices, required = true },
        { type = 'select', label = 'Customer', options = playerChoices, required = true }
    })
    if not result then return end

    local kegId, targetId = tonumber(result[1]), tonumber(result[2])
    if not playAction('Serving pint...', Config.ServeDuration, Config.ServeAnimation) then
        Config.Notify('Serving cancelled.', 'error')
        return
    end

    local success, message = lib.callback.await('ender_pub:server:servePint', false, kegId, targetId)
    Config.Notify(message or 'The pint could not be served.', success and 'success' or 'error')
end

local function checkStock()
    local stock, errorMessage = lib.callback.await('ender_pub:server:getStock', false)
    if not stock then
        Config.Notify(errorMessage or 'Stock could not be checked.', 'error')
        return
    end

    local options = {}
    for _, item in ipairs(stock) do
        options[#options + 1] = {
            title = item.label,
            description = ('Kegs in your inventory: %d | Pint price: $%d'):format(item.count, item.price),
            icon = 'box'
        }
    end

    lib.registerContext({ id = 'ender_pub_stock', title = 'Bar stock', options = options })
    lib.showContext('ender_pub_stock')
end

local function showInteraction(point)
    local options = {}
    if point.action == 'pour' then
        options = { { label = 'Pour a pint', icon = 'fa-solid fa-beer-mug-empty', onSelect = pourPint } }
    elseif point.action == 'serve' then
        options = { { label = 'Serve a pint', icon = 'fa-solid fa-handshake', onSelect = servePint } }
    else
        options = { { label = 'Check bar stock', icon = 'fa-solid fa-box', onSelect = checkStock } }
    end

    lib.registerContext({ id = 'ender_pub_interaction', title = 'The Pub', options = options })
    lib.showContext('ender_pub_interaction')
end

CreateThread(function()
    local points = {
        { data = Config.Points.Pour, action = 'pour' },
        { data = Config.Points.Serve, action = 'serve' },
        { data = Config.Points.Storage, action = 'stock' }
    }

    while true do
        local waitTime = 1000
        local promptVisible = false
        local coords = GetEntityCoords(cache.ped)
        local working = isWorking()

        if working then
            for _, point in ipairs(points) do
                local distance = #(coords - point.data.coords)
                if distance <= Config.MarkerDistance then
                    waitTime = 0
                    DrawMarker(
                        Config.MarkerType,
                        point.data.coords.x, point.data.coords.y, point.data.coords.z - 0.9,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        Config.MarkerScale.x, Config.MarkerScale.y, Config.MarkerScale.z,
                        Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                        false, true, 2, false, nil, nil, false
                    )

                    if distance <= Config.InteractionDistance then
                        promptVisible = true
                        lib.showTextUI(('[E] %s'):format(point.data.label))
                        if IsControlJustReleased(0, 38) then
                            showInteraction(point)
                            Wait(500)
                        end
                    end
                end
            end
        end

        if not promptVisible then
            lib.hideTextUI()
        end
        Wait(waitTime)
    end
end)
