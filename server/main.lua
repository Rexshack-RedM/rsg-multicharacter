local RSGCore = exports['rsg-core']:GetCoreObject()

-- Functions
-- local identifierUsed = GetConvar('es_identifierUsed', 'steam')
local hasDonePreloading = {}

AddEventHandler('RSGCore:Server:PlayerLoaded', function(Player)
    Wait(1000) -- 1 second should be enough to do the preloading in other resources
    hasDonePreloading[Player.PlayerData.source] = true
end)

AddEventHandler('RSGCore:Server:OnPlayerUnload', function(src)
    hasDonePreloading[src] = false
end)

-- generate horseid
local function GenerateHorseid()
    local UniqueFound = false
    local horseid = nil
    while not UniqueFound do
        horseid = tostring(RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM player_horses WHERE horseid = ?', { horseid })
        if result == 0 then
            UniqueFound = true
        end
    end
    return horseid
end
-- Functions

-- give starter items
local function GiveStarterItems(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    for k, v in pairs(RSGCore.Shared.StarterItems) do
        Player.Functions.AddItem(v.item, v.amount)
    end
    if Config.StarterHorse then
        local horseid = GenerateHorseid()
        local horsesex = {'male', 'female'}
        local randomSex = math.random(1, #horsesex)
        local randomHorseSex = horsesex[randomSex]
        MySQL.insert('INSERT INTO player_horses(stable, citizenid, horseid, name, horse, gender, active, born) VALUES(@stable, @citizenid, @horseid, @name, @horse, @gender, @active, @born)', {
            ['@stable'] = Config.StarterHorseStable,
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@horseid'] = horseid,
            ['@name'] = Config.StarterHorseName,
            ['@horse'] = Config.StarterHorseModel,
            ['@gender'] = randomHorseSex,
            ['@active'] = true,
            ['@born'] = os.time()
        })
    end
end

RegisterNetEvent('rsg-multicharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "You have disconnected from RSG RedM")
end)

RegisterNetEvent('rsg-multicharacter:server:loadUserData', function(cData, skindata)
    local src = source
    if RSGCore.Player.Login(src, cData.citizenid) then
        print('^2[rsg-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        repeat
            Wait(10)
        until hasDonePreloading[src]
        RSGCore.Commands.Refresh(src)
        TriggerClientEvent("rsg-multicharacter:client:closeNUI", src)
        if not skindata then
            TriggerClientEvent('rsg-spawn:client:setupSpawnUI', src, cData, false)
        else
            TriggerClientEvent('rsg-appearance:client:OpenCreator', src, false, true)
        end
        TriggerEvent('rsg-log:server:CreateLog', 'joinleave', 'Player Joined Server', 'green', '**' .. GetPlayerName(src) .. '** joined the server..')
    end
end)

RegisterNetEvent('rsg-multicharacter:server:createCharacter', function(data)
    local newData = {}
    local src = source
    newData.cid = data.cid
    newData.charinfo = data
    if RSGCore.Player.Login(src, false, newData) then
        repeat
            Wait(10)
        until hasDonePreloading[src]
        RSGCore.ShowSuccess(GetCurrentResourceName(), GetPlayerName(src)..' has succesfully loaded!')
        RSGCore.Commands.Refresh(src)
        GiveStarterItems(src)
    end
end)

RegisterNetEvent('rsg-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    MySQL.update('DELETE FROM playerskins WHERE citizenid = ?', {citizenid})
    RSGCore.Player.DeleteCharacter(src, citizenid)
end)

-- Callbacks

RSGCore.Functions.CreateCallback("rsg-multicharacter:server:setupCharacters", function(source, cb)
    local src = source
    local license = RSGCore.Functions.GetIdentifier(src, 'license')
    local plyChars = {}
    MySQL.Async.fetchAll('SELECT * FROM players WHERE license = @license', {['@license'] = license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)
            plyChars[#plyChars+1] = result[i]
        end
        cb(plyChars)
    end)
end)

RSGCore.Functions.CreateCallback("rsg-multicharacter:server:GetNumberOfCharacters", function(source, cb)
    local src = source
    local license = RSGCore.Functions.GetIdentifier(src, 'license')
    local numOfChars = 0
    if next(Config.PlayersNumberOfCharacters) then
        for i, v in pairs(Config.PlayersNumberOfCharacters) do
            if v.license == license then
                numOfChars = v.numberOfChars
                break
            else
                numOfChars = Config.DefaultNumberOfCharacters
            end
        end
    else
        numOfChars = Config.DefaultNumberOfCharacters
    end
    cb(numOfChars)
end)

RSGCore.Functions.CreateCallback("rsg-multicharacter:server:getAppearance", function(source, cb, citizenid)
    MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', { citizenid}, function(result)
        if result ~= nil and #result > 0 then
            local skinData = json.decode(result[1].skin)
            local clothesData = json.decode(result[1].clothes)
            result[1].skin = skinData
            result[1].clothes = clothesData
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

RSGCore.Commands.Add("logout", "Logout of Character (Admin Only)", {}, false, function(source)
    local src = source
    RSGCore.Player.Logout(src)
    TriggerClientEvent('rsg-multicharacter:client:chooseChar', src)
end, 'admin')

RSGCore.Commands.Add("closeNUI", "Close Multi NUI", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-multicharacter:client:closeNUI', src)
end, 'user')
