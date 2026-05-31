local RSGCore = exports['rsg-core']:GetCoreObject()

-- Functions
local hasDonePreloading = {}

AddEventHandler('RSGCore:Server:PlayerLoaded', function(Player)
    Wait(1000)
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

local profanityList = {
    "anal", "anus", "arse", "ass", "asshole", "bastard", "bitch", "bloody",
    "blowjob", "bollock", "boner", "boob", "bugger", "buttplug", "chink",
    "clit", "cock", "coon", "crap", "cum", "cunt", "dick", "dildo", "dyke",
    "fag", "faggot", "feck", "fellate", "fellatio", "fuck", "goddamn",
    "goddamned", "hell", "homo", "horny", "jerk", "jizz", "knob", "labia",
    "lust", "masturbate", "motherfucker", "nazi", "nigga", "nigger", "nob",
    "orgasm", "penis", "piss", "porn", "prick", "pube", "pussy", "queer",
    "rectum", "retard", "sadist", "scrotum", "semen", "sex", "shag", "shit",
    "skank", "slut", "smegma", "snatch", "spunk", "tit", "tosser", "turd",
    "twat", "vagina", "viagra", "vulva", "wank", "whore", "xxx"
}

local function hasProfanity(text)
    if not text then return false end
    local lower = text:lower()
    for _, word in ipairs(profanityList) do
        if lower:find(word, 1, true) then
            return true
        end
    end
    return false
end

local function validateCharacterData(data)
    if type(data) ~= 'table' then return false end

    local requiredFields = {
        firstname = { max = 50, pattern = "^[%a'%- ]+$" },
        lastname  = { max = 50, pattern = "^[%a'%- ]+$" },
        nationality = { max = 50, pattern = "^[%a'%- ]+$" },
        birthdate = { max = 12, pattern = "^[0-9%-/]+$" },
        gender    = { check = function(v) return v == 0 or v == 1 end },
        cid       = { check = function(v) return tonumber(v) ~= nil end }
    }

    for field, rules in pairs(requiredFields) do
        local val = data[field]
        if val == nil or val == '' then return false end
        val = tostring(val)
        if rules.max and #val > rules.max then return false end
        if rules.pattern and not val:match(rules.pattern) then return false end
        if rules.check and not rules.check(val) then return false end
    end

    if hasProfanity(data.firstname) or hasProfanity(data.lastname) or hasProfanity(data.nationality) then
        return false
    end

    return true
end

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
    if not cData or not cData.citizenid then return end
    local license = RSGCore.Functions.GetIdentifier(src, 'license')
    MySQL.Async.fetchAll('SELECT citizenid FROM players WHERE citizenid = ? AND license = ?', { cData.citizenid, license }, function(result)
        if not result or #result == 0 then return end
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
end)

RegisterNetEvent('rsg-multicharacter:server:createCharacter', function(data)
    local src = source
    if not validateCharacterData(data) then
        DropPlayer(src, 'Invalid character data')
        return
    end
    local newData = {}
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
    if not citizenid then return end
    local license = RSGCore.Functions.GetIdentifier(src, 'license')
    MySQL.Async.fetchAll('SELECT citizenid FROM players WHERE citizenid = ? AND license = ?', { citizenid, license }, function(result)
        if not result or #result == 0 then return end
        MySQL.update('DELETE FROM playerskins WHERE citizenid = ?', {citizenid})
        RSGCore.Player.DeleteCharacter(src, citizenid)
    end)
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
    local numOfChars = Config.DefaultNumberOfCharacters
    for i, v in pairs(Config.PlayersNumberOfCharacters) do
        if v.license == license then
            numOfChars = v.numberOfChars
            break
        end
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

RSGCore.Functions.CreateCallback("rsg-multicharacter:server:getCharacterWeapons", function(source, cb, citizenid)
    MySQL.Async.fetchAll('SELECT metadata FROM players WHERE citizenid = ?', { citizenid }, function(result)
        if not result or #result == 0 then cb({}) return end
        local metadata = json.decode(result[1].metadata) or {}
        local equippedWeapons = metadata.equippedweapons or {}
        local weapons = {}
        for _, weaponData in pairs(equippedWeapons) do
            weapons[#weapons+1] = weaponData.name
        end
        cb(weapons)
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
end, 'admin')
