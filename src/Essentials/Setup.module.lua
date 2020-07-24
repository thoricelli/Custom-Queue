--[[
_________________________________________________________
__  /___  /_________________(_)_____________  /__  /__(_)   
_  __/_  __ \  __ \_  ___/_  /_  ___/  _ \_  /__  /__  /    
/ /_ _  / / / /_/ /  /   _  / / /__ /  __/  / _  / _  /     
\__/ /_/ /_/\____//_/    /_/  \___/ \___//_/  /_/  /_/      

Name: Custom Queue System
Date: 24/07/2020
File Description: Sets up the GUI and RemoteFunctions
]]

local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Http = game:GetService("HttpService")

function module.SetUp(DefaultTextJobId,DisplayServerId,DisplayQueuePosition,DefaultTextQueue,RelaxingMusic,SoundVolume,SoundIds)
	
	local IsQueueServer = Instance.new("BoolValue") --If you're already using a private server script this value will tell when not to interfere with the queue
	IsQueueServer.Value = false
	IsQueueServer.Name = "IsQueueServer"
	IsQueueServer.Parent = workspace
	
	local isPrivateServer = Instance.new("RemoteFunction")
	isPrivateServer.Name = "IsPrivateServer"
	isPrivateServer.Parent = ReplicatedStorage
	
	local JobIDToJoin = Instance.new("RemoteFunction")
	JobIDToJoin.Name = "JobIDToJoin"
	JobIDToJoin.Parent = ReplicatedStorage
	
	local QueuePosition = Instance.new("RemoteFunction")
	QueuePosition.Name = "QueuePosition"
	QueuePosition.Parent = ReplicatedStorage
	
	local QueueGui = Instance.new("ScreenGui")
	QueueGui.Name = "QueueGui"
	QueueGui.IgnoreGuiInset = true
	QueueGui.Enabled = false
	
	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(1,0,1,0)
	MainFrame.BackgroundColor3 = Color3.new(255, 255, 255)
	MainFrame.Parent = QueueGui
	
	local Settings = Instance.new("StringValue")
	Settings.Value = Http:JSONEncode({SoundIds,{DefaultTextQueue,DefaultTextJobId,DisplayQueuePosition,DisplayServerId}})
	Settings.Name = "Settings"
	Settings.Parent = QueueGui
	
	if (RelaxingMusic) then
		local Sound = Instance.new("Sound")
		Sound.Name = "RelaxingMusic"
		Sound.Volume = SoundVolume
		Sound.Parent = QueueGui
	end
	
	if (DisplayServerId) then
		local JobIdTextLabel = Instance.new("TextLabel")
		JobIdTextLabel.TextSize = 40
		JobIdTextLabel.TextColor3 = Color3.fromRGB(0,0,0)
		JobIdTextLabel.BackgroundTransparency = 1
		JobIdTextLabel.Font = Enum.Font.Arcade
		JobIdTextLabel.BorderSizePixel = 0
		JobIdTextLabel.Position = UDim2.new(0,0,0.446,0)
		JobIdTextLabel.Size = UDim2.new(1,0,0.097,0)
		JobIdTextLabel.Text = DefaultTextJobId.." AWAITING"
		JobIdTextLabel.Name = "JobId"
		JobIdTextLabel.Parent = MainFrame
	end
	
	if (DisplayQueuePosition) then
		local QueuePositionTextLabel = Instance.new("TextLabel")
		QueuePositionTextLabel.TextColor3 = Color3.fromRGB(0,0,0)
		QueuePositionTextLabel.Font = Enum.Font.Arcade
		QueuePositionTextLabel.TextSize = 40
		QueuePositionTextLabel.BackgroundTransparency = 1
		QueuePositionTextLabel.BorderSizePixel = 0
		QueuePositionTextLabel.Position = UDim2.new(0,0,0.544,0)
		QueuePositionTextLabel.Size = UDim2.new(1,0,0.108,0)
		QueuePositionTextLabel.Text = DefaultTextQueue.." AWAITING"
		QueuePositionTextLabel.Name = "QueuePosition"
		QueuePositionTextLabel.Parent = MainFrame
	end
	
	script.Parent.GuiUpdate.Parent = QueueGui
	
	QueueGui.Parent = StarterGui
	
	return
end

return module
