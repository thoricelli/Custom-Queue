--[[
_________________________________________________________
__  /___  /_________________(_)_____________  /__  /__(_)   
_  __/_  __ \  __ \_  ___/_  /_  ___/  _ \_  /__  /__  /    
/ /_ _  / / / /_/ /  /   _  / / /__ /  __/  / _  / _  /     
\__/ /_/ /_/\____//_/    /_/  \___/ \___//_/  /_/  /_/      

Name: Custom Queue System
Date: 24/07/2020
File Description: Settings and function calling
]]

--SETTINGS--

local Admins = {}

--[[
Example:
local Admins = {69948947,6157007,31820308,24306216,26709627}

Their userId (found within the url) seperated by a , (With no , at the end)
]]

local UseGroup = false --Instead of using the admin value above it will check if the player is above the rank in a group
--TRUE: Uses group feature
--FALSE: Uses admin array

local MinimumRank = 70 --The rank number corospondending to the ranks. Every rank above will be allowed to be admin

local groupId = 901313 --The group Id

local DontTeleportAdmins = false --When joining a server, admins will not be teleported to the queue server (But people wont be able to join the queue if the server is full)

--SETTINGS--

--ADVANCED SETTINGS--

local SpotsReserved = 1

local RelaxingMusic = false --When true it will play relaxing music while waiting for the queue
local SoundVolume = 0.5 --Volume of the music
local SoundIds = {} --SoundId's that will be played, they are randomized.
--[[
Example:

local SoundIds = {455355502,4943258334,4921447628,1839541959,1841998846,1840535147}

The Id of the selected sound (found within the url) seperated by a , (With no , at the end)
]]

local DisplayServerId = true --Display the JobId of the server?
local DefaultTextJobId = "You are in the queue for server:" --Custom messages followed by a " AWAITING" or JOBID

local DisplayQueuePosition = true --Display the queue position?
local DefaultTextQueue = "Your position in queue:" --Custom message followed by a " AWAITING" or INT

--The queue will AUTOMATICALLY not show the GUI with any other private server if the teleportData is NOT a valid jobId
--However on the server side it will still listen for messages (Delete CustomQueue when not needed inside a specific private server)

wait() --Somehow game.Players.MaxPlayers doesn't load immediately
local maxplayers = game.Players.MaxPlayers - SpotsReserved --Maximum players -spots to be reserved to teleport them
--Increasing the reserved spots this will allow for more space and less bugs.

--ADVANCED SETTINGS--

local Components = require(script.Setup)

local QueueSystem = require(script.Main)

Components.SetUp(DefaultTextJobId,DisplayServerId,DisplayQueuePosition,DefaultTextQueue,RelaxingMusic,SoundVolume,SoundIds)
QueueSystem.Main(MinimumRank,groupId,DontTeleportAdmins,RelaxingMusic,UseGroup,Admins,maxplayers)