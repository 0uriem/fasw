--Auto Buy Food

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local VirtualUser = game:GetService('VirtualUser')
--
local CoreEvents = ReplicatedStorage:WaitForChild('Core'):WaitForChild('Events')
--
local DataEvents = CoreEvents:WaitForChild('Data')
local ThrottleData = DataEvents:WaitForChild('ThrottleData')
local PurchaseRemote = DataEvents:WaitForChild('ConfirmPurchase')
--
local CharacterEvents = CoreEvents:WaitForChild('Character')
local RespawnRemote = CharacterEvents:WaitForChild('Respawn')
local ShadowRemote = CharacterEvents:WaitForChild('SpawnShadow')
local NapRemote = CharacterEvents:WaitForChild('Nap')
--
local PlayerEvents = CoreEvents:WaitForChild('Player')
local SelectMissionDifficulty = PlayerEvents:WaitForChild('SelectMissionDifficulty')
local MenuAction = PlayerEvents:WaitForChild('MenuAction')
--
local CombatEvents = CoreEvents:WaitForChild('Combat')
local LockOn = CombatEvents:WaitForChild('LockOn')
local UpdateHitbox = CombatEvents:WaitForChild('UpdateClientHitbox')
local RecoverStamina = CombatEvents:WaitForChild('RecoverStamina')
local RecoverRagdoll = CombatEvents:WaitForChild('Recover')
--
local SpaceShip = workspace.StarMailShip
local BreakableIce = workspace.BreakableIce
local CleanableTrash = workspace.CleanableTrash
local SpawnedCharacters = workspace.SpawnedCharacters
--
local LocalPlayer = Players.LocalPlayer
local Connections = {}
local CreatedInstances = {}
--
local SlotData
--
local LatentProgress = LocalPlayer.PlayerGui.UI.Frame.LatentProgress
--
local Food = 'Pork Bun'
local Seller = "Chilley's Crafts"
local FoodPrice = 500
--
local MissionBoard = CFrame.new(898.9939575195312, 272.4340515136719, 1004.3404541015625)
local MailShip = CFrame.new(1747.211181640625, 733.032470703125, -486.29962158203125)
local NapLocation = CFrame.new(5199.97363, 559.346619, 2644.99878, -0.644051313, -2.24837233e-08, -0.764982283, 6.02875361e-10, 1, -2.98987395e-08, 0.764982283, -1.97175112e-08, -0.644051313)
local ShadowBoxLocation = CFrame.new(5133.88232, 2041.1366, 2676.71094, 0.190642506, -0.0049938662, 0.981646836, -0.000269407639, 0.999986768, 0.0051394864, -0.981659472, -0.0012442678, 0.190638632)
--
local MissionQuest
local QuestProgress = 0
local QuestGoal 
local ActiveQuest = nil
--
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
--
for i,v in pairs(Connections) do
    v:Disconnect()
    i = nil
end

for i,v in pairs(CreatedInstances) do
    if v then
        v:Destroy()
    end
end


LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(math.random(10, 50), math.random(10, 50)))
end)

local TeleportReq = false
LocalPlayer.OnTeleport:Connect(function()
    if TeleportReq then return end
    TeleportReq = true
    queueteleport()

end)


Connections['SlotData'] = ThrottleData.OnClientEvent:Connect(function(Data)
    if typeof(Data) ~= 'table' then return warn('no') end 
    local Slots = Data.Slots 
    if typeof(Slots) == 'table' then
        print('1')
        local ActiveSlot = Data.ActiveSlot
        if typeof(ActiveSlot) == 'number' then 
            print('3')
            if typeof(Slots[ActiveSlot]) == 'table' then
                print('4')
                SlotData = Slots[ActiveSlot] 
                warn('set')
            end
        end
    end
    if typeof(SlotData['Active_Quest']) == 'table' then 
        ActiveQuest = SlotData['Active_Quest']
        for i,v in pairs(SlotData['Active_Quest']) do 
            if i == 'Objective' then
                MissionQuest = v 
                print('Mission Objective = ',MissionQuest)
            end
            if i == 'Progress' then
                for Info,Data in pairs(v) do
                    if Info == 'Goal' then 
                        QuestGoal = Data 
                        print('Goal = ',QuestGoal)
                    end
                    if Info == 'Current' then
                        QuestProgress = Data
                        print('QuestProgress = ',QuestProgress)
                    end
                end
            end
        end
    else 
        ActiveQuest = nil 
    end
end)


