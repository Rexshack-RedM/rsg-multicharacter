local charPed = nil
local choosingCharacter = false
local currentSkin = nil
local currentClothes = nil
local selectingChar = true
local isChossing = false
local PlayerSkins = {}
local PlayerClothes = {}
local characters = {}
local RSGCore = exports['rsg-core']:GetCoreObject()

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

local function baseModel(sex)
    if (sex == 'mp_male') then
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x158cb7f2, true, true, true); --head
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 361562633, true, true, true); --hair
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 62321923, true, true, true); --hand
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 3550965899, true, true, true); --legs
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 612262189, true, true, true); --Eye
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 319152566, true, true, true); --
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x2CD2CB71, true, true, true); -- shirt
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x151EAB71, true, true, true); -- bots
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x1A6D27DD, true, true, true); -- pants
    else
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x1E6FDDFB, true, true, true); -- head
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 272798698, true, true, true); -- hair
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 869083847, true, true, true); -- Eye
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 736263364, true, true, true); -- hand
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x193FCEC4, true, true, true); -- shirt
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x285F3566, true, true, true); -- pants
        Citizen.InvokeNative(0xD3A7B003ED343FD9, charPed, 0x134D7E03, true, true, true); -- bots
    end
end

local function createCharacter(sex)
    if (sex == 0) then
        local model = 'mp_male'
        RequestAndSetModel(model)
        Wait(1000)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x158cb7f2, true, true, true); --head
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x16e292a1, true, true, true); --torso
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0xa615e02, true, true, true); --legs
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x105ddb4, true, true, true); --hair
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x10404a83, true, true, true); --mustache
        -- Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 0, 0) -- set outfit preset, unsure if needed
        SetModelAsNoLongerNeeded(model)
    else
        local model = 'mp_female'
        RequestAndSetModel(model)
        Wait(1000)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x11567c3, true, true, true); --head
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x2c4fe0c5, true, true, true); --torso
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0xaa25eca7, true, true, true); --legs
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x104293ea, true, true, true); --hair
        -- Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 0, 0) -- set outfit preset, unsure if needed
        SetModelAsNoLongerNeeded(model)
    end
    selectingChar = false
end

local function RequestAndSetModel(model)
    local requestedModel = GetHashKey(model)
    RequestModel(requestedModel)
    while not HasModelLoaded(requestedModel) do
        Wait(0)
    end
    Wait(200)
    Citizen.InvokeNative(0xED40380076A31506, PlayerId(), requestedModel, false)
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 0, 0)
    Wait(200)
    Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x1D4C528A, 0)
    Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0x3F1F01E5, 0)
    Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), 0xDA0E2C55, 0)
end

local function skyCam(bool)
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(cam, -555.925, -3778.709, 238.597)
        SetCamRot(cam, -20.0, 0.0, 83)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
        fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(fixedCam, -561.206, -3776.224, 239.597)
        SetCamRot(fixedCam, -20.0, 0, 270.0)
        SetCamActive(fixedCam, true)
        SetCamActiveWithInterp(fixedCam, cam, 3900, true, true)
        Wait(3900)
        DestroyCam(groundCam)
        InterP = true
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

-- Handlers

AddEventHandler('onResourceStop', function(resource)
    if (GetCurrentResourceName() == resource) then
        DeleteEntity(charPed)
        SetModelAsNoLongerNeeded(charPed)
    end
end)

local function openCharMenu(bool)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            action = "ui",
            toggle = bool,
            nChar = result,
        })
        choosingCharacter = bool
        Wait(100)
        skyCam(bool)
    end)
end

RegisterNetEvent('rsg-multicharacter:client:closeNUI', function()
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
    isChossing = false
end)

RegisterNetEvent('rsg-multicharacter:client:chooseChar', function()
    SetEntityVisible(PlayerPedId(), false, false)
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    GetInteriorAtCoords(-558.9098, -3775.616, 238.59, 137.98)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), -562.91,-3776.25,237.63)
    Wait(1500)
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
RegisterNUICallback('cDataPed', function(data) -- Visually seeing the char
    local cData = data.cData
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    if cData then
        RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getAppearance', function(appearance)
            local skinTable = appearance.skin
            local clothesTable = appearance.clothes
            local sex = tonumber(skinTable.sex)
            if sex == 1 then
                model = "mp_male"
            elseif sex == 2 then
                model = "mp_female"
            end
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            charPed = CreatePed(model, -558.91, -3776.25, 237.63, 90.0, true, false, 0, 0)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            SetBlockingOfNonTemporaryEvents(charPed, true)
            while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, charPed) do
                Wait(1)
            end
            TriggerEvent('rsg-appearance:ApplySkin', skinTable, charPed, clothesTable)
        end, cData.citizenid)
    else
        CreateThread(function()
            local randommodels = {
                "mp_male",
                "mp_female",
            }
            local randomModel = randommodels[math.random(1, #randommodels)]
            local model = GetHashKey(randomModel)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            charPed = CreatePed(model, -558.91, -3776.25, 237.63, 90.0, false, false)
            Wait(100)
            baseModel(randomModel)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            NetworkSetEntityInvisibleToNetwork(charPed, true)
            SetBlockingOfNonTemporaryEvents(charPed, true)
        end)
    end
end)

RegisterNUICallback('closeUI', function()
    openCharMenu(false)
end)

RegisterNUICallback('disconnectButton', function()
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('rsg-multicharacter:server:disconnect')
end)

RegisterNUICallback('selectCharacter', function(data) -- When a char is selected and confirmed to use
    CreateThread(function()
        selectingChar = false
        local cData = data.cData
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData)
        openCharMenu(false)
        local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        Wait(5000)
        TriggerServerEvent("rsg-appearance:loadSkin")
        Wait(500)
        TriggerServerEvent("rsg-clothes:LoadClothes", 1)
        SetModelAsNoLongerNeeded(model)
    end)
end)

RegisterNUICallback('setupCharacters', function() -- Present char info
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
    end)
end)

RegisterNUICallback('removeBlur', function()
    SetTimecycleModifier('default')
end)

RegisterNUICallback('createNewCharacter', function(data) -- Creating a char
    DoScreenFadeOut(150)
    Wait(200)
    DestroyAllCams(true)
    DeleteEntity(charPed)
    TriggerEvent("rsg-appearance:OpenCreator")
    SetModelAsNoLongerNeeded(charPed)
    TriggerServerEvent('rsg-multicharacter:server:createCharacter', data)
    Wait(1000)
    DoScreenFadeIn(1000)
end)

RegisterNUICallback('removeCharacter', function(data) -- Removing a char
    TriggerServerEvent('rsg-multicharacter:server:deleteCharacter', data.citizenid)
    TriggerEvent('rsg-multicharacter:client:chooseChar')
end)

-- Threads

CreateThread(function()
    RequestImap(-1699673416)
    RequestImap(1679934574)
    RequestImap(183712523)
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            TriggerEvent('rsg-multicharacter:client:chooseChar')
            isChossing = true
            CreateThread(function()
                while isChossing do
                    Wait(0)
                    Citizen.InvokeNative(0xF1622CE88A1946FB)
                end
            end)
            return
        end
    end
end)
