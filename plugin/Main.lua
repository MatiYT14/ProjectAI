-- ProjectAI Studio v1.0: docked AI panel + local MCP bridge
local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PLUGIN_NAME = "MatiDev AI"
local VERSION = "v1.0.0"
local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local button = toolbar:CreateButton(PLUGIN_NAME, "Open MatiDev AI assistant", "")
button.ClickableWhenViewportHidden = true
local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, true, false, 390, 560, 300, 300)
local widget = plugin:CreateDockWidgetPluginGui("ProjectAI_V1", info)
widget.Title = "ProjectAI • Roblox Developer"

local function new(class, props, parent)
    local x = Instance.new(class)
    for k, v in pairs(props or {}) do x[k] = v end
    x.Parent = parent
    return x
end
local bg = new("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.fromRGB(15,18,25), BorderSizePixel=0}, widget)
local header = new("Frame", {Size=UDim2.new(1,0,0,58), BackgroundColor3=Color3.fromRGB(23,28,40), BorderSizePixel=0}, bg)
new("UIGradient", {Color=ColorSequence.new(Color3.fromRGB(36,52,86), Color3.fromRGB(23,28,40)), Rotation=25}, header)
new("Frame", {Position=UDim2.new(0,0,1,-2), Size=UDim2.new(1,0,0,2), BackgroundColor3=Color3.fromRGB(76,125,255), BorderSizePixel=0}, header)
new("TextLabel", {Position=UDim2.new(0,18,0,6), Size=UDim2.new(1,-36,0,24), BackgroundTransparency=1, Text=PLUGIN_NAME, TextColor3=Color3.fromRGB(235,241,255), Font=Enum.Font.GothamBold, TextSize=18, TextXAlignment=Enum.TextXAlignment.Left}, header)
new("TextLabel", {Position=UDim2.new(0,18,0,29), Size=UDim2.new(1,-36,0,14), BackgroundTransparency=1, Text=VERSION.."  •  Created by MatiDev", TextColor3=Color3.fromRGB(145,157,183), Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left}, header)
local status = new("TextLabel", {Position=UDim2.new(0,18,0,43), Size=UDim2.new(1,-36,0,14), BackgroundTransparency=1, Text="●  Ready", TextColor3=Color3.fromRGB(95,220,155), Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left}, header)
local logFrame = new("ScrollingFrame", {Position=UDim2.new(0,12,0,70), Size=UDim2.new(1,-24,1,-190), BackgroundColor3=Color3.fromRGB(10,12,18), BorderSizePixel=0, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=5}, bg)
new("UIPadding", {PaddingTop=UDim.new(0,12), PaddingBottom=UDim.new(0,12), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12)}, logFrame)
local layout = new("UIListLayout", {Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder}, logFrame)
local input = new("TextBox", {Position=UDim2.new(0,12,1,-108), Size=UDim2.new(1,-24,0,62), BackgroundColor3=Color3.fromRGB(28,33,46), BorderSizePixel=0, ClearTextOnFocus=false, MultiLine=true, PlaceholderText="Describe what you want to build...", Text="", TextColor3=Color3.fromRGB(230,235,245), PlaceholderColor3=Color3.fromRGB(130,140,160), Font=Enum.Font.Gotham, TextSize=13, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, bg)
new("UIPadding", {PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)}, input)
local send = new("TextButton", {Position=UDim2.new(1,-112,1,-38), Size=UDim2.new(0,100,0,30), BackgroundColor3=Color3.fromRGB(76,125,255), BorderSizePixel=0, Text="Send  ↗", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=12}, bg)
local apply = new("TextButton", {Position=UDim2.new(0,12,1,-38), Size=UDim2.new(0,100,0,30), BackgroundColor3=Color3.fromRGB(39,49,69), BorderSizePixel=0, Text="Zastosuj", TextColor3=Color3.fromRGB(220,228,245), Font=Enum.Font.GothamBold, TextSize=12}, bg)
local pulseTime = 0
local function style(obj, radius, strokeColor)
    new("UICorner", {CornerRadius=UDim.new(0, radius)}, obj)
    if strokeColor then new("UIStroke", {Color=strokeColor, Transparency=0.55, Thickness=1}, obj) end
