Config = {}

Config.Job = 'bar'
Config.MinimumGrade = 0
Config.PourDuration = 6500
Config.ServeDuration = 3000
Config.InteractionDistance = 2.0
Config.MarkerDistance = 18.0
Config.MarkerType = 2
Config.MarkerScale = vec3(0.18, 0.18, 0.18)
Config.MarkerColor = { r = 234, g = 187, b = 87, a = 180 }
Config.RequireDuty = true

Config.Payment = {
    item = 'cash',
    receiptItem = 'pub_receipt',
    receiptLabel = 'The Pub receipt'
}

Config.PourAnimation = {
    dict = 'amb@world_human_drinking@coffee@male@idle_a',
    clip = 'idle_c'
}

Config.ServeAnimation = {
    dict = 'mp_common',
    clip = 'givetake1_a'
}

Config.Kegs = {
    {
        label = 'Lager Pint',
        item = 'lager_keg',
        glass = 'lager_pint',
        price = 8
    },
    {
        label = 'Pale Ale Pint',
        item = 'pale_ale_keg',
        glass = 'pale_ale_pint',
        price = 9
    },
    {
        label = 'Stout Pint',
        item = 'stout_keg',
        glass = 'stout_pint',
        price = 9
    }
}

Config.Points = {
    Pour = {
        coords = vec3(-1387.62, -586.18, 30.22),
        label = 'Pour a pint'
    },
    Serve = {
        coords = vec3(-1384.92, -588.66, 30.22),
        label = 'Serve a pint'
    },
    Storage = {
        coords = vec3(-1389.28, -584.77, 30.22),
        label = 'Check bar stock'
    }
}

Config.Notify = function(message, type)
    lib.notify({
        title = 'The Pub',
        description = message,
        type = type or 'inform'
    })
end
