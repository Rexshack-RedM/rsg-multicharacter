local RSGCore = exports['rsg-core']:GetCoreObject()

local cached_player_skins = {}
local randommodels = { "mp_male", "mp_female"}

local charPed = nil
local loadScreenCheckState = false

local DataSkin = nil
local cam = nil
local fixedCam = nil
local spawnThread = nil
local selectingChar = true

CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            Wait(500)
            TriggerEvent('rsg-multicharacter:client:chooseChar')
            return
        end
    end
end)

local cams = {
    {
        type = "customization",
        x = -561.8157,
        y = -3780.966,
        z = 239.0805,
        rx = -4.2146,
        ry = -0.0007,
        rz = -87.8802,
        fov = 30.0
    },
    {
        type = "selection",
        x = -562.8157,
        y = -3776.266,
        z = 239.0805,
        rx = -4.2146,
        ry = -0.0007,
        rz = -87.8802,
        fov = 30.0
    }
}

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

local function cleanPed(ped)
    if DoesEntityExist(ped) then
        local model = IsPedMale(ped) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(ped, true, true)
        DeleteEntity(ped)
        SetModelAsNoLongerNeeded(model)
        charPed = nil
    end
end

local function baseModel(sex)
    local partsBody = (sex == 'mp_male') and {
        {0x158cb7f2, true}, --head
        {361562633, true},  --hair
        {62321923, true},   --hand
        {3550965899, true}, --legs
        {612262189, true},  --Eye
        {319152566, true},
        {0x2CD2CB71, true}, -- shirt
        {0x151EAB71, true}, -- bots
        {0x1A6D27DD, true}  -- pants
    } or {
        {0x1E6FDDFB, true}, -- head
        {272798698, true},  -- hair
        {869083847, true},  -- Eye
        {736263364, true},  -- hand
        {0x193FCEC4, true}, -- shirt
        {0x285F3566, true}, -- pants
        {0x134D7E03, true}  -- bots
    }
    for _, part in ipairs(partsBody) do
        if charPed and DoesEntityExist(charPed) then
            ApplyShopItemToPed(charPed, part[1], part[2], true, true)
        end
    end
end

local function initializePedModel(appearanceData, coords, heading)
    if spawnThread then TerminateThread(spawnThread) end
    spawnThread = CreateThread(function()
        local modelName
        local modelHash
        local skinTable, clothesTable
        if appearanceData and appearanceData.skin then
            DataSkin = appearanceData.skin
            modelName = (tonumber(appearanceData.skin.sex) == 1) and "mp_male" or "mp_female"
            skinTable = appearanceData.skin
            clothesTable = appearanceData.clothes or {}
        else
            modelName = randommodels[math.random(#randommodels)]
        end
        modelHash = joaat(modelName)

        loadModel(modelHash)
        charPed = CreatePed(modelHash, coords.x, coords.y, coords.z, heading, false, false)

        FreezeEntityPosition(charPed, false)
        SetEntityInvincible(charPed, true)
        SetBlockingOfNonTemporaryEvents(charPed, true)

        while not IsPedReadyToRender(charPed) do Wait(1) end

        if skinTable then
            exports['rsg-appearance']:ApplySkinMultiChar(skinTable, charPed, clothesTable)
        else
            baseModel(modelName)
        end
        Wait(50)
    end)
end

local function skyCam(bool)
    exports.weathersync:setMyTime(0, 0, 0, 0, true) -- SYNC OFF
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(cam, -555.925, -3778.709, 238.597)
        SetCamRot(cam, -20.0, 0.0, 83)
        SetCamActive(cam, true)
        fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(fixedCam, -561.206, -3776.224, 239.597)
        SetCamRot(fixedCam, -20.0, 0, 270.0)
        SetCamActive(fixedCam, true)
        SetCamActiveWithInterp(fixedCam, cam, 3900, true, true)
        RenderScriptCams(true, false, 1, true, true)
        Wait(3900)
        if cam and DoesCamExist(cam) then DestroyCam(cam) end
    else
        SetTimecycleModifier('default')
        if cam and DoesCamExist(cam) then
            SetCamActive(cam, false)
            DestroyCam(cam, true)
        end
        cam = nil
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

-- Handlers

AddEventHandler('onResourceStop', function(resource)
    if (GetCurrentResourceName() ~= resource) then return end
    selectingChar = false
    SetTimecycleModifier('default')
    DestroyAllCams(true)
    RenderScriptCams(false, false, 0, true, false)
    cam = nil
    fixedCam = nil
    FreezeEntityPosition(PlayerPedId(), false)
    cleanPed(charPed)
    DataSkin = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "ui", toggle = false })
end)

