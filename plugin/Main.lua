-- MatiDev AI remote runtime v1.1.0
local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NAME, VERSION = "MatiDev AI", "v1.2.0"
local toolbar = plugin:CreateToolbar(NAME)
local toolbarButton = toolbar:CreateButton(NAME, "Open MatiDev AI", "")
toolbarButton.ClickableWhenViewportHidden = true
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, true, false, 500, 650, 400, 420)
local widget = plugin:CreateDockWidgetPluginGui("MatiDevAI_Main", widgetInfo)
widget.Title = NAME

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do obj[key] = value end
    obj.Parent = parent
    return obj
end
local function rounded(obj, radius, stroke)
    make("UICorner", {CornerRadius=UDim.new(0, radius)}, obj)
    if stroke then make("UIStroke", {Color=stroke, Transparency=0.55, Thickness=1}, obj) end
end
local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or .18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local colors = {
    background=Color3.fromRGB(11,14,21), panel=Color3.fromRGB(18,23,34), panel2=Color3.fromRGB(24,30,44),
    text=Color3.fromRGB(235,241,255), muted=Color3.fromRGB(137,149,175), blue=Color3.fromRGB(89,126,255),
    green=Color3.fromRGB(88,222,157), yellow=Color3.fromRGB(255,194,91), red=Color3.fromRGB(255,109,122)
}
local root = make("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=colors.background, BorderSizePixel=0}, widget)
local top = make("Frame", {Size=UDim2.new(1,0,0,76), BackgroundColor3=colors.panel, BorderSizePixel=0}, root)
make("UIGradient", {Color=ColorSequence.new(colors.panel2, colors.panel), Rotation=20}, top)
make("Frame", {Position=UDim2.new(0,0,1,-2), Size=UDim2.new(1,0,0,2), BackgroundColor3=colors.blue, BorderSizePixel=0}, top)
local logo = make("Frame", {Position=UDim2.new(0,18,0,17), Size=UDim2.new(0,40,0,40), BackgroundColor3=colors.blue, BorderSizePixel=0}, top)
rounded(logo, 12); make("UIGradient", {Color=ColorSequence.new(Color3.fromRGB(123,154,255), colors.blue), Rotation=45}, logo)
make("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="M", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=22}, logo)
make("TextLabel", {Position=UDim2.new(0,70,0,14), Size=UDim2.new(1,-90,0,25), BackgroundTransparency=1, Text=NAME, TextColor3=colors.text, Font=Enum.Font.GothamBold, TextSize=18, TextXAlignment=Enum.TextXAlignment.Left}, top)
make("TextLabel", {Position=UDim2.new(0,70,0,40), Size=UDim2.new(1,-90,0,18), BackgroundTransparency=1, Text=VERSION.."  •  Created by MatiDev", TextColor3=colors.muted, Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left}, top)
local statusDot = make("Frame", {Position=UDim2.new(1,-112,0,29), Size=UDim2.new(0,8,0,8), BackgroundColor3=colors.green, BorderSizePixel=0}, top); rounded(statusDot, 8)
local statusText = make("TextLabel", {Position=UDim2.new(1,-98,0,22), Size=UDim.new(0,84,0,22), BackgroundTransparency=1, Text="Ready", TextColor3=colors.green, Font=Enum.Font.GothamMedium, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left}, top)
local reloadButton = make("TextButton", {Position=UDim2.new(1,-190,0,22), Size=UDim2.new(0,78,0,28), BackgroundColor3=colors.panel2, BorderSizePixel=0, Text="Reload", TextColor3=colors.text, Font=Enum.Font.GothamBold, TextSize=10, AutoButtonColor=false}, top); rounded(reloadButton, 7, Color3.fromRGB(55,68,100))

local side = make("Frame", {Position=UDim2.new(0,0,0,76), Size=UDim2.new(0,142,1,-76), BackgroundColor3=colors.panel, BorderSizePixel=0}, root)
local sideTitle = make("TextLabel", {Position=UDim2.new(0,16,0,20), Size=UDim2.new(1,-32,0,18), BackgroundTransparency=1, Text="WORKSPACE", TextColor3=colors.muted, Font=Enum.Font.GothamBold, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left}, side)
local function nav(label, y, active)
    local button = make("TextButton", {Position=UDim2.new(0,10,0,y), Size=UDim2.new(1,-20,0,36), BackgroundColor3=active and Color3.fromRGB(42,56,95) or Color3.fromRGB(0,0,0), BackgroundTransparency=active and 0 or 1, BorderSizePixel=0, Text="  "..label, TextColor3=active and colors.text or colors.muted, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, side)
    rounded(button, 8)
    if active then make("Frame", {Position=UDim2.new(0,0,0,8), Size=UDim2.new(0,3,0,20), BackgroundColor3=colors.blue, BorderSizePixel=0}, button) end
    button.MouseEnter:Connect(function() if not active then tween(button, {BackgroundTransparency=.75}, .15) end end)
    button.MouseLeave:Connect(function() if not active then tween(button, {BackgroundTransparency=1}, .15) end end)
    return button
end
nav("Chat", 52, true); nav("Activity", 94, false); nav("Settings", 136, false)
make("TextLabel", {Position=UDim2.new(0,16,1,-54), Size=UDim2.new(1,-32,0,34), BackgroundTransparency=1, Text="LOCAL AGENT\nOllama + MCP Bridge", TextColor3=colors.muted, Font=Enum.Font.Code, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Bottom}, side)

local content = make("Frame", {Position=UDim2.new(0,142,0,76), Size=UDim2.new(1,-142,1,-76), BackgroundTransparency=1}, root)
local hero = make("Frame", {Position=UDim2.new(0,20,0,18), Size=UDim2.new(1,-40,0,74), BackgroundColor3=colors.panel2, BorderSizePixel=0}, content); rounded(hero, 12, Color3.fromRGB(55,68,100))
make("TextLabel", {Position=UDim2.new(0,16,0,12), Size=UDim2.new(1,-32,0,22), BackgroundTransparency=1, Text="What are we building today?", TextColor3=colors.text, Font=Enum.Font.GothamBold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left}, hero)
make("TextLabel", {Position=UDim2.new(0,16,0,38), Size=UDim2.new(1,-32,0,20), BackgroundTransparency=1, Text="Describe a feature, system, or complete Roblox game.", TextColor3=colors.muted, Font=Enum.Font.Gotham, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left}, hero)
local log = make("ScrollingFrame", {Position=UDim2.new(0,20,0,108), Size=UDim2.new(1,-40,1,-270), BackgroundColor3=colors.panel, BorderSizePixel=0, ScrollBarThickness=4, AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()}, content); rounded(log, 12, Color3.fromRGB(45,55,80))
make("UIPadding", {PaddingTop=UDim.new(0,14), PaddingBottom=UDim.new(0,14), PaddingLeft=UDim.new(0,14), PaddingRight=UDim.new(0,14)}, log)
make("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, log)
local input = make("TextBox", {Position=UDim2.new(0,20,1,-144), Size=UDim2.new(1,-40,0,78), BackgroundColor3=colors.panel2, BorderSizePixel=0, ClearTextOnFocus=false, MultiLine=true, PlaceholderText="Describe what you want to build...", Text="", TextColor3=colors.text, PlaceholderColor3=colors.muted, Font=Enum.Font.Gotham, TextSize=12, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, content); rounded(input, 12, Color3.fromRGB(55,68,100)); make("UIPadding", {PaddingTop=UDim.new(0,12), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12)}, input)
local apply = make("TextButton", {Position=UDim2.new(0,20,1,-54), Size=UDim2.new(0,112,0,34), BackgroundColor3=colors.panel2, BorderSizePixel=0, Text="Apply changes", TextColor3=colors.text, Font=Enum.Font.GothamBold, TextSize=11}, content); rounded(apply, 8, Color3.fromRGB(55,68,100))
local send = make("TextButton", {Position=UDim2.new(1,-132,1,-54), Size=UDim2.new(0,112,0,34), BackgroundColor3=colors.blue, BorderSizePixel=0, Text="Send  ↗", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=11}, content); rounded(send, 8)

local function addLog(text, color)
    local card = make("TextLabel", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Text=tostring(text), TextColor3=color or Color3.fromRGB(190,198,215), Font=Enum.Font.Code, TextSize=10, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left}, log)
    card.TextTransparency = 1; tween(card, {TextTransparency=0}, .22)
end
local function request(method, path, body)
    local options={Url="http://127.0.0.1:8765"..path, Method=method, Headers={["Content-Type"]="application/json"}}
    if body then options.Body=HttpService:JSONEncode(body) end
    return HttpService:RequestAsync(options)
end
local function resolvePath(path)
    local parts=string.split(path,"/"); local root=table.remove(parts,1)
    local parent=root=="StarterPlayerScripts" and game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts") or game:FindFirstChild(root)
    if not parent then error("Unsupported root: "..tostring(root)) end
    for i,name in ipairs(parts) do
        local final=i==#parts; local clean=final and string.gsub(name,"%.lua$","") or name
        local class=final and (root=="StarterPlayerScripts" and "LocalScript" or (string.find(clean,"Module") and "ModuleScript" or "Script")) or "Folder"
        local found=parent:FindFirstChild(clean)
        if not found then found=Instance.new(class); found.Name=clean; found.Parent=parent end
        parent=found
    end
    return parent
end
local function applyCommand(command)
    if command.op~="write_script" then error("Unsupported operation: "..tostring(command.op)) end
    local scriptObject=resolvePath(command.path); scriptObject.Source=command.source; ChangeHistoryService:SetWaypoint("MatiDev AI: "..command.path)
end
local function submit()
    if input.Text=="" then return end
    local taskText=input.Text; input.Text=""; addLog("> "..taskText, Color3.fromRGB(145,175,255)); statusText.Text="Working"; statusText.TextColor3=colors.yellow; statusDot.BackgroundColor3=colors.yellow
    local ok,res=pcall(function() return request("POST","/task",{task=taskText}) end)
    if not ok or not res.Success then addLog("Bridge unavailable. Run start-bridge.ps1.", colors.red); statusText.Text="Offline"; statusText.TextColor3=colors.red; statusDot.BackgroundColor3=colors.red end
end
send.MouseButton1Click:Connect(submit); input.FocusLost:Connect(function(enter) if enter then submit() end end)
apply.MouseButton1Click:Connect(function()
    local ok,res=pcall(function() return request("GET","/poll") end)
    if not ok or not res.Success then addLog("Could not connect to the bridge.", colors.red); return end
    local data=HttpService:JSONDecode(res.Body)
    if not data.command then addLog("No pending changes."); return end
    local done,err=pcall(function() applyCommand(data.command) end); pcall(function() request("POST","/result",{ok=done,error=err}) end)
    addLog(done and "✓ Applied: "..tostring(data.command.path) or "✕ Error: "..tostring(err), done and colors.green or colors.red)
end)
toolbarButton.Click:Connect(function() widget.Enabled=not widget.Enabled end)
reloadButton.MouseEnter:Connect(function() tween(reloadButton, {BackgroundColor3=colors.blue}, .15) end)
reloadButton.MouseLeave:Connect(function() tween(reloadButton, {BackgroundColor3=colors.panel2}, .15) end)
reloadButton.MouseButton1Click:Connect(function()
    if _G.MatiDevAI_Reload then _G.MatiDevAI_Reload() else addLog("Reload is available after installing the GitHub bootstrapper.", colors.muted) end
end)
local lastLogs=""; local phase=0
RunService.Heartbeat:Connect(function(dt)
    phase+=dt; if statusText.Text=="Working" then statusDot.BackgroundTransparency=.15+(math.sin(phase*5)+1)*.18 else statusDot.BackgroundTransparency=0 end
end)
task.spawn(function()
    while true do
        task.wait(1)
        local ok,res=pcall(function() return request("GET","/status") end)
        if ok and res.Success then
            local data=HttpService:JSONDecode(res.Body); statusText.Text=data.running and "Working" or (data.queued>0 and "Changes ready" or "Ready"); statusText.TextColor3=data.running and colors.yellow or colors.green; statusDot.BackgroundColor3=data.running and colors.yellow or colors.green
            local joined=table.concat(data.logs,"\n")
            if joined~=lastLogs then lastLogs=joined; for _,child in ipairs(log:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end; for _,line in ipairs(data.logs) do addLog(line) end end
        end
    end
end)
print(NAME.." "..VERSION.." loaded — Created by MatiDev")
_G.MatiDevAI_Cleanup = function()
    pcall(function() widget:Destroy() end)
    pcall(function() toolbarButton:Destroy() end)
end