local function BeginerQuestFarm()

    if not SlotData then RespawnCharacter() end

    local Character = LocalPlayer.Character
    local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
    local Humanoid = Character and Character:FindFirstChild('Humanoid')
    if not HumanoidRootPart or not Humanoid then return end

    print('Instances created')

    Connections['AutoQuest'] = RunService.Heartbeat:Connect(function()
        for _,v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
                v.Velocity = Vector3.zero
            end
        end
        if CreatedInstances['Platform'] then 
            CreatedInstances['Platform'].CFrame = HumanoidRootPart.CFrame * CFrame.new(0,-2.5,0)  
        end
        if  CreatedInstances['FloatVelocity'] then 
            CreatedInstances['FloatVelocity'].Velocity = Vector3.zero
        end
        sethiddenproperty(LocalPlayer, 'MaxSimulationRadius', math.huge);
        sethiddenproperty(LocalPlayer, 'SimulationRadius', math.huge);   
    end)

    


    local MissionRan = 0

    local function FarmMission()
        -- Check for SlotData
        -- Teleport to mission board
        HumanoidRootPart.CFrame = MissionBoard 
        task.wait(0.5)
        SelectMissionDifficulty:FireServer('Beginner')
        task.wait(1)
        if MissionQuest and MissionQuest == 'Destroy the ice covering the Energy Reactors!' then
            local function GatherReactors()
                for _,Ice in pairs(BreakableIce:GetChildren()) do
                    if QuestProgress >= QuestGoal + 1  or not ActiveQuest then break end 
                    
                    local RandomPart = Ice:FindFirstChild('Part')
                    if RandomPart and RandomPart.Transparency ~= 0.5 then continue end 
                    print('Check 1')
                    local ProximityPrompt = Ice:FindFirstChild('ProximityPrompt',true)
                    if ProximityPrompt then
                        print('Has Prox Prompt')
                        ProximityPrompt.HoldDuration = 0
                        HumanoidRootPart.CFrame = ProximityPrompt.Parent.CFrame * CFrame.new(0,-5,0)
                        task.wait(0.5)
                        print('Teleported')
                        repeat task.wait()
                            fireproximityprompt(ProximityPrompt,1)
                        until RandomPart.Transparency ~= 0.5 or getgenv().TestRun == false
                        print('Proxy clicked and part vanished')
                      --  QuestProgress += 1 
                      --     if QuestProgress == 9 then print('yea was 9') QuestProgress = 10 end
                        warn('new prog = ',QuestProgress)
                        warn('Quest Goal = ',QuestGoal + 1)
                    end
                end
            end

            repeat
                task.wait()
                GatherReactors()
            until  QuestProgress >= QuestGoal  or not ActiveQuest or getgenv().TestRun == false
            warn('YEA ITS DONE!')
            MissionQuest = nil
            QuestProgress = 0
            QuestGoal = nil
        elseif MissionQuest and MissionQuest == 'Clean up the trash at the station!' then 
            local function GatherTrash()
                for _,TrashBag in pairs(CleanableTrash:GetChildren()) do
                    if QuestProgress >= QuestGoal + 1 or not ActiveQuest then break end 
                    local RandomPart = TrashBag:FindFirstChild('Part')
                    if RandomPart and RandomPart.Transparency ~= 0 then continue end 
                    print('Check 1')
                    local ProximityPrompt = RandomPart and RandomPart:FindFirstChild('ProximityPrompt',true)
                    if ProximityPrompt then
                        print('Has Prox Prompt')
                        ProximityPrompt.HoldDuration = 0
                        HumanoidRootPart.CFrame = ProximityPrompt.Parent.CFrame * CFrame.new(0,-5,0)
                        task.wait(0.5)
                        print('Teleported')
                        repeat task.wait()
                            fireproximityprompt(ProximityPrompt,1)
                        until RandomPart.Transparency ~= 0 or getgenv().TestRun == false
                        print('Proxy clicked and part vanished')
                        --      QuestProgress += 1 
                        ---if QuestProgress == 19 then print('yea was 19') QuestProgress = 20 end
                        warn('new prog = ',QuestProgress)
                        warn('Quest Goal = ',QuestGoal + 1)
                    end
                end
            end
            repeat
                task.wait()
                GatherTrash()
            until  QuestProgress >= QuestGoal or not ActiveQuest or getgenv().TestRun == false
            warn('YEA ITS DONE! X2')
            MissionQuest = nil
            QuestProgress = 0
            QuestGoal = nil
        elseif MissionQuest and MissionQuest == 'Deliver the package to the Star Mailbox!' then 
            HumanoidRootPart.CFrame = MailShip 
            task.wait(0.5)
            print('teleported to mailbox')
            local ProximityPrompt = SpaceShip:FindFirstChild('ProximityPrompt',true)
            if ProximityPrompt then
                ProximityPrompt.HoldDuration = 0
                local Click = 0
                repeat task.wait()
                    fireproximityprompt(ProximityPrompt,1)
                    Click += 1
                until Click == 50 or getgenv().TestRun == false
            end
            MissionQuest = nil
            QuestProgress = 0
            QuestGoal = nil
        end
    end

    repeat 
        task.wait()
        FarmMission()
        MissionRan += 1
        warn('Mission Ran ',MissionRan)
    until MissionRan >= 10 or getgenv().TestRun == false

    print('Enough')