local function openCharMenu(bool)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            action = "ui",
            toggle = bool,
            nChar = result,
        })
        skyCam(bool)
        Wait(100)
        if not loadScreenCheckState then
            ShutdownLoadingScreenNui()
            loadScreenCheckState = true
        end
    end)
end

RegisterNetEvent('rsg-multicharacter:client:closeNUI', function()
    cleanPed(charPed)
    SetNuiFocus(false, false)
end)

RegisterNetEvent('rsg-multicharacter:client:chooseChar', function()
    selectingChar = true
    SetEntityVisible(PlayerPedId(), false, false)
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    GetInteriorAtCoords(-558.9098, -3775.616, 238.59, 137.98)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), -562.91,-3776.25,237.63)
    Wait(2500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(10)
    openCharMenu(true)
    while selectingChar do
        Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        DrawLightWithRange(coords.x, coords.y , coords.z + 1.0 , 255, 255, 255, 5.5, 50.0)
    end
end)

-- NUI
RegisterNUICallback('cDataPed', function(data, cb) -- Visually seeing the char
    local cData = data.cData
    cleanPed(charPed)

    if cData ~= nil then
        if cached_player_skins[cData.citizenid] then
            initializePedModel(cached_player_skins[cData.citizenid], vector3(-558.91, -3776.25, 237.63), 90.0)
            cb('ok')
        else
            RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getAppearance', function(appearance)
                cached_player_skins[cData.citizenid] = appearance
                initializePedModel(appearance, vector3(-558.91, -3776.25, 237.63), 90.0)
                cb('ok')
            end, cData.citizenid)
        end
    else
        DataSkin = nil
        initializePedModel(nil, vector3(-558.91, -3776.25, 237.63), 90.0)
        cb('ok')
    end
end)

RegisterNUICallback('closeUI', function(data, cb)
    DoScreenFadeOut(10)
    openCharMenu(false)
    TriggerServerEvent('rsg-multicharacter:server:loadUserData', data)
    cleanPed(charPed)
    cb('ok')
end)

RegisterNUICallback('disconnectButton', function(data, cb)
    cleanPed(charPed)
    TriggerServerEvent('rsg-multicharacter:server:disconnect')
    cb('ok')
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    selectingChar = false
    local cData = data.cData
    if DataSkin ~= nil then
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData)
        openCharMenu(false)
        cleanPed(charPed)
        Wait(5000)
        TriggerServerEvent('rsg-appearance:server:LoadSkin')
        Wait(500)
        TriggerServerEvent('rsg-appearance:server:LoadClothes', 1)
    else
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData, true)
        openCharMenu(false)
        cleanPed(charPed)
    end
    cb('ok')
end)

RegisterNUICallback('setupCharacters', function(data, cb) -- Present char info
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        cached_player_skins = {}
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
    end)
    cb('ok')
end)

RegisterNUICallback('removeBlur', function(data, cb)
    SetTimecycleModifier('default')
    cb('ok')
end)

RegisterNUICallback('createNewCharacter', function(data, cb) -- Creating a char
    local cData = data
    selectingChar = false
    DoScreenFadeOut(150)
    local sex = cData.gender == 1 and `mp_male` or `mp_female`
    Wait(200)
    openCharMenu(false)
    DestroyAllCams(true)
    cleanPed(charPed)
    DoScreenFadeIn(1000)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerEvent('rsg-appearance:client:OpenCreator', data)
    Wait(500)
    cb('ok')
end)

RegisterNUICallback('removeCharacter', function(data, cb) -- Removing a char
    TriggerServerEvent('rsg-multicharacter:server:deleteCharacter', data.citizenid)
    Wait(200)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({ action = "setupCharacters", characters = result })
    end)
    TriggerEvent('rsg-multicharacter:client:chooseChar')
    cb('ok')
end)

-- unstick player from start location
CreateThread(function()
    if LocalPlayer.state['isLoggedIn'] then
        exports['rsg-core']:createPrompt('unstick', vector3(-549.77, -3778.38, 238.60), RSGCore.Shared.Keybinds['J'], 'Set Me Free!', {
            type = 'client',
            event = 'rsg-multicharacter:client:unstick',
        })
    end
end)

RegisterNetEvent('rsg-multicharacter:client:unstick', function()
    SetEntityCoordsNoOffset(cache.ped, vector3(-169.47, 629.38, 114.03), true, true, true)
    FreezeEntityPosition(cache.ped, false)
end)
