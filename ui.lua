--[[
    Advanced UI Library for Roblox
    Mobile Optimized & Feature Rich
    Created: 2025
]]--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}
Library.__index = Library

-- Configuration
local Config = {
    Theme = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 160),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
        Border = Color3.fromRGB(45, 45, 50),
    },
    Animation = {
        Speed = 0.3,
        EasingStyle = Enum.EasingStyle.Quint,
        EasingDirection = Enum.EasingDirection.Out
    },
    UI = {
        CornerRadius = 8,
        Padding = 10,
        MinimumSize = UDim2.new(0, 600, 0, 450),
        MobileSize = UDim2.new(0, 380, 0, 480),
    }
}

-- Utilities
local Utils = {}

function Utils:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utils:Tween(object, properties, duration)
    duration = duration or Config.Animation.Speed
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, Config.Animation.EasingStyle, Config.Animation.EasingDirection),
        properties
    )
    tween:Play()
    return tween
end

function Utils:CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Config.UI.CornerRadius)
    return corner
end

function Utils:CreateStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

function Utils:CreatePadding(all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all or Config.UI.Padding)
    padding.PaddingBottom = UDim.new(0, all or Config.UI.Padding)
    padding.PaddingLeft = UDim.new(0, all or Config.UI.Padding)
    padding.PaddingRight = UDim.new(0, all or Config.UI.Padding)
    return padding
end