end


local function GetZeni()
    local Zeni = LocalPlayer:GetAttribute('Zeni')
    if typeof(Zeni) ~= 'number' then return end
    return Zeni
end

local function CalculateBuyAmount(Zeni)
    return math.floor(Zeni/FoodPrice)
end

local function PurchaseFood()
    local Character = LocalPlayer.Character
    local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
    local Humanoid = Character and Character:FindFirstChild('Humanoid')
    if not Humanoid or not HumanoidRootPart then return end

    local Zeni = GetZeni()
    local AmountToBuy = CalculateBuyAmount(Zeni)
    if AmountToBuy <= 0 then

        BeginerQuestFarm()
        AmountToBuy = CalculateBuyAmount(Zeni)
    end
    task.wait(0.5)

    for Index = 1, AmountToBuy do
        task.wait()
        PurchaseRemote:FireServer(Food,Seller)
    end

end

local function RespawnCharacter()
    if LocalPlayer.Character then
        local Humanoid = LocalPlayer.Character:WaitForChild('Humanoid',5)
        LocalPlayer.Character:BreakJoints()
        LocalPlayer.CharacterAdded:Wait()
        task.wait(1.15)
    end
end


local function CheckFoodAmount()
    local Amount = 0
    if not SlotData then 
        repeat task.wait() until SlotData or getgenv().TestRun == false
    end

    for i,v in pairs(SlotData.Items) do
        if i == Food then
            for a,b in pairs(v) do
                if a == 'Amount' then
                    Amount = b
                end
            end
        end
    end
    return Amount
end

local function ConsumeFood()
    MenuAction:FireServer('Use',{Name = 'Pork Bun'})
end


local function Attack()
    local Character = LocalPlayer.Character
    if not Character then return end
    Character:SetAttribute('ThrottledLightAttack',true)
    Character:SetAttribute('ThrottledLightAttack',false)
end


local function SpawnShadow()
    local ShadowTarget = SpawnedCharacters:FindFirstChild(tostring(LocalPlayer.UserId))
    if ShadowTarget then return ShadowTarget end
    CharacterEvents.SpawnShadow:FireServer()
    repeat task.wait() until SpawnedCharacters:FindFirstChild(tostring(LocalPlayer.UserId)) or getgenv().TestRun == false task.wait()
    ShadowTarget = SpawnedCharacters:FindFirstChild(tostring(LocalPlayer.UserId))
    return ShadowTarget
end


local function CheckLatentBar()
    local LatentNumber = 0 
    for Number in string.gmatch(LatentProgress.Text,"%d+") do
        LatentNumber = Number
    end
    return tonumber(LatentNumber)
end

Connections['CharacterAdded'] = LocalPlayer.CharacterAdded:Connect(function(Char)
end)


if LocalPlayer.Character then
    local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')

    CreatedInstances['Platform'] = Instance.new('Part')
    CreatedInstances['Platform'].Size = Vector3.new(10, 0.1, 10)
    CreatedInstances['Platform'].Transparency = 0.75
    CreatedInstances['Platform'].Parent = LocalPlayer.Character

    CreatedInstances['FloatVelocity'] = Instance.new('BodyVelocity')
    CreatedInstances['FloatVelocity'].MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    CreatedInstances['FloatVelocity'].Velocity = Vector3.zero
    CreatedInstances['FloatVelocity'].Parent = HumanoidRootPart 

    task.wait(2)
    for i = 1,5 do
        task.wait()
        HumanoidRootPart.CFrame = ShadowBoxLocation
    end
    task.wait(1.5)
