--[[
_________________________________________________________
__  /___  /_________________(_)_____________  /__  /__(_)   
_  __/_  __ \  __ \_  ___/_  /_  ___/  _ \_  /__  /__  /    
/ /_ _  / / / /_/ /  /   _  / / /__ /  __/  / _  / _  /     
\__/ /_/ /_/\____//_/    /_/  \___/ \___//_/  /_/  /_/      

Name: Custom Queue System
Date: 24/07/2020
File Description: Handles incoming and outcoming requests
]]

--DO NOT EDIT--
local module = {}

local closing = false
local isReserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 --Check if the server is a reserved server by another server
local queuelist = {} --{PLAYER, PLAYER, ...}, sorted equals their position in the queue
local alreadysentjobid = {} --Otherwise they can join multiple servers.

local http = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local MessagingService = game:GetService("MessagingService")

function module.Main(MinimumRank,groupId,DontTeleportAdmins,RelaxingMusic,UseGroup,Admins,maxplayers)
	
	local playerToWaitFor = ""
	
	function IsPlayerAllowed(plr)
		if (UseGroup) then
			return (plr:GetRankInGroup(groupId) >= MinimumRank)
		else
			return FindInTableNumber(plr.UserId,Admins)
		end
	end
	
	function FindInTableNumber(object,tabl)
		for i,v in pairs(tabl) do
			if v == object then
				return i
			end
		end
	end
	
	function TeleportToPrivateServer(plr)
		local Code,PrivatePlaceId = TeleportService:ReserveServer(game.PlaceId)
		TeleportService:TeleportToPrivateServer(game.PlaceId,Code,{plr},nil,game.JobId)
	end
	
	function WaitForPlayer(plr)
		wait(5)
		if playerToWaitFor == queuelist[1] then
			MessagingService:PublishAsync("TELEPORTREQUEST",http:JSONEncode({queuelist[1],game.JobId}))
		end
		wait(5)
		if playerToWaitFor == queuelist[1] then
			table.remove(queuelist,1)
			playerToWaitFor = ""
			if (maxplayers > #game.Players:GetChildren() - 1) and queuelist[1] then
				local playerexpecting = queuelist[1]
				MessagingService:PublishAsync("TELEPORTREQUEST",http:JSONEncode({queuelist[1],game.JobId}))
				WaitForPlayer(playerexpecting)
			end
		end
	end
	
	if (maxplayers >= 1) then
		
		game.ReplicatedStorage.IsPrivateServer.OnServerInvoke = function(plr)
			return isReserved
		end
		
		--PRIVATE SERVER
		
		--SEND TO SERVER WITH JOBID
		if isReserved then
			game.ReplicatedStorage.JobIDToJoin.OnServerInvoke = function(plr,jobID)
				game.Workspace:FindFirstChild("IsQueueServer").Value = true
				--Check for messages and position in queue
				if not FindInTableNumber(plr.Name,alreadysentjobid) then
					table.insert(alreadysentjobid,plr.Name)
					if (jobID and type(jobID) == "string" and string.len(jobID) == 36) then
						MessagingService:PublishAsync("QUEUELIST="..jobID,plr.Name)
					end
				end
			end
			
			MessagingService:SubscribeAsync("KICKREQUEST", function(queuelisttokick)
				queuelisttokick = queuelisttokick.Data
				for i,v in pairs(queuelisttokick) do
					if game.Players:FindFirstChild(v) ~= nil then
						game.Players:FindFirstChild(v):Kick("The server has shut down.")
					end
				end
			end)
			
			--SERVER RECEIVES QUEUE FOR PLAYER IN SERVER
			MessagingService:SubscribeAsync("QUEUEUPDATE", function(queueplayerlist) --{PLAYER,PLAYER,...}
				queueplayerlist = queueplayerlist.Data
				for i,v in pairs(queueplayerlist) do
					for _,player in pairs(game.Players:GetChildren()) do
						if v == player.Name then
							game.ReplicatedStorage.QueuePosition:InvokeClient(player,i)
						end
					end
				end
			end)
			
			local lastteleport = {} --PLAYER,JOBID
			
			--SERVER RECEIVES TELEPORT COMMAND
			MessagingService:SubscribeAsync("TELEPORTREQUEST", function(data)
				data = data.Data
				data = http:JSONDecode(data)
				local playername,jobId = data[1],data[2]
				if game.Players:FindFirstChild(playername) then
					lastteleport = {playername,jobId}
					TeleportService:TeleportToPlaceInstance(game.PlaceId,jobId,game.Players:FindFirstChild(playername))
				end
			end)
			
			--PLAYER LEFT -> UPDATE
			game.Players.PlayerRemoving:Connect(function(player)
				if (player.Name ~= lastteleport[1]) then
					table.remove(alreadysentjobid,FindInTableNumber(player.Name,alreadysentjobid))
					MessagingService:PublishAsync("QUEUELISTDELETE",player.Name)
				end
			end)
			
		end
		
		
		--NORMAL SERVER--
		
		--LISTEN FOR PLAYERS TO ADD
		if not isReserved then
			
			--LISTEN FOR MEMBER ADD TO QUEUELIST
			MessagingService:SubscribeAsync("QUEUELIST="..game.JobId,function(plrstring)
				plrstring = plrstring.Data
				table.insert(queuelist, plrstring)
				MessagingService:PublishAsync("QUEUEUPDATE", queuelist)
			end)
			
			--LISTEN FOR MEMBER DELETE FROM QUEUELIST
			MessagingService:SubscribeAsync("QUEUELISTDELETE", function(plrstring)
				plrstring = plrstring.Data
				if (playerToWaitFor == plrstring) then
					playerToWaitFor = ""
				end
				local positionintabl = FindInTableNumber(plrstring,queuelist)
				
				if positionintabl then
					table.remove(queuelist, positionintabl)
					MessagingService:PublishAsync("QUEUEUPDATE", queuelist)
				end
			end)
			
			--PLAYER ENTERS FULL SERVER
			game.Players.PlayerAdded:Connect(function(plr)
				if FindInTableNumber(plr.UserId,queuelist) then
					table.remove(FindInTableNumber(plr.UserId,queuelist))
					MessagingService:PublishAsync("QUEUEUPDATE", queuelist)
				end
				if (not IsPlayerAllowed(plr)) or (not DontTeleportAdmins) then
					if #game.Players:GetChildren() > maxplayers and playerToWaitFor == "" then
						TeleportToPrivateServer(plr)
					end
					if #game.Players:GetChildren() > maxplayers-1 and playerToWaitFor ~= "" then
						print(playerToWaitFor)
						if plr.Name ~= playerToWaitFor then
							TeleportToPrivateServer(plr)
						elseif plr.Name == playerToWaitFor then
							playerToWaitFor = ""
						end
					end
				end
			end)
			
			--SPACE AVAILABLE?
			game.Players.PlayerRemoving:Connect(function(plr)
				if (maxplayers > #game.Players:GetChildren() - 1) and (queuelist[1]) and (not (#game.Players:GetChildren()-1 <= 0)) and (not closing) and playerToWaitFor == "" then
					playerToWaitFor = queuelist[1]
					MessagingService:PublishAsync("TELEPORTREQUEST",http:JSONEncode({queuelist[1],game.JobId}))
					WaitForPlayer(plr)
				end
			end)
			
			game:BindToClose(function()
				closing = true
				MessagingService:PublishAsync("KICKREQUEST", queuelist)
			end)
			
			
		end
	end
end

return module
