
local QBCore = exports['qb-core']:GetCoreObject()
-------
local searched = {3423423424}
local canSearch = true
local dumpsters = { 218085040, 666561306, -58485588, -206690185, 1511880420, 682791951, 1437508529, 2051806701, -246439655, 74073934, -654874323, 651101403, 909943734, 1010534896, 1614656839, -130812911, -93819890,
1329570871, 1143474856, -228596739, -468629664, -1426008804, -1187286639, -1096777189, -413198204, 437765445, -1830793175, -329415894, -341442425, -2096124444, 122303831, 1748268526, 998415499,
-5943724, -317177646, 1380691550, -115771139, -85604259, 1233216915, 375956747, 673826957, 354692929, -14708062, 811169045, -96647174, 1919238784, 275188277, 16567861, -1224639730, -1414390795, }
local searchTime = 500000
local idle = 0
local dumpPos
local nearDumpster = false
local maxDistance = 2.5
local listening = false
local dumpster
local currentCoords = nil
local realDumpster

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

CreateThread(function()
	--Dumpster Third Eye
	exports['qb-target']:AddTargetModel(dumpsters, { options = { { event = "qb-dumpster:client:dumpsterdive", icon = "fas fa-dumpster", label = "Search Trash", }, }, distance = 1.5 })
end)

--------
Citizen.CreateThread(function()
    local dist = 0
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local playerCoords, awayFromGarbage = GetEntityCoords(PlayerPedId()), true
        if not nearDumpster then
            for i = 1, #dumpsters do
                local distance
                dumpster = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.0, dumpsters[i], false, false, false)
                if dumpster ~= 0 then
                    realDumpster = dumpster 
                end
                dumpPos = GetEntityCoords(dumpster)
                local distance = #(pos - dumpPos)
                if distance < maxDistance then
                    currentCoords = dumpPos
                end
                if distance < maxDistance then
                    awayFromGarbage = false
                    nearDumpster = true
                end
            end
        end
        if currentCoords ~= nil and #(currentCoords - playerCoords) > maxDistance then
            nearDumpster = false
            listening = false
        end
        if awayFromGarbage then
            Citizen.Wait(1000)
        end
    end
end)


RegisterNetEvent("qb-dumpster:client:dumpsterdive", function()
    listening = true
    currentlySearching = false
    notifiedOfFailure = false
    Citizen.CreateThread(function()
        while listening do
            local dumpsterFound = false
            Citizen.Wait(10)
            for i = 1, #searched do
                if searched[i] == realDumpster then
                    dumpsterFound = true
                end
                if i == #searched and dumpsterFound and not notifiedOfFailure then
                    QBCore.Functions.Notify('This dumpster is empty', 'error')
                    notifiedOfFailure = true
                    Citizen.Wait(1000)
                elseif i == #searched and not dumpsterFound and not currentlySearching then
                    currentlySearching = true
                    QBCore.Functions.Progressbar("dumpsters", "Searching Dumpster", 4500, false, false, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "amb@prop_human_bum_bin@base",
                        anim = "base",
                        flags = 49,
                    }, {}, {}, function()
                        TriggerServerEvent("qb-dumpster:server:giveDumpsterReward")
                        notifiedOfFailure = true
                        TriggerServerEvent('qb-dumpster:server:startDumpsterTimer', dumpster)
                        table.insert(searched, realDumpster)
                    end, function()
                        QBCore.Functions.Notify('You cancelled the search', 'error')
                    end)
                end
            end
        end
    end)
end)