function Utils:CreateGradient(colors)
    local gradient = Instance.new("UIGradient")
    if colors then
        local colorSequence = {}
        for i, color in ipairs(colors) do
            table.insert(colorSequence, ColorSequenceKeypoint.new((i-1)/(#colors-1), color))
        end
        gradient.Color = ColorSequence.new(colorSequence)
    end
    gradient.Rotation = 90
    return gradient
end

function Utils:Ripple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.BorderSizePixel = 0
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    
    local corner = Utils:CreateCorner(999)
    corner.Parent = ripple
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Utils:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- Notification System
local NotificationManager = {}
NotificationManager.Queue = {}
NotificationManager.Container = nil

function NotificationManager:Init(parent)
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(1, -20, 0, 20)
    container.Size = UDim2.new(0, 300, 1, -40)
    container.AnchorPoint = Vector2.new(1, 0)
    container.ZIndex = 1000
    container.Parent = parent
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = container
    
    self.Container = container
end

function NotificationManager:Send(title, message, duration, notifType)
    duration = duration or 3
    notifType = notifType or "info"
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = Config.Theme.Secondary
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.ClipsDescendants = true
    notification.ZIndex = 1001
    notification.Parent = self.Container
    
    Utils:CreateCorner(8).Parent = notification
    Utils:CreateStroke(Config.Theme.Border, 1).Parent = notification
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "Accent"
    accentBar.BackgroundColor3 = notifType == "success" and Config.Theme.Success or 
                                  notifType == "warning" and Config.Theme.Warning or
                                  notifType == "error" and Config.Theme.Error or
                                  Config.Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Parent = notification
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.BackgroundTransparency = 1
    contentContainer.Position = UDim2.new(0, 14, 0, 0)
    contentContainer.Size = UDim2.new(1, -14, 1, 0)
    contentContainer.Parent = notification
    
    Utils:CreatePadding(10).Parent = contentContainer
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Config.Theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = contentContainer
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 0, 0, 25)
    messageLabel.Size = UDim2.new(1, 0, 0, 35)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Text = message
    messageLabel.TextColor3 = Config.Theme.TextDark
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = contentContainer
    
    -- Animate in
    notification.Position = UDim2.new(1, 20, 0, 0)
    notification.Size = UDim2.new(1, 0, 0, 70)
    Utils:Tween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    
    -- Auto dismiss
    task.delay(duration, function()
        Utils:Tween(notification, {
            Position = UDim2.new(1, 20, 0, 0),
            Size = UDim2.new(1, 0, 0, 0)
        }, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- Main Library
function Library:New(config)
    local window = {}
    
    config = config or {}
    config.Name = config.Name or "UI Library"
    config.Icon = config.Icon or "rbxassetid://7733964719"
    config.SaveConfig = config.SaveConfig ~= false
    config.IntroEnabled = config.IntroEnabled ~= false
    config.KeySystem = config.KeySystem or false
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedUI_" .. math.random(1000, 9999)
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Config.Theme.Background
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Size = Utils:IsMobile() and Config.UI.MobileSize or Config.UI.MinimumSize
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    Utils:CreateCorner(12).Parent = mainFrame
    Utils:CreateStroke(Config.Theme.Border, 2).Parent = mainFrame
    
    -- Drop Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.BackgroundColor3 = Config.Theme.Secondary
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.Parent = mainFrame
    
    local topBarCorner = Utils:CreateCorner(12)
    topBarCorner.Parent = topBar
    
    -- Cover bottom corners of topbar
    local topBarCover = Instance.new("Frame")
    topBarCover.BackgroundColor3 = Config.Theme.Secondary
    topBarCover.BorderSizePixel = 0
    topBarCover.Position = UDim2.new(0, 0, 1, -12)
    topBarCover.Size = UDim2.new(1, 0, 0, 12)
    topBarCover.Parent = topBar
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 15, 0.5, 0)
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Image = config.Icon
    icon.Parent = topBar
    
    Utils:CreateCorner(6).Parent = icon
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 50, 0, 0)
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = config.Name
    titleLabel.TextColor3 = Config.Theme.Text
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.BackgroundColor3 = Config.Theme.Error
    closeBtn.Position = UDim2.new(1, -40, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Config.Theme.Text
    closeBtn.TextSize = 20
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = topBar
    
    Utils:CreateCorner(6).Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        Utils:Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 91, 91)})
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utils:Tween(closeBtn, {BackgroundColor3 = Config.Theme.Error})
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        local pos = closeBtn.AbsolutePosition
        Utils:Ripple(closeBtn, closeBtn.AbsoluteSize.X/2, closeBtn.AbsoluteSize.Y/2)
        Utils:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        screenGui:Destroy()
    end)
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.BackgroundColor3 = Config.Theme.Warning
    minimizeBtn.Position = UDim2.new(1, -75, 0.5, 0)
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.AnchorPoint = Vector2.new(0, 0.5)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Config.Theme.Text
    minimizeBtn.TextSize = 20
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = topBar
    
    Utils:CreateCorner(6).Parent = minimizeBtn
    
    local minimized = false
    local originalSize = mainFrame.Size
    
    minimizeBtn.MouseEnter:Connect(function()
        Utils:Tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(255, 186, 46)})
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        Utils:Tween(minimizeBtn, {BackgroundColor3 = Config.Theme.Warning})
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        Utils:Ripple(minimizeBtn, minimizeBtn.AbsoluteSize.X/2, minimizeBtn.AbsoluteSize.Y/2)
        minimized = not minimized
        if minimized then
            originalSize = mainFrame.Size
            Utils:Tween(mainFrame, {Size = UDim2.new(0, mainFrame.AbsoluteSize.X, 0, 50)})
        else
            Utils:Tween(mainFrame, {Size = originalSize})
        end
    end)
    
    -- Drag functionality
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Utils:Tween(mainFrame, {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }, 0.1)
    end
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = Config.Theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.Size = UDim2.new(0, Utils:IsMobile() and 60 or 150, 1, -50)
    tabContainer.Parent = mainFrame
    
    Utils:CreatePadding(10).Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.BackgroundTransparency = 1
    contentContainer.Position = UDim2.new(0, Utils:IsMobile() and 60 or 150, 0, 50)
    contentContainer.Size = UDim2.new(1, Utils:IsMobile() and -60 or -150, 1, -50)
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame
    
    -- Initialize Notifications
    NotificationManager:Init(screenGui)
    
    -- Intro Animation
    if config.IntroEnabled then
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        task.wait(0.1)
        Utils:Tween(mainFrame, {Size = Utils:IsMobile() and Config.UI.MobileSize or Config.UI.MinimumSize}, 0.5)
    end
    
    window.Tabs = {}
    window.ScreenGui = screenGui
    window.MainFrame = mainFrame
    window.TabContainer = tabContainer
    window.ContentContainer = contentContainer
    
    function window:Notify(title, message, duration, notifType)
        NotificationManager:Send(title, message, duration, notifType)
    end
    
    function window:CreateTab(tabConfig)
        local tab = {}
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or "rbxassetid://7733673345"
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabConfig.Name
        tabButton.BackgroundColor3 = Config.Theme.Background
        tabButton.BackgroundTransparency = 1
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = ""
        tabButton.TextColor3 = Config.Theme.TextDark
        tabButton.TextSize = 14
        tabButton.AutoButtonColor = false
        tabButton.ClipsDescendants = true
        tabButton.Parent = tabContainer
        
        -- Tab Icon
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "Icon"
        tabIcon.BackgroundTransparency = 1
        tabIcon.Position = Utils:IsMobile() and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 10, 0.5, 0)
        tabIcon.Size = UDim2.new(0, 20, 0, 20)
        tabIcon.AnchorPoint = Utils:IsMobile() and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5)
        tabIcon.Image = tabConfig.Icon
        tabIcon.ImageColor3 = Config.Theme.TextDark
        tabIcon.Parent = tabButton
        
        -- Tab Label (hidden on mobile)
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.BackgroundTransparency = 1
        tabLabel.Position = UDim2.new(0, 40, 0, 0)
        tabLabel.Size = UDim2.new(1, -40, 1, 0)
        tabLabel.Font = Enum.Font.Gotham
        tabLabel.Text = tabConfig.Name
        tabLabel.TextColor3 = Config.Theme.TextDark
        tabLabel.TextSize = 13
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Visible = not Utils:IsMobile()
        tabLabel.Parent = tabButton
        
        -- Selection Indicator
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.BackgroundColor3 = Config.Theme.Accent
        indicator.BorderSizePixel = 0
        indicator.Position = UDim2.new(0, 0, 0.5, 0)
        indicator.Size = UDim2.new(0, 0, 0, 0)
        indicator.AnchorPoint = Vector2.new(0, 0.5)
        indicator.Parent = tabButton
        
        Utils:CreateCorner(999).Parent = indicator
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabConfig.Name .. "_Content"
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Config.Theme.Accent
        tabContent.BorderSizePixel = 0
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        Utils:CreatePadding(15).Parent = tabContent
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab Selection
        local function selectTab()
            for _, otherTab in pairs(window.Tabs) do
                otherTab.Button.BackgroundTransparency = 1
                otherTab.Icon.ImageColor3 = Config.Theme.TextDark
                otherTab.Label.TextColor3 = Config.Theme.TextDark
                Utils:Tween(otherTab.Indicator, {Size = UDim2.new(0, 0, 0, 0)})
                otherTab.Content.Visible = false
            end
            
            tabButton.BackgroundTransparency = 0.9
            tabIcon.ImageColor3 = Config.Theme.Accent
            tabLabel.TextColor3 = Config.Theme.Accent
            Utils:Tween(indicator, {Size = UDim2.new(0, 3, 0, 30)})
            tabContent.Visible = true
        end
        
        tabButton.MouseButton1Click:Connect(function()
            Utils:Ripple(tabButton, tabButton.AbsoluteSize.X/2, tabButton.AbsoluteSize.Y/2)
            selectTab()
        end)
        
        tabButton.MouseEnter:Connect(function()
            if tabContent.Visible == false then
                Utils:Tween(tabButton, {BackgroundTransparency = 0.95})
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabContent.Visible == false then
                Utils:Tween(tabButton, {BackgroundTransparency = 1})
            end
        end)
        
        -- Auto-select first tab
        if #window.Tabs == 0 then
            task.wait(0.1)
            selectTab()
        end
        
        tab.Button = tabButton
        tab.Icon = tabIcon
        tab.Label = tabLabel
        tab.Indicator = indicator
        tab.Content = tabContent
        tab.Elements = {}
        
        table.insert(window.Tabs, tab)
        
        -- Tab Elements
        function tab:CreateButton(buttonConfig)
            buttonConfig = buttonConfig or {}
            buttonConfig.Name = buttonConfig.Name or "Button"
            buttonConfig.Callback = buttonConfig.Callback or function() end
            
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.BackgroundColor3 = Config.Theme.Secondary
            button.Size = UDim2.new(1, 0, 0, 40)
            button.Font = Enum.Font.Gotham
            button.Text = ""
            button.AutoButtonColor = false
            button.ClipsDescendants = true
            button.Parent = tabContent
            
            Utils:CreateCorner(8).Parent = button
            Utils:CreatePadding(12).Parent = button
            
            local buttonLabel = Instance.new("TextLabel")
            buttonLabel.Name = "Label"
            buttonLabel.BackgroundTransparency = 1
            buttonLabel.Size = UDim2.new(1, 0, 1, 0)
            buttonLabel.Font = Enum.Font.GothamMedium
            buttonLabel.Text = buttonConfig.Name
            buttonLabel.TextColor3 = Config.Theme.Text
            buttonLabel.TextSize = 14
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
            buttonLabel.Parent = button
            
            button.MouseEnter:Connect(function()
                Utils:Tween(button, {BackgroundColor3 = Config.Theme.Border})
            end)
            
            button.MouseLeave:Connect(function()
                Utils:Tween(button, {BackgroundColor3 = Config.Theme.Secondary})
            end)
            
            button.MouseButton1Click:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local relativeX = mousePos.X - button.AbsolutePosition.X
                local relativeY = mousePos.Y - button.AbsolutePosition.Y - 36
                Utils:Ripple(button, relativeX, relativeY)
                
                pcall(buttonConfig.Callback)
            end)
            
            return button
        end
        
        function tab:CreateToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            toggleConfig.Name = toggleConfig.Name or "Toggle"
            toggleConfig.Default = toggleConfig.Default or false
            toggleConfig.Callback = toggleConfig.Callback or function() end
            
            local toggleState = toggleConfig.Default
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = "Toggle"
            toggleFrame.BackgroundColor3 = Config.Theme.Secondary
            toggleFrame.Size = UDim2.new(1, 0, 0, 40)
            toggleFrame.Parent = tabContent
            
            Utils:CreateCorner(8).Parent = toggleFrame
            Utils:CreatePadding(12).Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Name = "Label"
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Size = UDim2.new(1, -50, 1, 0)
            toggleLabel.Font = Enum.Font.GothamMedium
            toggleLabel.Text = toggleConfig.Name
            toggleLabel.TextColor3 = Config.Theme.Text
            toggleLabel.TextSize = 14
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "Button"
            toggleButton.BackgroundColor3 = toggleState and Config.Theme.Accent or Config.Theme.Border
            toggleButton.Position = UDim2.new(1, -40, 0.5, 0)
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.AnchorPoint = Vector2.new(0, 0.5)
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = false
            toggleButton.Parent = toggleFrame
            
            Utils:CreateCorner(999).Parent = toggleButton
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Name = "Circle"
            toggleCircle.BackgroundColor3 = Config.Theme.Text
            toggleCircle.Position = toggleState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
            toggleCircle.Parent = toggleButton
            
            Utils:CreateCorner(999).Parent = toggleCircle
            
            local function updateToggle()
                toggleState = not toggleState
                Utils:Tween(toggleButton, {
                    BackgroundColor3 = toggleState and Config.Theme.Accent or Config.Theme.Border
                })
                Utils:Tween(toggleCircle, {
                    Position = toggleState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                })
                pcall(toggleConfig.Callback, toggleState)
            end
            
            toggleButton.MouseButton1Click:Connect(updateToggle)
            
            toggleFrame.MouseEnter:Connect(function()
                Utils:Tween(toggleFrame, {BackgroundColor3 = Config.Theme.Border})
            end)
            
            toggleFrame.MouseLeave:Connect(function()
                Utils:Tween(toggleFrame, {BackgroundColor3 = Config.Theme.Secondary})
            end)
            
            return {
                Frame = toggleFrame,
                SetValue = function(value)
                    if value ~= toggleState then
                        updateToggle()
                    end
                end,
                GetValue = function()
                    return toggleState
                end
            }
        end
        
        function tab:CreateSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            sliderConfig.Name = sliderConfig.Name or "Slider"
            sliderConfig.Min = sliderConfig.Min or 0
            sliderConfig.Max = sliderConfig.Max or 100
            sliderConfig.Default = sliderConfig.Default or sliderConfig.Min
            sliderConfig.Increment = sliderConfig.Increment or 1
            sliderConfig.Callback = sliderConfig.Callback or function() end
            
            local sliderValue = sliderConfig.Default
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = "Slider"
            sliderFrame.BackgroundColor3 = Config.Theme.Secondary
            sliderFrame.Size = UDim2.new(1, 0, 0, 55)
            sliderFrame.Parent = tabContent
            
            Utils:CreateCorner(8).Parent = sliderFrame
            Utils:CreatePadding(12).Parent = sliderFrame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Name = "Label"
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Size = UDim2.new(1, -50, 0, 20)
            sliderLabel.Font = Enum.Font.GothamMedium
            sliderLabel.Text = sliderConfig.Name
            sliderLabel.TextColor3 = Config.Theme.Text
            sliderLabel.TextSize = 14
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Name = "Value"
            valueLabel.BackgroundTransparency = 1
            valueLabel.Position = UDim2.new(1, -50, 0, 0)
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.Text = tostring(sliderValue)
            valueLabel.TextColor3 = Config.Theme.Accent
            valueLabel.TextSize = 14
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Name = "Bar"
            sliderBar.BackgroundColor3 = Config.Theme.Border
            sliderBar.Position = UDim2.new(0, 0, 1, -15)
            sliderBar.Size = UDim2.new(1, 0, 0, 6)
            sliderBar.Parent = sliderFrame
            
            Utils:CreateCorner(999).Parent = sliderBar
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.BackgroundColor3 = Config.Theme.Accent
            sliderFill.Size = UDim2.new((sliderValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar
            
            Utils:CreateCorner(999).Parent = sliderFill
            
            local draggingSlider = false
            
            local function updateSlider(input)
                local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                sliderValue = math.floor(((sliderConfig.Max - sliderConfig.Min) * relativeX + sliderConfig.Min) / sliderConfig.Increment + 0.5) * sliderConfig.Increment
                sliderValue = math.clamp(sliderValue, sliderConfig.Min, sliderConfig.Max)
                
                valueLabel.Text = tostring(sliderValue)
                Utils:Tween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1)
                pcall(sliderConfig.Callback, sliderValue)
            end
            
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateSlider(input)
                end
            end)
            
            sliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            return {
                Frame = sliderFrame,
                SetValue = function(value)
                    sliderValue = math.clamp(value, sliderConfig.Min, sliderConfig.Max)
                    valueLabel.Text = tostring(sliderValue)
                    local relativeX = (sliderValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                    Utils:Tween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)})
                end,
                GetValue = function()
                    return sliderValue
                end
            }
        end
        
        function tab:CreateDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
            dropdownConfig.Options = dropdownConfig.Options or {"Option 1", "Option 2"}
            dropdownConfig.Default = dropdownConfig.Default or dropdownConfig.Options[1]
            dropdownConfig.Callback = dropdownConfig.Callback or function() end
            
            local selectedOption = dropdownConfig.Default
            local isOpen = false
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "Dropdown"
            dropdownFrame.BackgroundColor3 = Config.Theme.Secondary
            dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.Parent = tabContent
            
            Utils:CreateCorner(8).Parent = dropdownFrame
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Name = "Button"
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Size = UDim2.new(1, 0, 0, 40)
            dropdownButton.Text = ""
            dropdownButton.AutoButtonColor = false
            dropdownButton.Parent = dropdownFrame
            
            Utils:CreatePadding(12).Parent = dropdownButton
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Name = "Label"
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Size = UDim2.new(1, -30, 1, 0)
            dropdownLabel.Font = Enum.Font.GothamMedium
            dropdownLabel.Text = dropdownConfig.Name .. ": " .. selectedOption
            dropdownLabel.TextColor3 = Config.Theme.Text
            dropdownLabel.TextSize = 14
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Parent = dropdownButton
            
            local arrow = Instance.new("TextLabel")
            arrow.Name = "Arrow"
            arrow.BackgroundTransparency = 1
            arrow.Position = UDim2.new(1, -20, 0.5, 0)
            arrow.Size = UDim2.new(0, 20, 0, 20)
            arrow.AnchorPoint = Vector2.new(0, 0.5)
            arrow.Font = Enum.Font.GothamBold
            arrow.Text = "▼"
            arrow.TextColor3 = Config.Theme.TextDark
            arrow.TextSize = 12
            arrow.Parent = dropdownButton
            
            local optionsContainer = Instance.new("Frame")
            optionsContainer.Name = "Options"
            optionsContainer.BackgroundTransparency = 1
            optionsContainer.Position = UDim2.new(0, 0, 0, 40)
            optionsContainer.Size = UDim2.new(1, 0, 1, -40)
            optionsContainer.Parent = dropdownFrame
            
            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Padding = UDim.new(0, 2)
            optionsLayout.Parent = optionsContainer
            
            for _, option in ipairs(dropdownConfig.Options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = option
                optionButton.BackgroundColor3 = Config.Theme.Border
                optionButton.BackgroundTransparency = 0.5
                optionButton.Size = UDim2.new(1, -4, 0, 35)
                optionButton.Position = UDim2.new(0, 2, 0, 0)
                optionButton.Font = Enum.Font.Gotham
                optionButton.Text = option
                optionButton.TextColor3 = Config.Theme.Text
                optionButton.TextSize = 13
                optionButton.AutoButtonColor = false
                optionButton.Parent = optionsContainer
                
                Utils:CreateCorner(6).Parent = optionButton
                
                optionButton.MouseEnter:Connect(function()
                    Utils:Tween(optionButton, {BackgroundTransparency = 0})
                end)
                
                optionButton.MouseLeave:Connect(function()
                    Utils:Tween(optionButton, {BackgroundTransparency = 0.5})
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    dropdownLabel.Text = dropdownConfig.Name .. ": " .. selectedOption
                    isOpen = false
                    Utils:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)})
                    Utils:Tween(arrow, {Rotation = 0})
                    pcall(dropdownConfig.Callback, selectedOption)
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetSize = isOpen and UDim2.new(1, 0, 0, 40 + (#dropdownConfig.Options * 37) + 5) or UDim2.new(1, 0, 0, 40)
                Utils:Tween(dropdownFrame, {Size = targetSize})
                Utils:Tween(arrow, {Rotation = isOpen and 180 or 0})
            end)
            
            return {
                Frame = dropdownFrame,
                SetValue = function(value)
                    if table.find(dropdownConfig.Options, value) then
                        selectedOption = value
                        dropdownLabel.Text = dropdownConfig.Name .. ": " .. selectedOption
                    end
                end,
                GetValue = function()
                    return selectedOption
                end
            }
        end
        
        function tab:CreateTextbox(textboxConfig)
            textboxConfig = textboxConfig or {}
            textboxConfig.Name = textboxConfig.Name or "Textbox"
            textboxConfig.Default = textboxConfig.Default or ""
            textboxConfig.Placeholder = textboxConfig.Placeholder or "Enter text..."
            textboxConfig.Callback = textboxConfig.Callback or function() end
            
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = "Textbox"
            textboxFrame.BackgroundColor3 = Config.Theme.Secondary
            textboxFrame.Size = UDim2.new(1, 0, 0, 70)
            textboxFrame.Parent = tabContent
            
            Utils:CreateCorner(8).Parent = textboxFrame
            Utils:CreatePadding(12).Parent = textboxFrame
            
            local textboxLabel = Instance.new("TextLabel")
            textboxLabel.Name = "Label"
            textboxLabel.BackgroundTransparency = 1
            textboxLabel.Size = UDim2.new(1, 0, 0, 20)
            textboxLabel.Font = Enum.Font.GothamMedium
            textboxLabel.Text = textboxConfig.Name
            textboxLabel.TextColor3 = Config.Theme.Text
            textboxLabel.TextSize = 14
            textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            textboxLabel.Parent = textboxFrame
            
            local textboxInput = Instance.new("TextBox")
            textboxInput.Name = "Input"
            textboxInput.BackgroundColor3 = Config.Theme.Border
            textboxInput.Position = UDim2.new(0, 0, 0, 28)
            textboxInput.Size = UDim2.new(1, 0, 0, 30)
            textboxInput.Font = Enum.Font.Gotham
            textboxInput.Text = textboxConfig.Default
            textboxInput.PlaceholderText = textboxConfig.Placeholder
            textboxInput.TextColor3 = Config.Theme.Text
            textboxInput.PlaceholderColor3 = Config.Theme.TextDark
            textboxInput.TextSize = 13
            textboxInput.ClearButtonEnabled = true
            textboxInput.Parent = textboxFrame
            
            Utils:CreateCorner(6).Parent = textboxInput
            Utils:CreatePadding(8).Parent = textboxInput
            
            textboxInput.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    pcall(textboxConfig.Callback, textboxInput.Text)
                end
            end)
            
            return {
                Frame = textboxFrame,
                SetValue = function(value)
                    textboxInput.Text = value
                end,
                GetValue = function()
                    return textboxInput.Text
                end
            }
        end
        
        function tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.BackgroundColor3 = Config.Theme.Secondary
            label.Size = UDim2.new(1, 0, 0, 35)
            label.Font = Enum.Font.Gotham
            label.Text = text or "Label"
            label.TextColor3 = Config.Theme.TextDark
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = tabContent
            
            Utils:CreateCorner(8).Parent = label
            Utils:CreatePadding(12).Parent = label
            
            return {
                Frame = label,
                SetText = function(newText)
                    label.Text = newText
                end
            }
        end
        
        function tab:CreateSection(text)
            local section = Instance.new("Frame")
            section.Name = "Section"
            section.BackgroundTransparency = 1
            section.Size = UDim2.new(1, 0, 0, 30)
            section.Parent = tabContent
            
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Name = "Label"
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Size = UDim2.new(1, 0, 1, 0)
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.Text = text or "Section"
            sectionLabel.TextColor3 = Config.Theme.Text
            sectionLabel.TextSize = 15
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = section
            
            return section
        end
        
        function tab:CreateColorPicker(colorConfig)
            colorConfig = colorConfig or {}
            colorConfig.Name = colorConfig.Name or "Color Picker"
            colorConfig.Default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
            colorConfig.Callback = colorConfig.Callback or function() end
            
            local selectedColor = colorConfig.Default
            local pickerOpen = false
            
            local colorFrame = Instance.new("Frame")
            colorFrame.Name = "ColorPicker"
            colorFrame.BackgroundColor3 = Config.Theme.Secondary
            colorFrame.Size = UDim2.new(1, 0, 0, 40)
            colorFrame.ClipsDescendants = true
            colorFrame.Parent = tabContent
            
            Utils:CreateCorner(8).Parent = colorFrame
            Utils:CreatePadding(12).Parent = colorFrame
            
            local colorLabel = Instance.new("TextLabel")
            colorLabel.Name = "Label"
            colorLabel.BackgroundTransparency = 1
            colorLabel.Size = UDim2.new(1, -50, 1, 0)
            colorLabel.Font = Enum.Font.GothamMedium
            colorLabel.Text = colorConfig.Name
            colorLabel.TextColor3 = Config.Theme.Text
            colorLabel.TextSize = 14
            colorLabel.TextXAlignment = Enum.TextXAlignment.Left
            colorLabel.Parent = colorFrame
            
            local colorDisplay = Instance.new("TextButton")
            colorDisplay.Name = "Display"
            colorDisplay.BackgroundColor3 = selectedColor
            colorDisplay.Position = UDim2.new(1, -35, 0.5, 0)
            colorDisplay.Size = UDim2.new(0, 28, 0, 28)
            colorDisplay.AnchorPoint = Vector2.new(0, 0.5)
            colorDisplay.Text = ""
            colorDisplay.AutoButtonColor = false
            colorDisplay.Parent = colorFrame
            
            Utils:CreateCorner(6).Parent = colorDisplay
            Utils:CreateStroke(Config.Theme.Border, 2).Parent = colorDisplay
            
            -- Color Picker Panel
            local pickerPanel = Instance.new("Frame")
            pickerPanel.Name = "PickerPanel"
            pickerPanel.BackgroundColor3 = Config.Theme.Border
            pickerPanel.Position = UDim2.new(0, 5, 0, 45)
            pickerPanel.Size = UDim2.new(1, -10, 0, 180)
            pickerPanel.Parent = colorFrame
            
            Utils:CreateCorner(8).Parent = pickerPanel
            Utils:CreatePadding(10).Parent = pickerPanel
            
            -- Saturation/Value Picker
            local svPicker = Instance.new("ImageButton")
            svPicker.Name = "SVPicker"
            svPicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            svPicker.Size = UDim2.new(1, -50, 1, -20)
            svPicker.AutoButtonColor = false
            svPicker.Parent = pickerPanel
            
            Utils:CreateCorner(6).Parent = svPicker
            
            local svGradient = Instance.new("UIGradient")
            svGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
            })
            svGradient.Rotation = 90
            svGradient.Parent = svPicker
            
            local svOverlay = Instance.new("Frame")
            svOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            svOverlay.BackgroundTransparency = 0
            svOverlay.Size = UDim2.new(1, 0, 1, 0)
            svOverlay.Parent = svPicker
            
            Utils:CreateCorner(6).Parent = svOverlay
            
            local svOverlayGradient = Instance.new("UIGradient")
            svOverlayGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            })
            svOverlayGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            svOverlayGradient.Rotation = 0
            svOverlayGradient.Parent = svOverlay
            
            -- Cursor
            local cursor = Instance.new("Frame")
            cursor.Name = "Cursor"
            cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            cursor.BorderSizePixel = 0
            cursor.Size = UDim2.new(0, 8, 0, 8)
            cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            cursor.Position = UDim2.new(0, 0, 1, 0)
            cursor.ZIndex = 5
            cursor.Parent = svPicker
            
            Utils:CreateCorner(999).Parent = cursor
            Utils:CreateStroke(Color3.fromRGB(0, 0, 0), 2).Parent = cursor
            
            -- Hue Slider
            local hueSlider = Instance.new("ImageButton")
            hueSlider.Name = "HueSlider"
            hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hueSlider.Position = UDim2.new(1, -35, 0, 0)
            hueSlider.Size = UDim2.new(0, 35, 1, -20)
            hueSlider.AutoButtonColor = false
            hueSlider.Parent = pickerPanel
            
            Utils:CreateCorner(6).Parent = hueSlider
            
            local hueGradient = Instance.new("UIGradient")
            hueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            hueGradient.Rotation = 90
            hueGradient.Parent = hueSlider
            
            local hueIndicator = Instance.new("Frame")
            hueIndicator.Name = "Indicator"
            hueIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hueIndicator.BorderSizePixel = 0
            hueIndicator.Size = UDim2.new(1, 0, 0, 3)
            hueIndicator.AnchorPoint = Vector2.new(0, 0.5)
            hueIndicator.Position = UDim2.new(0, 0, 0, 0)
            hueIndicator.Parent = hueSlider
            
            Utils:CreateStroke(Color3.fromRGB(0, 0, 0), 1).Parent = hueIndicator
            
            -- RGB Display
            local rgbDisplay = Instance.new("TextLabel")
            rgbDisplay.Name = "RGBDisplay"
            rgbDisplay.BackgroundColor3 = Config.Theme.Background
            rgbDisplay.Position = UDim2.new(0, 0, 1, -15)
            rgbDisplay.Size = UDim2.new(1, 0, 0, 15)
            rgbDisplay.Font = Enum.Font.GothamMedium
            rgbDisplay.Text = string.format("RGB: %d, %d, %d", selectedColor.R * 255, selectedColor.G * 255, selectedColor.B * 255)
            rgbDisplay.TextColor3 = Config.Theme.TextDark
            rgbDisplay.TextSize = 11
            rgbDisplay.Parent = pickerPanel
            
            Utils:CreateCorner(4).Parent = rgbDisplay
            
            -- Color logic
            local hue, sat, val = 0, 1, 1
            
            local function updateColor()
                local function HSVToRGB(h, s, v)
                    local r, g, b
                    local i = math.floor(h * 6)
                    local f = h * 6 - i
                    local p = v * (1 - s)
                    local q = v * (1 - f * s)
                    local t = v * (1 - (1 - f) * s)
                    i = i % 6
                    
                    if i == 0 then r, g, b = v, t, p
                    elseif i == 1 then r, g, b = q, v, p
                    elseif i == 2 then r, g, b = p, v, t
                    elseif i == 3 then r, g, b = p, q, v
                    elseif i == 4 then r, g, b = t, p, v
                    elseif i == 5 then r, g, b = v, p, q
                    end
                    
                    return Color3.fromRGB(r * 255, g * 255, b * 255)
                end
                
                local hueColor = HSVToRGB(hue, 1, 1)
                svPicker.BackgroundColor3 = hueColor
                
                selectedColor = HSVToRGB(hue, sat, val)
                colorDisplay.BackgroundColor3 = selectedColor
                rgbDisplay.Text = string.format("RGB: %d, %d, %d", 
                    math.floor(selectedColor.R * 255), 
                    math.floor(selectedColor.G * 255), 
                    math.floor(selectedColor.B * 255))
                
                pcall(colorConfig.Callback, selectedColor)
            end
            
            local draggingSV = false
            local draggingHue = false
            
            svPicker.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = true
                    local relativeX = math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                    local relativeY = math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                    sat = relativeX
                    val = 1 - relativeY
                    cursor.Position = UDim2.new(relativeX, 0, relativeY, 0)
                    updateColor()
                end
            end)
            
            svPicker.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relativeX = math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                    local relativeY = math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                    sat = relativeX
                    val = 1 - relativeY
                    cursor.Position = UDim2.new(relativeX, 0, relativeY, 0)
                    updateColor()
                end
            end)
            
            hueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true
                    local relativeY = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                    hue = relativeY
                    hueIndicator.Position = UDim2.new(0, 0, relativeY, 0)
                    updateColor()
                end
            end)
            
            hueSlider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relativeY = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                    hue = relativeY
                    hueIndicator.Position = UDim2.new(0, 0, relativeY, 0)
                    updateColor()
                end
            end)
            
            colorDisplay.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                local targetSize = pickerOpen and UDim2.new(1, 0, 0, 230) or UDim2.new(1, 0, 0, 40)
                Utils:Tween(colorFrame, {Size = targetSize})
            end)
            
            updateColor()
            
            return {
                Frame = colorFrame,
                SetValue = function(color)
                    selectedColor = color
                    colorDisplay.BackgroundColor3 = color
                    updateColor()
                end,
                GetValue = function()
                    return selectedColor
                end
            }
        end
        
        return tab
    end
    
    return window
end

return Library
