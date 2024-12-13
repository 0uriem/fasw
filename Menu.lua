if game.PlaceId ~= 10904925594 then return end
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

game:GetService("ReplicatedStorage"):WaitForChild('Core'):WaitForChild('Events'):WaitForChild('SelectSlot'):FireServer(1)
task.wait(2)
game:GetService("ReplicatedStorage"):WaitForChild('Core'):WaitForChild('Events'):WaitForChild('JoinUp'):FireServer('OpenWorld')

local TeleportReq = false
game.Players.LocalPlayer.OnTeleport:Connect(function()
    if TeleportReq then return end
    TeleportReq = true
    queueteleport()
end)