end

local ShadowNPC = SpawnShadow()
local ShadowStats = ShadowNPC:WaitForChild('Core',5)
local KnockedBack = ShadowStats:WaitForChild('FlungBack',5)

Connections['Spawned'] = task.spawn(function()
    while getgenv().TestRun do
        task.wait()
        if ShadowNPC then
            UpdateClientHitbox:FireServer(ShadowNPC,'MaxRange')
            RecoverStamina:FireServer()
            Recover:FireServer()
        end
    end
end)





getgenv().TestRun = true
local function NewFarm()
    while getgenv().TestRun do
        task.wait()
        if getgenv().TestRun == false then break end
        local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    
        -- First Check Latent Power
        local LatentAmount = CheckLatentBar()
        if LatentAmount >= 50 or LocalPlayer:GetAttribute('Fatigue') >= 50 then 
            if ShadowNPC then
                if LocalPlayer.Character.Core.Target.Value == ShadowNPC then
                    LockOn:FireServer()
                end
                ShadowRemote:FireServer()
            end
            -- Check food levels
            local FoodAmount = CheckFoodAmount()
            if FoodAmount <= 1 then
                PurchaseFood()
            end
            ConsumeFood()
            task.wait(1.25)
            print('Food Ate moving on')
    
            if CreatedInstances['Platform'] then
                CreatedInstances['Platform']:Destroy()
            end
            if CreatedInstances['FloatVelocity'] then
                CreatedInstances['FloatVelocity']:Destroy()
            end
    
            for i = 1,10 do
                if getgenv().TestRun == false then break end
                HumanoidRootPart.CFrame = NapLocation
                task.wait()
            end
            task.wait(1.5)
            print('Teleported to nap location')
            NapRemote:FireServer()
            print('napping?')
            repeat task.wait(0.1) until LocalPlayer:GetAttribute('Fatigue') <= 5 or getgenv().TestRun == false
            if getgenv().TestRun == false then break end
            task.wait(1.5)
            NapRemote:FireServer()
            print('got rid of nap')
            CreatedInstances['Platform'] = Instance.new('Part')
            CreatedInstances['Platform'].Size = Vector3.new(10, 0.1, 10)
            CreatedInstances['Platform'].Transparency = 0.75
            CreatedInstances['Platform'].Parent = LocalPlayer.Character
    
            CreatedInstances['FloatVelocity'] = Instance.new('BodyVelocity')
            CreatedInstances['FloatVelocity'].MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            CreatedInstances['FloatVelocity'].Velocity = Vector3.zero
            CreatedInstances['FloatVelocity'].Parent = HumanoidRootPart 
            print(' gave character back platform nd float')
    
            task.wait(0.5)
            for i = 1,10 do
                if getgenv().TestRun == false then break end
                HumanoidRootPart.CFrame = ShadowBoxLocation
                task.wait()
            end
            print(' teleported back to box location')
            task.wait(2)
            ShadowNPC = SpawnShadow()
            ShadowStats = ShadowNPC:WaitForChild('Core',5)
            KnockedBack = ShadowStats:WaitForChild('FlungBack',5)
        end
    
        if LocalPlayer.Character and ShadowNPC and  LocalPlayer.Character.Core.Target.Value ~= ShadowNPC then
            LockOn:FireServer(ShadowNPC)
        end
    
        if KnockedBack.Value then 
            CombatEvents.ZVanish:FireServer()
        end
    
        if ShadowNPC then
            local ShadowRoot = ShadowNPC:FindFirstChild('HumanoidRootPart')
            local Distance = ShadowRoot and (ShadowRoot.Position - HumanoidRootPart.Position).magnitude
            if Distance and Distance <= 20 then
                Attack()
            end 
        end
    end
    for i,v in pairs(Connections) do
        v:Disconnect()
        i = nil
    end
    for i,v in pairs(CreatedInstances) do
        if v then
            v:Destroy()
        end
    end

    if ShadowNPC and LocalPlayer.Character.Core.Target.Value == ShadowNPC then
        LockOn:FireServer()
    end
    if ShadowNPC then
        ShadowRemote:FireServer()
    end
    
end
 NewFarm()
Players.PlayerAdded:Connect(function()
    getgenv().TestRun = false
end)


Players.PlayerRemoving:Connect(function()
    if #Players:GetPlayers() == 1 then
        getgenv().TestRun = true
        NewFarm()
    end
end)
