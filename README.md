# Rexshack Gaming Version
 
# credits
- original resouce created by : https://github.com/qbcore-redm-framework
- convert and rework by : https://github.com/QRCore-RedM-Re

Note: In rsg-appearance cl_main.lua in the RegisterNetEvent('rsg-appearance:ApplySkin'), 
remove the following: `local savedhealth = RSGCore.Functions.GetPlayerData().metadata["health"] or 600` & `SetEntityHealth(PlayerPedId(), savedhealth, 0)`.
rsg-appearance cant get metadata on preview character ped. so gotta remove it to have function to preview character. 