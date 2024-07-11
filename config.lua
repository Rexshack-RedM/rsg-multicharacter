Config = {}

Config.EnablePlayerOut = true

Config.DefaultNumberOfCharacters = 3 -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}

-------------------------
-- EXTRA Webhooks / RANKING
-----------------------
Config.Webhooks = {
    ["loaded"] = "https://discord.com/api/webhooks/1257638072858968105/Wzog2bgrEApeLvXnAenhGRE9a26x80V5OuAL-aamlNnuCbuAvBqlZ1b-KgrZuV5esJ9W", -- log public
    ["joinleave"] = "https://discord.com/api/webhooks/1248113969026175087/AQtzaXSpqUV_W6ypxdB-eA_1kvziXhZG2c8dD__L2vJK2oxShDVd2Dgaup-G7oTfWwsZ", -- log private
}