end
style(logFrame, 8, Color3.fromRGB(65,78,108)); style(input, 8, Color3.fromRGB(65,78,108)); style(send, 7); style(apply, 7)

local function addLog(text, color)
    new("TextLabel", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Text=tostring(text), TextColor3=color or Color3.fromRGB(190,198,215), Font=Enum.Font.Code, TextSize=11, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left}, logFrame)
end
local function request(method, path, body)
    local opts = {Url="http://127.0.0.1:8765"..path, Method=method, Headers={ ["Content-Type"]="application/json" }}
    if body then opts.Body=HttpService:JSONEncode(body) end
    return HttpService:RequestAsync(opts)
end
local function findOrCreate(parent, name, className)
    local found=parent:FindFirstChild(name); if found then return found end
    local obj=Instance.new(className); obj.Name=name; obj.Parent=parent; return obj
end
local function resolvePath(path)
    local parts=string.split(path,"/"); local root=table.remove(parts,1)
    local parent=root=="StarterPlayerScripts" and game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts") or game:FindFirstChild(root)
    if not parent then error("Unsupported root: "..tostring(root)) end
    for i,name in ipairs(parts) do
        local final=i==#parts; local clean=final and string.gsub(name,"%.lua$","") or name
        local class=final and (root=="StarterPlayerScripts" and "LocalScript" or (string.find(clean,"Module") and "ModuleScript" or "Script")) or "Folder"
        parent=findOrCreate(parent,clean,class)
    end
    return parent
end
local function applyCommand(cmd)
    if cmd.op~="write_script" then error("Unsupported operation: "..tostring(cmd.op)) end
    local obj=resolvePath(cmd.path); obj.Source=cmd.source; ChangeHistoryService:SetWaypoint("ProjectAI: "..cmd.path)
end
local function submit()
    if input.Text == "" then return end
    local taskText=input.Text; input.Text=""; addLog("> "..taskText, Color3.fromRGB(140,170,255)); status.Text="●  Working..."; status.TextColor3=Color3.fromRGB(255,194,82)
    local ok, res=pcall(function() return request("POST", "/task", {task=taskText}) end)
    if not ok or not res.Success then addLog("Bridge unavailable. Run start-bridge.ps1.", Color3.fromRGB(255,110,110)); status.Text="●  Offline"; status.TextColor3=Color3.fromRGB(255,110,110) end
end
send.MouseButton1Click:Connect(submit)
input.FocusLost:Connect(function(enter) if enter then submit() end end)
button.Click:Connect(function() widget.Enabled=not widget.Enabled end)
apply.MouseButton1Click:Connect(function()
    local ok,res=pcall(function() return request("GET","/poll") end)
    if ok and res.Success then
        local d=HttpService:JSONDecode(res.Body)
        if d.command then
            local done,err=pcall(function() applyCommand(d.command) end)
            pcall(function() request("POST","/result",{ok=done,error=err}) end)
            addLog(done and "✓ Applied: "..tostring(d.command.path) or "✕ Error: "..tostring(err), done and Color3.fromRGB(95,220,155) or Color3.fromRGB(255,110,110))
        else addLog("No pending changes.") end
    else addLog("Could not connect to the bridge.", Color3.fromRGB(255,110,110)) end
end)

task.spawn(function()
    local last=""
    while true do
        task.wait(1)
        local ok,res=pcall(function() return request("GET","/status") end)
        if ok and res.Success then
            local d=HttpService:JSONDecode(res.Body); status.Text=d.running and "●  Working..." or (d.queued>0 and "●  Changes ready" or "●  Ready")
            status.TextColor3=d.running and Color3.fromRGB(255,194,82) or Color3.fromRGB(95,220,155)
            local joined=table.concat(d.logs,"\n")
            if joined~=last then last=joined; for _,child in ipairs(logFrame:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end; for _,line in ipairs(d.logs) do addLog(line) end end
        end
    end
end)
print(PLUGIN_NAME.." "..VERSION.." loaded — Created by MatiDev")
RunService.Heartbeat:Connect(function(dt)
    pulseTime += dt
    if status.Text:find("Working") then
        status.TextTransparency = 0.15 + (math.sin(pulseTime * 5) + 1) * 0.18
    else
        status.TextTransparency = 0
    end
end)
