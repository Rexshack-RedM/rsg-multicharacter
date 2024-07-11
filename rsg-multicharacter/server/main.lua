local RSGCore = exports['rsg-core']:GetCoreObject()

---------------------------------------------
-- send To Discord
-------------------------------------------
local sendToDiscord = function(color, name, message, footer, type)
    local embed = {
            {
                ["color"] = color,
                ["title"] = "**".. name .."**",
                ["description"] = message,
                ["footer"] = {
                ["text"] = footer
            }
        }
    }
    if type == "load" then  -- public
    	PerformHttpRequest(Config['Webhooks']['loaded'], function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
    elseif type == "join" then -- pribate
        PerformHttpRequest(Config['Webhooks']['joinleave'], function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
    end
end

-------------------------------------------
-- Functions
-------------------------------------------
local identifierUsed = GetConvar('es_identifierUsed', 'steam')
local foundResources = {}
-- Functions

-- starter items
local StarterItems = {
    ['bread']      = { amount = 5, item = 'bread' },
    ['canteen100'] = { amount = 1, item = 'canteen100' }
}

-- give starter items
local function GiveStarterItems(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    for k, v in pairs(StarterItems) do
        Player.Functions.AddItem(v.item, v.amount)
    end
end

RegisterNetEvent('rsg-multicharacter:server:disconnect', function(source)
    DropPlayer(source, "You have disconnected from HDRP RedM")
end)

RegisterNetEvent('rsg-multicharacter:server:loadUserData', function(cData, skindata)
    local src = source
    if RSGCore.Player.Login(src, cData.citizenid) then
        print('^2[rsg-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        RSGCore.Commands.Refresh(src)
        TriggerClientEvent("rsg-multicharacter:client:closeNUI", src)
        if not skindata then
            TriggerClientEvent('rsg-spawn:client:setupSpawnUI', src, cData, false)
        else
            TriggerClientEvent('rsg-appearance:client:OpenCreator', src, false, true)
        end
        sendToDiscord(16753920,	"Login | GAME", "Name:** "..cData.charinfo.firstname.." "..cData.charinfo.lastname.. "**Ingame ID:** "..cData.cid.."\n**ENTRY TO PLAY",	"Log Multicharacter for RSG Framework",  "load")
        sendToDiscord(16753920,	"Login | GAME", "Citizenid:** "..cData.citizenid.."**Ingame ID:** "..cData.cid.. "\n**Name:** "..cData.charinfo.firstname.." "..cData.charinfo.lastname.. "\n**ENTRY TO PLAY** ".. GetPlayerName(src) .. "** ("..cData.citizenid.." | "..src..")**",	"Log Multicharacter for RSG Framework", "join")
        -- TriggerEvent('rsg-log:server:CreateLog', 'joinleave', 'Player Joined Server', 'green', '**' .. GetPlayerName(src) .. '** joined the server..')
    end
end)

RegisterNetEvent('rsg-multicharacter:server:createCharacter', function(data)
    local newData = {}
    local src = source
    newData.cid = data.cid
    newData.charinfo = data
    if RSGCore.Player.Login(src, false, newData) then
        RSGCore.ShowSuccess(GetCurrentResourceName(), GetPlayerName(src)..' has succesfully loaded!')
        RSGCore.Commands.Refresh(src)
        GiveStarterItems(src)
    end
end)

RegisterNetEvent('rsg-multicharacter:server:deleteCharacter', function(citizenid)
    RSGCore.Player.DeleteCharacter(source, citizenid)
end)

-- Callbacks

RSGCore.Functions.CreateCallback("rsg-multicharacter:server:setupCharacters", function(source, cb)
    local license = RSGCore.Functions.GetIdentifier(source, 'license')
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
    local license = RSGCore.Functions.GetIdentifier(source, 'license')
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

RSGCore.Commands.Add("logout", "Cerrar sesion del personaje (Admin Only)", {}, false, function(source)
    RSGCore.Player.Logout(source)
    TriggerClientEvent('rsg-multicharacter:client:chooseChar', source)
end, 'admin')

if Config.EnablePlayerOut then
    RSGCore.Commands.Add("playerout", "Cerrar sesion del personaje", {}, false, function(source)
        RSGCore.Player.Logout(source)
        TriggerClientEvent('rsg-multicharacter:client:chooseChar', source)
    end)
end

RSGCore.Commands.Add("closeNUI", "Close Multi NUI", {}, false, function(source)
    TriggerClientEvent('rsg-multicharacter:client:closeNUI', source)
end, 'user')