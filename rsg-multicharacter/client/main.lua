local RSGCore = exports['rsg-core']:GetCoreObject()
local charPed = nil
local selectingChar = true
local isChossing = false
local DataSkin = nil

local function baseModel(sex)
    if (sex == 'mp_male') then
        ApplyShopItemToPed(charPed, 0x158cb7f2, true, true, true); --head
        ApplyShopItemToPed(charPed, 361562633,  true, true, true); --hair
        ApplyShopItemToPed(charPed, 62321923,   true, true, true); --hand
        ApplyShopItemToPed(charPed, 3550965899, true, true, true); --legs
        ApplyShopItemToPed(charPed, 612262189,  true, true, true); --Eye
        ApplyShopItemToPed(charPed, 319152566,  true, true, true); --
        ApplyShopItemToPed(charPed, 0x2CD2CB71, true, true, true); -- shirt
        ApplyShopItemToPed(charPed, 0x151EAB71, true, true, true); -- bots
        ApplyShopItemToPed(charPed, 0x1A6D27DD, true, true, true); -- pants
    else
        ApplyShopItemToPed(charPed, 0x1E6FDDFB, true, true, true); -- head
        ApplyShopItemToPed(charPed, 272798698,  true, true, true); -- hair
        ApplyShopItemToPed(charPed, 869083847,  true, true, true); -- Eye
        ApplyShopItemToPed(charPed, 736263364,  true, true, true); -- hand
        ApplyShopItemToPed(charPed, 0x193FCEC4, true, true, true); -- shirt
        ApplyShopItemToPed(charPed, 0x285F3566, true, true, true); -- pants
        ApplyShopItemToPed(charPed, 0x134D7E03, true, true, true); -- bots
    end
end

local function skyCam(bool)
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        -- old SetCamCoord(cam, -555.925, -3778.709, 238.597)
        SetCamCoord(cam, -556.025, -3777.209, 238.597) -- camara fija inicio sin menu
        SetCamRot(cam, -20.0, 0.0, 83)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
        fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        -- old SetCamCoord(fixedCam, -561.206, -3776.224, 239.597)
        SetCamCoord(fixedCam, -559.806, -3776.624, 239.220) -- camara fija con rotacion vista con menu
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
    SetEntityCoords(PlayerPedId(), -562.91, -3776.25, 237.63)
    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(10)
    exports.weathersync:setMyTime(0, 0, 0, 0, true)
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
    if cData ~= nil then
        RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getAppearance', function(appearance)
            local skinTable = appearance.skin or {}
            DataSkin = appearance.skin
            local clothesTable = appearance.clothes or {}
            local sex = tonumber(skinTable.sex) == 1 and `mp_male` or `mp_female`
            if sex ~= nil then
                CreateThread(function ()
                    RequestModel(sex)
                    while not HasModelLoaded(sex) do
                        Wait(0)
                    end
                    charPed = CreatePed(sex, -558.91, -3776.25, 237.63, 120.0, false, false)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    while not IsPedReadyToRender(charPed) do
                        Wait(1)
                    end
                    exports['rsg-appearance']:ApplySkinMultiChar(skinTable, charPed, clothesTable)
                    TaskStartScenarioInPlace(charPed, GetHashKey("WORLD_HUMAN_WRITE_NOTEBOOK"), -1, true, "StartScenario", 0, false)

                end)
            else
                CreateThread(function()
                    local randommodels = {
                        "mp_male",
                        "mp_female",
                    }
                    local randomModel = randommodels[math.random(1, #randommodels)]
                    local model = joaat(randomModel)
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    Wait(100)
                    baseModel(randomModel)
                    charPed = CreatePed(model, -558.91, -3776.25, 237.63, 120.0, false, false)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    TaskStartScenarioInPlace(charPed, GetHashKey("WORLD_HUMAN_WRITE_NOTEBOOK"), -1, true, "StartScenario", 0, false)

                end)
            end
        end, cData.citizenid)
    else
        CreateThread(function()
            local randommodels = {
                "mp_male",
                "mp_female",
            }
            local randomModel = randommodels[math.random(1, #randommodels)]
            local model = joaat(randomModel)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            charPed = CreatePed(model, -558.91, -3776.25, 237.63, 120.0, false, false)
            Wait(100)
            baseModel(randomModel)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            NetworkSetEntityInvisibleToNetwork(charPed, true)
            SetBlockingOfNonTemporaryEvents(charPed, true)
            TaskStartScenarioInPlace(charPed, GetHashKey("WORLD_HUMAN_WRITE_NOTEBOOK"), -1, true, "StartScenario", 0, false)

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

RegisterNUICallback('selectCharacter', function(data)
    selectingChar = false
    local cData = data.cData
    if DataSkin ~= nil then
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData)
        openCharMenu(false)
        local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        Wait(5000)
        TriggerServerEvent('rsg-appearance:server:LoadSkin')
        Wait(500)
        TriggerServerEvent('rsg-appearance:server:LoadClothes', 1)
        SetModelAsNoLongerNeeded(model)
    else
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData, true)
        openCharMenu(false)
        local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        SetModelAsNoLongerNeeded(model)
    end
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
    selectingChar = false
    DoScreenFadeOut(150)
    Wait(200)
    TriggerEvent("rsg-multicharacter:client:closeNUI")
    DestroyAllCams(true)
    SetModelAsNoLongerNeeded(charPed)
    DeleteEntity(charPed)
    DoScreenFadeIn(1000)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerEvent('rsg-appearance:client:OpenCreator', data)
end)

RegisterNUICallback('removeCharacter', function(data) -- Removing a char
    TriggerServerEvent('rsg-multicharacter:server:deleteCharacter', data.citizenid)
    TriggerEvent('rsg-multicharacter:client:chooseChar')
end)

-- Threads
CreateThread(function()

    repeat Wait(1000) until GetIsLoadingScreenActive()

    RequestImap(-1699673416)
    RequestImap(1679934574)
    RequestImap(183712523)

    TriggerEvent('rsg-multicharacter:client:chooseChar')
    isChossing = true
        CreateThread(function()
            while isChossing do
            Wait(0)
            Citizen.InvokeNative(0xF1622CE88A1946FB)
        end
    end)
end)
