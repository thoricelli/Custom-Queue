--[[
_________________________________________________________
__  /___  /_________________(_)_____________  /__  /__(_)   
_  __/_  __ \  __ \_  ___/_  /_  ___/  _ \_  /__  /__  /    
/ /_ _  / / / /_/ /  /   _  / / /__ /  __/  / _  / _  /     
\__/ /_/ /_/\____//_/    /_/  \___/ \___//_/  /_/  /_/      

Name: Custom Queue System
Date: 24/07/2020
File Description: Handles requests from server and information
]]

--SETUP--

local Http = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local teleportService = game:GetService("TeleportService")

local Settings = script.Parent:FindFirstChild("Settings").Value --SoundIds,{DefaultTextQueue,DefaultTextJobId,DisplayQueuePosition,DisplayServerId}
Settings = Http:JSONDecode(Settings)

local soundIds = Settings[1]

local isReserved = ReplicatedStorage.IsPrivateServer:InvokeServer() --Check if the server is private or not

--SETUP--

function PlaySoundId(randomNumber)
	if #soundIds > 0 then
		local RelaxingMusic = script.Parent:FindFirstChild("RelaxingMusic")
		
		RelaxingMusic.SoundId = "rbxassetid://"..soundIds[randomNumber]
		print(soundIds[randomNumber])
		repeat wait() print(RelaxingMusic.TimeLength) until RelaxingMusic.TimeLength > 0 or not nil --Wait for the sound to buffer in
		RelaxingMusic:Play()
		wait(RelaxingMusic.TimeLength)
		RelaxingMusic:Stop()
	
		PlaySoundId(math.random(1,#soundIds))
	end
end

if isReserved then
	local DefaultTextQueue = Settings[2][1]
	local DefaultTextJobId = Settings[2][2]
	local DisplayQueuePosition = Settings[2][3]
	local DisplayServerId = Settings[2][4]
	
	local teleportdata = teleportService:GetLocalPlayerTeleportData() --Get the jobId
	
	if (teleportdata and type(teleportdata) == "string" and string.len(teleportdata) == 36) then
		script.Parent.Enabled = true --Make the GUI visible
		
		if (DisplayServerId) then
			script.Parent.Frame.JobId.Text = DefaultTextJobId.." "..teleportdata
		end
		
		ReplicatedStorage.JobIDToJoin:InvokeServer(teleportdata) --Send jobId to server
		
		
		if (DisplayQueuePosition) then
			ReplicatedStorage.QueuePosition.OnClientInvoke = function(queue)
				script.Parent.Frame.QueuePosition.Text = DefaultTextQueue.." "..queue --Update queue
			end
		end
		
		if script.Parent:FindFirstChild("RelaxingMusic") ~= nil then
			PlaySoundId(math.random(1,#soundIds))
		end
	end
end