
local SaveLoadSystem = {
    elementRegistry = {
        Toggles = {},
        Sliders = {},
        Inputs = {},
        Dropdowns = {},
        Keybinds = {},
        Colorpickers = {},
        Checkboxes = {},
    },
    FolderName = nil
}

function SaveLoadSystem:RegisterToggle(id, obj)
    self.elementRegistry.Toggles[id] = obj
end

function SaveLoadSystem:RegisterSlider(id, obj)
    self.elementRegistry.Sliders[id] = obj
end

function SaveLoadSystem:RegisterInput(id, obj)
    self.elementRegistry.Inputs[id] = obj
end

function SaveLoadSystem:RegisterDropdown(id, obj)
    self.elementRegistry.Dropdowns[id] = obj
end

function SaveLoadSystem:RegisterKeybind(id, obj)
    self.elementRegistry.Keybinds[id] = obj
end

function SaveLoadSystem:RegisterColorpicker(id, obj)
    self.elementRegistry.Colorpickers[id] = obj
end

function SaveLoadSystem:RegisterCheckbox(id, obj)
    self.elementRegistry.Checkboxes[id] = obj
end

function SaveLoadSystem:GetPath()
    -- Salva direto na pasta Lib.Folder (sem /Config)
    return (self.FolderName or "AiCodeLib") .. "/"
end

function SaveLoadSystem:CollectData()
    local data = {
        Toggles = {},
        Sliders = {},
        Inputs = {},
        Dropdowns = {},
        Keybinds = {},
        Colorpickers = {},
        Checkboxes = {},
    }
    
    for id, obj in pairs(self.elementRegistry.Toggles) do
        if obj and obj.GetValue then data.Toggles[id] = obj:GetValue() end
    end
    for id, obj in pairs(self.elementRegistry.Sliders) do
        if obj and obj.GetValue then data.Sliders[id] = obj:GetValue() end
    end
    for id, obj in pairs(self.elementRegistry.Inputs) do
        if obj and obj.GetValue then data.Inputs[id] = obj:GetValue() end
    end
    for id, obj in pairs(self.elementRegistry.Dropdowns) do
        if obj and obj.GetValue then data.Dropdowns[id] = obj:GetValue() end
    end
    for id, obj in pairs(self.elementRegistry.Keybinds) do
        if obj and obj.GetKey then data.Keybinds[id] = obj:GetKey() end
    end
    for id, obj in pairs(self.elementRegistry.Colorpickers) do
        if obj and obj.GetColor then
            local c = obj:GetColor()
            data.Colorpickers[id] = {R = c.R, G = c.G, B = c.B}
        end
    end
    for id, obj in pairs(self.elementRegistry.Checkboxes) do
        if obj and obj.GetValue then data.Checkboxes[id] = obj:GetValue() end
    end
    
    return data
end

function SaveLoadSystem:LoadData(data)
    if not data then return false end
    
    for id, state in pairs(data.Toggles or {}) do
        local obj = self.elementRegistry.Toggles[id]
        if obj and obj.SetValue then obj:SetValue(state) end
    end
    for id, value in pairs(data.Sliders or {}) do
        local obj = self.elementRegistry.Sliders[id]
        if obj and obj.SetValue then obj:SetValue(value) end
    end
    for id, text in pairs(data.Inputs or {}) do
        local obj = self.elementRegistry.Inputs[id]
        if obj and obj.SetText then obj:SetText(text) end
    end
    for id, value in pairs(data.Dropdowns or {}) do
        local obj = self.elementRegistry.Dropdowns[id]
        if obj and obj.SetValue then obj:SetValue(value) end
    end
    for id, key in pairs(data.Keybinds or {}) do
        local obj = self.elementRegistry.Keybinds[id]
        if obj and obj.SetKey then obj:SetKey(key) end
    end
    for id, colorData in pairs(data.Colorpickers or {}) do
        local obj = self.elementRegistry.Colorpickers[id]
        if obj and obj.SetColor then
            obj:SetColor(Color3.new(colorData.R, colorData.G, colorData.B))
        end
    end
    for id, state in pairs(data.Checkboxes or {}) do
        local obj = self.elementRegistry.Checkboxes[id]
        if obj and obj.SetValue then obj:SetValue(state) end
    end
    
    return true
end

function SaveLoadSystem:GetAllConfigs()
    local files = {}
    local path = self:GetPath()
    
    if not isfolder(path) then
        makefolder(path)
        return files
    end
    
    for _, file in pairs(listfiles(path)) do
        local name = file:match("([^/\\]+)%.json$")
        if name then table.insert(files, name) end
    end
    
    return files
end

function SaveLoadSystem:SaveConfig(name)
    if not name or name == "" then
        name = "Config_" .. os.date("%Y-%m-%d_%H-%M-%S")
    end
    
    local data = self:CollectData()
    local saveData = {
        SaveName = name,
        Timestamp = os.time(),
        Data = data
    }
    
    local json = game:GetService("HttpService"):JSONEncode(saveData)
    local path = self:GetPath()
    
    if not isfolder(path) then
        makefolder(path)
    end
    
    writefile(path .. name .. ".json", json)
    return true
end

function SaveLoadSystem:LoadConfig(name)
    local path = self:GetPath() .. name .. ".json"
    
    if not isfile(path) then
        return false
    end
    
    local content = readfile(path)
    local success, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), content)
    
    if not success or not data then
        return false
    end
    
    return self:LoadData(data.Data)
end

function SaveLoadSystem:DeleteConfig(name)
    local path = self:GetPath() .. name .. ".json"
    if isfile(path) then
        delfile(path)
        return true
    end
    return false
end

function SaveLoadSystem:ResetAll()
    for id, obj in pairs(self.elementRegistry.Toggles) do
        if obj and obj.SetValue then obj:SetValue(false) end
    end
    for id, obj in pairs(self.elementRegistry.Sliders) do
        if obj and obj.SetValue then obj:SetValue(0) end
    end
    for id, obj in pairs(self.elementRegistry.Inputs) do
        if obj and obj.SetText then obj:SetText("") end
    end
    for id, obj in pairs(self.elementRegistry.Keybinds) do
        if obj and obj.Reset then obj:Reset() end
    end
    for id, obj in pairs(self.elementRegistry.Checkboxes) do
        if obj and obj.SetValue then obj:SetValue(false) end
    end
    for id, obj in pairs(self.elementRegistry.Colorpickers) do
        if obj and obj.SetColor then obj:SetColor(Color3.fromRGB(255,255,255)) end
    end
    for id, obj in pairs(self.elementRegistry.Dropdowns) do
        if obj and obj.SetValue then
            if obj.GetMultiSelection and obj:GetMultiSelection() then
                obj:SetValue({})
            else
                local values = obj:GetValues()
                if values and #values > 0 then
                    obj:SetValue(values[1])
                else
                    obj:SetValue("None")
                end
            end
        end
    end
    return true
end

function SaveLoadSystem:SetupWithLib(Window)
    self.FolderName = Window.Folder or "AiCodeLib"
    
    local saveTab = Window:Tab({ Icon = "Settings" })
    local mainSubTab = saveTab:SubTab({ Name = "Save & Load" })
    
    -- SAVE
    local saveSection = mainSubTab:Section({ Header = "Save", Side = "Left" })
    
    local saveNameInput = saveSection:Input("SaveNameInput", {
        Name = "Config Name",
        Placeholder = "Enter name...",
        Default = ""
    })
    
    saveSection:Button("SaveButton", {
        Name = "Save Config",
        Callback = function()
            local name = saveNameInput:GetValue()
            if name == "" then name = "Config_" .. os.date("%Y-%m-%d_%H-%M-%S") end
            self:SaveConfig(name)
            Window:Notification({
                Title = "Save & Load",
                Message = "Saved: " .. name .. " in " .. self:GetPath(),
                Duration = 4,
                Position = "Screen"
            })
            if Window._refresh then Window:_refresh() end
        end
    })
    
    -- LOAD
    local loadSection = mainSubTab:Section({ Header = "Load", Side = "Right" })
    
    local configsList = {}
    local configsDropdown

    local function refreshList()
    local path = self:GetPath()
    
    -- Limpar valores antigos do dropdown
    if configsDropdown then
        local currentValues = configsDropdown.Settings.Values or {}
        for i = #currentValues, 1, -1 do
            if currentValues[i] ~= "Loading..." then
                configsDropdown:DelValue(currentValues[i])
            end
        end
    end
    
    -- Buscar arquivos da pasta
    local configs = {}
    if isfolder(path) then
        for _, file in pairs(listfiles(path)) do
            local name = file:match("([^/\\]+)%.json$")
            if name then 
                table.insert(configs, name) 
            end
        end
    end
    
    -- Adicionar valores ao dropdown usando AddValue
    if configsDropdown then
        if #configs == 0 then
            configsDropdown:AddValue("No configs found")
            configsDropdown:SetValue("No configs found")
        else
            for _, name in ipairs(configs) do
                configsDropdown:AddValue(name)
            end
            configsDropdown:SetValue(configs[1])
        end
    end
end
    
    configsDropdown = loadSection:Dropdown("ConfigsDropdown", {
        Name = "Select Config",
        Values = configsList,
        Default = configsList[1] or "No configs",
        MultiSelection = false
    })
    
    loadSection:Button("LoadButton", {
        Name = "Load Selected",
        Callback = function()
            local selected = configsDropdown:GetValue()
            if selected == "No configs" then
                Window:Notification({ Title = "Save & Load", Message = "No configs!", Duration = 2, Position = "Screen" })
                return
            end
            if self:LoadConfig(selected) then
                Window:Notification({ Title = "Save & Load", Message = "Loaded: " .. selected, Duration = 3, Position = "Screen" })
                if Window._refresh then Window:_refresh() end
            end
        end
    })
    
    loadSection:Button("DeleteButton", {
        Name = "Delete Selected",
        Callback = function()
            local selected = configsDropdown:GetValue()
            if selected == "No configs" then return end
            self:DeleteConfig(selected)
            refreshList()
            Window:Notification({ Title = "Save & Load", Message = "Deleted: " .. selected, Duration = 3, Position = "Screen" })
        end
    })
    
    loadSection:Button("RefreshButton", {
        Name = "Refresh List",
        Callback = refreshList
    })
    
    -- SETTINGS
    local settingsSection = mainSubTab:Section({ Header = "Settings", Side = "Left" })
    
    settingsSection:Button("ResetButton", {
        Name = "Reset All",
        Callback = function()
            Window:Dialog({
                Title = "Reset All",
                Description = "Reset all progress?",
                Buttons = {
                    { Name = "Yes", Callback = function() 
                        self:ResetAll() 
                        Window:Notification({ Title = "Reset", Message = "All reset!", Duration = 2, Position = "Screen" }) 
                    end },
                    { Name = "No" }
                }
            })
        end
    })
    
    Window._refresh = refreshList
    refreshList()
    
    return {
        SaveNameInput = saveNameInput,
        ConfigsDropdown = configsDropdown,
        RefreshList = refreshList
    }
end

local Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/AKAIDOUSER/HARPY-LIBRARY/refs/heads/main/Load%20Icons.lua"))()
Icons:LoadIcons("https://raw.githubusercontent.com/AKAIDOUSER/HARPY-LIBRARY/refs/heads/main/Icons.lua")

local Lib = {
    Features = {}, 
    Folder = "",
    
	Themes = {
	    Darker = {
	        Background = {
                Primary = Color3.fromRGB(10, 10, 10),
                Secondary = Color3.fromRGB(15, 15, 15),
                Tertiary = Color3.fromRGB(15, 15, 15),
                Card = Color3.fromRGB(15, 15, 15)
            },
            
            Text = {
                Primary = Color3.fromRGB(240, 240, 240),
                Secondary = Color3.fromRGB(180, 180, 180),
                Disabled = Color3.fromRGB(120, 120, 120)
            },
            
            Font = {
                Title = Enum.Font.Code,
                Text = Enum.Font.Code,
                interFont = "rbxassetid://12187365364",
            },
            
            Image = {
                Primary = Color3.fromRGB(240, 240, 240),
                Secondary = Color3.fromRGB(180, 180, 180),
                Disabled = Color3.fromRGB(120, 120, 120),
                Shadow = Color3.fromRGB(15, 15, 15)
            },
            
            Border = {
                Primary = Color3.fromRGB(35, 35, 35),
                Secondary = Color3.fromRGB(140, 140, 140),
            },
            
            Interactive = {
                Hover = Color3.fromRGB(45, 45, 55),
                Pressed = Color3.fromRGB(55, 55, 65),
                Selected = Color3.fromRGB(18, 18, 18),
                Tab = Color3.fromRGB(22, 22, 22)
            },
            
            Highlight = {
                White = Color3.fromRGB(255, 255, 255),
                Blue = Color3.fromRGB(0, 120, 215),
                Purple = Color3.fromRGB(103, 58, 183),
                Green = Color3.fromRGB(76, 175, 80),
                Red = Color3.fromRGB(244, 67, 54),
                Orange = Color3.fromRGB(255, 152, 0),
                Cyan = Color3.fromRGB(0, 188, 212)
            },
            
            Apple = {
                Red = Color3.fromRGB(255, 79, 79),
                Yellow = Color3.fromRGB(227, 232, 95),
                Green = Color3.fromRGB(96, 181, 65),
            },
            
            Elements = {
                Button = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                    Thumb = Color3.fromRGB(240, 240, 240),
                },
                
                Toggle = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Track = Color3.fromRGB(18, 18, 18),
                    Thumb = Color3.fromRGB(140, 140, 140),
                    Text = Color3.fromRGB(240, 240, 240),
                },
                
                Checkbox = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Track = Color3.fromRGB(18, 18, 18),
                    Thumb = Color3.fromRGB(140, 140, 140),
                    Text = Color3.fromRGB(240, 240, 240),
                },
                
                Slider = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                    Display = Color3.fromRGB(240, 240, 240),
                    Thumb = Color3.fromRGB(180, 180, 180),
                    Track = Color3.fromRGB(200, 200, 200),
                    Bottom = Color3.fromRGB(25, 25, 25)
                },
                
                Dropdown = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                    Thumb = Color3.fromRGB(240, 240, 240),
                    Track = Color3.fromRGB(240, 240, 240),
                },
                
                Colorpicker = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240)
                },
                
                Input = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                    Icon = Color3.fromRGB(180, 180, 180),
                    Track = Color3.fromRGB(18, 18, 18),
                    Placeholder = Color3.fromRGB(200, 200, 200),
                },
                
                KeyBind = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                    Track = Color3.fromRGB(18, 18, 18),
                    Placeholder = Color3.fromRGB(200, 200, 200),
                },
                
                Paragraph = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                },
                
                Label = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                },
                
                SubLabel = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(180, 180, 180),
                },
                
                Header = {
                    Primary = Color3.fromRGB(18, 18, 18),
                    Text = Color3.fromRGB(240, 240, 240),
                },
                
                Dialog = {
                    Primary = Color3.fromRGB(10, 10, 10),
                    Secondary = Color3.fromRGB(18, 18, 18),
                    Tertiary = Color3.fromRGB(15, 15, 15),
                    Buttons = Color3.fromRGB(25, 25, 25),
                    Title = Color3.fromRGB(240, 240, 240),
                    Text = Color3.fromRGB(180, 180, 180),
                },
                
                Notification = {
                    Primary = Color3.fromRGB(10, 10, 10),
                    Secondary = Color3.fromRGB(18, 18, 18),
                    Tertiary = Color3.fromRGB(15, 15, 15),
                    Title = Color3.fromRGB(240, 240, 240),
                    Text = Color3.fromRGB(180, 180, 180),
                },
            },
	    },
	
	},
	    
	
	GetService = function(service)
		return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
	end
}

local TweenService = Lib.GetService("TweenService")
local RunService = Lib.GetService("RunService")
local HttpService = Lib.GetService("HttpService")
local ContentProvider = Lib.GetService("ContentProvider")
local UserInputService = Lib.GetService("UserInputService")
local Lighting = Lib.GetService("Lighting")
local Players = Lib.GetService("Players")

local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer

local assets = {
    userInfoBlurred = "rbxassetid://18824089198",
}

function CreateElement(type, properties)
	local element = Instance.new(type)
	for prop, value in pairs(properties) do
		element[prop] = value
	end
	return element
end

function UICorner(Size, Parent)
    local Corner
    task.spawn(function()
        Corner = CreateElement("UICorner", {
            CornerRadius = UDim.new(Size[1], Size[2]),  -- Acessa os valores diretamente
            Parent = Parent
        })
    end)
    return Corner
end

function UIStroke(Size, Trans, Color, Parent)
    local Stroke
    task.spawn(function()
         Stroke = CreateElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Thickness = Size,
            Transparency = Trans,
            Color = Color,
            Parent = Parent,
        })
	end)
	return Stroke
end

function UIPadding(Top, Sides, Parent)
    local Padding
    task.spawn(function()
         Padding = CreateElement("UIPadding", {
            PaddingLeft = UDim.new(Sides[1], Sides[2]),
           	PaddingRight = UDim.new(Sides[3], Sides[4]),
            PaddingTop = UDim.new(Top[1], Top[2]),
           	PaddingBottom = UDim.new(Top[1], Top[2]),
           	Parent = Parent
        })
	end)
	return Padding
end

function Lib:GetThemeConfig(themeName)
    return self.Themes[themeName] or self.Themes.Darker 
end

function Lib:GetGui()
	local newGui = Instance.new("ScreenGui")
	newGui.ScreenInsets = Enum.ScreenInsets.None
	newGui.ResetOnSpawn = false
	newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	newGui.DisplayOrder = 2147483647

	local parent = RunService:IsStudio() 
		and LocalPlayer:FindFirstChild("PlayerGui")
		or (gethui and gethui())
		or (cloneref and cloneref(Lib.GetService("CoreGui")) or Lib.GetService("CoreGui"))

	newGui.Parent = parent
	return newGui
end

function Lib:AutoUpdateText(parent)
    parent:GetPropertyChangedSignal("Text"):Connect(function()
	    task.wait()
	    local textSize = game:GetService("TextService"):GetTextSize(
	        parent.Text,
	        parent.TextSize,
	        parent.Font,
	        Vector2.new(100000, math.huge)
	    )
	    
	    parent.Size = UDim2.new(0, textSize.X + 2, 0, textSize.Y + 2)
	end)
end

function Lib:AutoUpdateList(parent1, parent2, type)
    if type == "Frame" then
        parent1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            parent2.Size = UDim2.new(0, 0, 0, parent1.AbsoluteContentSize.Y)
        end)
    else
        parent1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            parent2.CanvasSize = UDim2.new(0, 0, 0, parent1.AbsoluteContentSize.Y)
        end)
    end
end

function Lib:HoverElements(Active, Hover, Parent_01, Parent_02)
    Parent_01.MouseEnter:Connect(function()
        Hover = true
        if not Active then
            TweenService:Create(Parent_02, TweenInfo.new(0.15), {
                TextTransparency = 0
            }):Play()
        end
    end)
    
    Parent_01.MouseLeave:Connect(function()
        Hover = false
        if not Active then 
            TweenService:Create(Parent_02, TweenInfo.new(0.15), {
                TextTransparency = 0.4
            }):Play()
        end
    end)
end

function Lib:AppleBalls(Size, theme, Parent)
    local Themes = self:GetThemeConfig(theme)

    local HolderBalls_F = CreateElement("Frame", {
    	Name = "HolderBalls_F",
    	Size = UDim2.new(0, 0, 0, 0),
    	AnchorPoint = Vector2.new(0.5, 0.5),
    	Position = UDim2.new(0.5, 0, 0.5, 0),
    	AutomaticSize = Enum.AutomaticSize.XY,
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	Visible = true,
    	ClipsDescendants = true,
    	Parent = Parent
    })
    
	CreateElement("UIListLayout", {
    	FillDirection = Enum.FillDirection.Horizontal,
    	HorizontalAlignment = Enum.HorizontalAlignment.Left,
    	VerticalAlignment = Enum.VerticalAlignment.Center,
    	SortOrder = Enum.SortOrder.LayoutOrder,
    	Padding = UDim.new(0, 5),
    	Parent = HolderBalls_F
    })
    
    local Ball_Red = CreateElement("Frame", {
		Name = "Ball_Red",
		Size = UDim2.fromOffset(unpack(Size)),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Themes.Apple.Red,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = true,
		ClipsDescendants = true,
		Parent = HolderBalls_F
	})
	
	CreateElement("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = Ball_Red
	})
	
	local Ball_Yellow = CreateElement("Frame", {
		Name = "Ball_Yellow",
		Size = UDim2.fromOffset(unpack(Size)),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Themes.Apple.Yellow,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = true,
		ClipsDescendants = true,
		Parent = HolderBalls_F
	})
	
	CreateElement("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = Ball_Yellow
	})
	
	local Ball_Green = CreateElement("Frame", {
		Name = "Ball_Green",
		Size = UDim2.fromOffset(unpack(Size)),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Themes.Apple.Green,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = true,
		ClipsDescendants = true,
		Parent = HolderBalls_F
	})
	
	CreateElement("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = Ball_Green
	})
	
	task.spawn(function()
        TweenService:Create(Ball_Red, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        	BackgroundTransparency = 0
        }):Play()
    
        task.delay(0.4, function()
        	TweenService:Create(Ball_Yellow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        		BackgroundTransparency = 0
        	}):Play()
        end)
        
        task.delay(0.8, function()
        	TweenService:Create(Ball_Green, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        		BackgroundTransparency = 0
        	}):Play()
        end)
    end)
	
	return HolderBalls_F
end


function Lib:UserInfoLayout(Parent, theme, State)
    local Themes = self:GetThemeConfig(theme)
    
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.AvatarBust
    local thumbSize = Enum.ThumbnailSize.Size48x48
    
    -- CORREÇÃO AQUI: GetUserThumbnailAsync retorna 2 valores
    local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    
    local BgUserPerfil = CreateElement("Frame", {
		Size = UDim2.new(1, - 20, 1, -10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Draggable = false,
		ClipsDescendants = false,
		Parent = Parent
	})

	CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = BgUserPerfil
    })
    
    CreateElement("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 1,
        Color = Themes.Border.Primary,
        Parent = BgUserPerfil,
    })
    
    local Headshot = CreateElement("ImageLabel", {
        Name = "Headshot",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Image = State and headshotImage or assets.userInfoBlurred,
        ImageTransparency = 1,
        Size = UDim2.fromOffset(28, 28),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = BgUserPerfil,
    })
    
    CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Headshot
    })
    
    local Stk = CreateElement("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 1,
        Color = Themes.Border.Primary,
        Parent = Headshot,
    })
    
    local Speed = 1
    
    task.spawn(function()
        TweenService:Create(Headshot, TweenInfo.new(Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 0
        }):Play()
        
        TweenService:Create(Stk, TweenInfo.new(Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Thickness = 1
        }):Play()
    end)
    
    -- Retorne uma tabela com todos os elementos principais se precisar controlá-los depois
    return {
        BgUserPerfil = BgUserPerfil,
        Headshot = Headshot,
        Stroke = Stk
    }
end

function Lib:Window(Settings)
    Settings.Title = Settings.Title or "AiCode Lib"
    Settings.Theme = Settings.Theme or "Darker"
    Settings.Folder = Settings.Folder or "AiCodeLib"
    Settings.ShowUserInfo = Settings.ShowUserInfo or false
    Settings.AcrylicBlur = Settings.AcrylicBlur or false
    Settings.Button = Settings.Button or {Enabled = false, Position = {10, 30}, Size = {40, 40}}
    Settings.Size = Settings.Size or {500, 350}
    Settings.MaxSize = Settings.MaxSize or {800, 500}
    Settings.MinSize = Settings.MinSize or {400, 300}
    Settings.KeyBind = Settings.KeyBind or Enum.KeyCode.K
    
    Lib.Folder = Settings.Folder
    
	local StorageTabs = {CurrentTab = nil, FirstTab = true}
    local ScreenGui = Lib:GetGui()
    local Themes = self:GetThemeConfig(Settings.Theme)
    
    if getgenv()._Check_Loader_Menu then 
        getgenv()._Check_Loader_Menu = false 
        getgenv().StorageTabs:Unload()
        wait(0.4) 
    end

    getgenv()._Check_Loader_Menu = true
    getgenv().StorageTabs = StorageTabs
    
    local Window = CreateElement("Frame", {
		Name = Settings.Title,
		Size = UDim2.fromOffset(unpack(Settings.Size)),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		Draggable = false,
		ZIndex = math.huge,
		ClipsDescendants = false,
		Parent = ScreenGui
	})

	UICorner({0, 10}, Window)
	
	local ConteinerFuns = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Themes.Background.Primary,
		BackgroundTransparency = Settings.AcrylicBlur and 0.047 or 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Window
	})
	
	UICorner({0, 10}, ConteinerFuns)
	
	-- Left Frame 
	
	local Left = CreateElement("Frame", {
		Size = UDim2.new(0, 85, 1, 0),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Themes.Background.Secondary,
		BackgroundTransparency = 0.035,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = ConteinerFuns
	})
	
	CreateElement("Frame", {
		Size = UDim2.new(0, 10, 1, 0),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Themes.Background.Secondary,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Left
	})
    
    UICorner({0, 10}, Left)
    
    CreateElement("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Themes.Border.Primary,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Left
	})
	
	local Left_balls_F = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 35),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		Parent = Left
	})
	
	CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Themes.Border.Primary,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Left_balls_F
	})
	
	local Left_Tabs_F = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 1, - 80),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, - 45),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Left
	})
	
	local ScrollingFrame = CreateElement("ScrollingFrame", {
    	Size = UDim2.new(1, 0, 1, 0),
    	AnchorPoint = Vector2.new(1, 1),
    	Position = UDim2.new(1, 0, 1, 0),
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	Visible = true,
    	ClipsDescendants = true,
    
    	CanvasSize = UDim2.new(0, 0, 0, 0),
    	ScrollBarThickness = 0,
    	ScrollBarImageTransparency = 1,
    	ScrollingDirection = Enum.ScrollingDirection.Y,
    	VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
    	
    	Parent = Left_Tabs_F
    })
    
    CreateElement("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
       	PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
       	PaddingBottom = UDim.new(0, 8),
       	Parent = ScrollingFrame
    })
	
	local UIListLayout = CreateElement("UIListLayout", {
    	FillDirection = Enum.FillDirection.Vertical,
    	HorizontalAlignment = Enum.HorizontalAlignment.Center,
    	VerticalAlignment = Enum.VerticalAlignment.Top,
    	SortOrder = Enum.SortOrder.LayoutOrder,
    	Padding = UDim.new(0, 8),
    	
    	Parent = ScrollingFrame
    })
	
	local Left_User_F = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 45),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Left
	})
	
	-- Right Frame
	
	local Right = CreateElement("Frame", {
		Size = UDim2.new(1, - 85, 1, 0),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		Parent = ConteinerFuns
	})
	
	local Right_Tabs_Frame = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 35),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Themes.Background.Secondary,
		BackgroundTransparency = 0.045,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Right
	})
	
	local Title = CreateElement("TextLabel", {
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, - 8, 0.5, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Text = Settings.Title,
        TextColor3 = Themes.Text.Primary,
        TextTransparency = 0,
        TextScaled = false,
        TextSize = 13,
        Font = Themes.Font.Title,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Right_Tabs_Frame
    })
	
	CreateElement("Frame", {
		Size = UDim2.new(0, 10, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Themes.Background.Secondary,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Right_Tabs_Frame
	})
	
	CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 10),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Themes.Background.Secondary,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Right_Tabs_Frame
	})
	
	CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Themes.Border.Primary,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Right_Tabs_Frame
	})
	
	UICorner({0, 10}, Right_Tabs_Frame)
	
	local Right_Conteiner = CreateElement("Frame", {
		Size = UDim2.new(1, 0, 1, - 35),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Right
	})
	
	CreateElement("UIPadding", {
        PaddingLeft = UDim.new(0, 7),
       	PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
       	PaddingBottom = UDim.new(0, 7),
       	Parent = Right_Conteiner
    })
	
	-- Code 
	
	Lib:AutoUpdateList(UIListLayout, ScrollingFrame, "ScrollingFrame")
	Lib:AppleBalls({7, 7}, Settings.Theme, Left_balls_F)
	--Lib:UserInfoLayout(Left_User_F, Settings.Theme, Settings.ShowUserInfo)
	Lib:AutoUpdateText(Title)
	
    local currentKeyBind = Settings.KeyBind
    local mainFrameVisible = true
    
    function toggleWindowVisibility()
        mainFrameVisible = not mainFrameVisible
        Window.Visible = mainFrameVisible
    end
    
    function setupKeyBind()
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == currentKeyBind then
                toggleWindowVisibility()
            end
        end)
    end
	
	local dragging = false
    local dragInput, dragStart, startPos
    
    function updateDrag(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        
        TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = newPos
        }):Play()
    end
    
    Left_balls_F.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Left_balls_F.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
	
	setupKeyBind()
	
	local Main_Button
	
	if Settings.Button then
        local ButtonSettings = Settings.Button
        if type(ButtonSettings) == "boolean" then
            ButtonSettings = {Enabled = ButtonSettings, Position = {10, 30}, Size = {50, 50}}
        end
        
        ButtonSettings.Enabled = ButtonSettings.Enabled or false
        ButtonSettings.Position = ButtonSettings.Position or {10, 30}
        ButtonSettings.Size = ButtonSettings.Size or {50, 50}
        ButtonSettings.Icon = ButtonSettings.Icon or "Logo"
        
        if ButtonSettings.Enabled then
            Main_Button = CreateElement("Frame", {
                Name = Settings.Title .. "_Button",
                Size = UDim2.fromOffset(unpack(ButtonSettings.Size)),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, ButtonSettings.Position[1], 0, ButtonSettings.Position[2]),
                BackgroundColor3 = Themes.Background.Primary,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Visible = true,
                Active = true,
                Draggable = true,
                ZIndex = Window.ZIndex + 99999999,
                ClipsDescendants = false,
                Parent = ScreenGui
            })
                
            UICorner({0, 10}, Main_Button)
            
            UIStroke(1, 0.2, Themes.Border.Primary, Main_Button)
            
            local Icon = CreateElement("ImageLabel", {
                Name = "Icon",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ImageColor3 = Themes.Text.Primary,
                Image = "rbxassetid://" .. tostring(Icons:GetIcon(ButtonSettings.Icon)),
                ImageTransparency = 0, 
                Size = UDim2.fromOffset(ButtonSettings.Size[1] - 10, ButtonSettings.Size[2] - 10),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Parent = Main_Button,
            })
            
            local OnClick = CreateElement("TextButton", {
                Name = "OnClickW",
                Parent = Main_Button,
                BackgroundTransparency = 1.000,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                AutoButtonColor = false,
                Text = "",
                TextSize = 0.000,
            })
            
            OnClick.MouseButton1Click:Connect(function()
                toggleWindowVisibility()
            end)
            
            -- Hover effect
            OnClick.MouseEnter:Connect(function()
                TweenService:Create(Main_Button, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.1
                }):Play()
            end)
            
            OnClick.MouseLeave:Connect(function()
                TweenService:Create(Main_Button, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0
                }):Play()
            end)
        end
    end
	
	function StorageTabs:Unload()
        if Window and Window.Parent then
            Window:Destroy()
        end
        
        for flag, _ in pairs(Lib.Features) do
            Lib.Features[flag] = nil
        end
        
        local Buttons = Main_Button
        if Buttons then
            Buttons:Destroy()
        end

        if ScreenGui then
            ScreenGui:Destroy()
        end
        
        getgenv()._Check_Loader_Menu = false
    end
    
    function StorageTabs:StateVisibilityButton(state)
        Main_Button.Visible = state
    end
    
    function StorageTabs:Button(Settings)
        Settings = Settings or {}
        Settings.Name = Settings.Name or "Simple button"
        Settings.Callback = Settings.Callback or function() end
        Settings.Size = Settings.Size or {80, 30}
        Settings.Position = Settings.Position or {10, 30}
        Settings.Color = Settings.Color or Themes.Elements.Button.Text
        
        local Button = {
            Settings = Settings
        }
        
        local Element = Themes.Elements.Button
        
        local Element_Button = CreateElement("Frame", {
            Name = "ButtonsWindows_" .. Settings.Name,
            Size = UDim2.fromOffset(unpack(Settings.Size)),
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, Settings.Position[1], 0, Settings.Position[2]),
            BackgroundColor3 = Element.Primary,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = Window.ZIndex + 99999999,
            Parent = ScreenGui
        })
            
        UICorner({0, 7}, Element_Button)
        UIStroke(1, 0.2, Themes.Border.Primary, Element_Button)
        UIPadding({0, 0}, {0, 5, 0, 5}, Element_Button)
            
        local Title = CreateElement("TextLabel", {
            Size = UDim2.new(0, 0, 0, 13),
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = true,
            ClipsDescendants = true,
            Text = Settings.Name,
            TextColor3 = Settings.Color,
            TextTransparency = 0.3,
            TextScaled = false,
            TextSize = 13,
            Font = Themes.Font.Text,
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = Element_Button
        })
        
        local OnClick = CreateElement("TextButton", {
            Parent = Element_Button,
            BackgroundTransparency = 1.000,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            AutoButtonColor = false,
            Text = "",
            TextSize = 0.000,
            ZIndex = 2,
        })
        
        Lib:AutoUpdateText(Title)
        
        -- Hover effect
        OnClick.MouseEnter:Connect(function()
            TweenService:Create(Element_Button, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(Title, TweenInfo.new(0.15), {
                TextTransparency = 0
            }):Play()
        end)
        
        OnClick.MouseLeave:Connect(function()
            TweenService:Create(Element_Button, TweenInfo.new(0.15), {
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Title, TweenInfo.new(0.15), {
                TextTransparency = 0.3
            }):Play()
        end)
        
        -- Click effect
        OnClick.MouseButton1Down:Connect(function()
            TweenService:Create(Element_Button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        OnClick.MouseButton1Up:Connect(function()
            TweenService:Create(Element_Button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0
            }):Play()
        end)

        local function Callback()
            pcall(Settings.Callback)
        end
        
        OnClick.MouseButton1Click:Connect(function()
            Callback()
        end)
        
        -- Funções públicas
        function Button:SetText(text)
            Title.Text = text
        end
        
        function Button:GetText()
            return Title.Text
        end
        
        function Button:SetPosition(x, y)
            Element_Button.Position = UDim2.new(0, x, 0, y)
            Settings.Position = {x, y}
        end
        
        function Button:SetVisible(visible)
            Element_Button.Visible = visible
        end
        
        function Button:GetVisible()
            return Element_Button.Visible
        end
        
        function Button:Destroy()
            Element_Button:Destroy()
        end
        
        return Button
    end
    
    function StorageTabs:Divider()
        local Divider = {}
        
        local ViewLine = CreateElement("Frame", {
            Size = UDim2.new(1, - 24, 0, 2),
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Themes.Border.Secondary,
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
            Visible = true,
            ClipsDescendants = true,
            Parent = ScrollingFrame
        })
        
        UICorner({1, 0}, ViewLine)
        
        return Divider
    end
    
    function StorageTabs:Tab(Settings)
        Settings.Icon = Settings.Icon or "Home"
        
        local Tab = {
            Hover = false,
            Active = false,
            CurrentSTab = nil, 
            FirstSTab = true
        }
        
        local Tab_F = CreateElement("Frame", {
            Name = Settings.Icon.. "_Tab_F",
            Size = UDim2.new(0, 50, 0, 45),
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Themes.Interactive.Selected,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = true,
            ClipsDescendants = true,
            Parent = ScrollingFrame
        })
        
        CreateElement("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = Tab_F
        })
        
        local UiStroke_01 = CreateElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Thickness = 0,
            Color = Themes.Border.Primary,
            Parent = Tab_F,
        })
        
        local iconId = Icons:GetIcon(Settings.Icon)
        
        local Icon = CreateElement("ImageLabel", {
            Name = "Icon",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ImageColor3 = Themes.Image.Primary,
            Image = "rbxassetid://" .. tostring(iconId),
            ImageTransparency = 0.6,
            Size = UDim2.fromOffset(20, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Parent = Tab_F,
        })
    
        local OnClick = CreateElement("TextButton", {
            Name = "OnClickT",
            Parent = Tab_F,
            BackgroundTransparency = 1.000,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            AutoButtonColor = false,
            Text = "",
            TextSize = 0.000,
        })
        
        local Cont = CreateElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ClipsDescendants = true,
            Parent = Right_Conteiner
        })
        
        local ConteinerButtons = CreateElement("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ClipsDescendants = true,
            Parent = Right_Tabs_Frame
        })
        
        local ViewLine = CreateElement("Frame", {
            Size = UDim2.new(0, 0, 0, 2),
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Themes.Border.Secondary,
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            Visible = false,
            ClipsDescendants = true,
            Parent = Right_Tabs_Frame
        })
        
        UICorner({1, 0}, ViewLine)
        
        CreateElement("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
            Parent = ConteinerButtons
        })
        
        local conteinerList = CreateElement("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ConteinerButtons
        })
        
        local TxSize = game:GetService("TextService"):GetTextSize(
            Title.Text,
            Title.TextSize,
            Title.Font,
            Vector2.new(10000, math.huge)
        )

        Title.Size = UDim2.new(0, TxSize.X, 0, TxSize.Y)
        ConteinerButtons.Size = UDim2.new(1, - TxSize.X - 15, 1, 0)

        OnClick.MouseButton1Click:Connect(function(input)
            Tab:Activate()
        end)

        function Tab:Activate()
            if not Tab.Active then
                if StorageTabs.CurrentTab and StorageTabs.CurrentTab ~= Tab then
                    StorageTabs.CurrentTab:Deactivate()
                end
                
                Tab.Active = true
                StorageTabs.CurrentTab = Tab
                
                ConteinerButtons.Visible = true
                Cont.Visible = true
                ViewLine.Visible = true
        
                TweenService:Create(Tab_F, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.050,
                    Size = UDim2.new(0, 55, 0, 45),
                }):Play()
                TweenService:Create(Icon, TweenInfo.new(0.15), {
                    ImageTransparency = 0
                }):Play()
                TweenService:Create(UiStroke_01, TweenInfo.new(0.15), {
                    Thickness = 1
                }):Play()
            end
        end
    
        function Tab:Deactivate()
            if Tab.Active then
                Tab.Active = false
                Tab.Hover = false
                
                ConteinerButtons.Visible = false
                Cont.Visible = false
                ViewLine.Visible = false
                
                TweenService:Create(Tab_F, TweenInfo.new(0.15), {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 50, 0, 40),
                }):Play()
                TweenService:Create(Icon, TweenInfo.new(0.15), {
                    ImageTransparency = 0.6
                }):Play()
                TweenService:Create(UiStroke_01, TweenInfo.new(0.15), {
                    Thickness = 0
                }):Play()
            end
        end
    
        if StorageTabs.CurrentTab == nil then
            StorageTabs.CurrentTab = Tab
            Tab:Activate()
        end
        
        function Tab:SetIcon(icon)
            Icon.Image = "rbxassetid://" .. Icons:GetIcon(icon)
        end
        
        function Tab:SubTab(Settings)
            Settings.Name = Settings.Name or "Test"
            
            local SubTab = { HoverTS = false, ActiveTS = false}
            
            local ButtonSubTab = CreateElement("Frame", {
                Name = Settings.Name.. "SubTbab",
                Size = UDim2.new(0, 0, 0, 27),
                AnchorPoint = Vector2.new(0, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Themes.Interactive.Selected,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Visible = true,
                ClipsDescendants = true,
                Parent = ConteinerButtons
            })
            
            UICorner({0, 8}, ButtonSubTab)
            
            local Title = CreateElement("TextLabel", {
                Size = UDim2.new(0, 0, 0, 18),
                AutomaticSize = Enum.AutomaticSize.X,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Text = Settings.Name,
                TextColor3 = Themes.Text.Primary,
                TextTransparency = 0.6,
                TextScaled = false,
                TextSize = 13,
                Font = Themes.Font.Text,
                TextWrapped = false,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = ButtonSubTab
            })
            
            local OnClick = CreateElement("TextButton", {
                Name = "OnClickT",
                Parent = ButtonSubTab,
                BackgroundTransparency = 1.000,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                AutoButtonColor = false,
                Text = "",
                TextSize = 0.000,
            })
            
            local Conteiner = CreateElement("Frame", {
        		Name = "Conteiner",
        		Size = UDim2.new(1, 0, 1, 0),
        		AnchorPoint = Vector2.new(0, 0),
        		Position = UDim2.new(0, 0, 0, 0),
        		BackgroundTransparency = 1,
        		BorderSizePixel = 0,
        		Visible = false,
        		ClipsDescendants = true,
        		Parent = Cont
        	})
        	
        	local ScrollPages = CreateElement("ScrollingFrame", {
                Name = "ScrollPages",
                Parent = Conteiner,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                BorderSizePixel = 0,
                ScrollBarThickness = 0,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            })
            
            CreateElement("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
               	PaddingRight = UDim.new(0, 1),
                PaddingTop = UDim.new(0, 1),
               	PaddingBottom = UDim.new(0, 1),
               	Parent = ScrollPages
            })
            
            local UiList = CreateElement("UIListLayout", {
                Parent = ScrollPages,
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal
            })
            
            local left = CreateElement("Frame", {
                Name = "Left",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0.5, -5, 1, 0),
                Parent = ScrollPages
            })
            
            local leftUIListLayout = CreateElement("UIListLayout", {
                Name = "LeftUIListLayout",
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                Parent = left
            })
            
            local right = CreateElement("Frame", {
                Name = "Right",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 1,
                Size = UDim2.new(0.5, -5, 1, 0),
                Parent = ScrollPages
            })
            
            local rightUIListLayout = CreateElement("UIListLayout", {
                Name = "RightUIListLayout",
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                Parent = right
            })
            
            Lib:AutoUpdateList(UiList, ScrollPages, "ScrollingFrame")
            
            local initialTextSize = game:GetService("TextService"):GetTextSize(
                Title.Text,
                Title.TextSize,
                Title.Font,
                Vector2.new(10000, math.huge)
            )
            
            Title.Size = UDim2.new(0, initialTextSize.X, 0, initialTextSize.Y)
            ButtonSubTab.Size = UDim2.new(0, initialTextSize.X + 10, 0, 27)
            
            OnClick.MouseButton1Click:Connect(function(input)
                SubTab:Activate()
            end)
    
            function SubTab:Activate()
                if not SubTab.ActiveTS then
                    if Tab.CurrentSTab and Tab.CurrentSTab ~= SubTab then
                        Tab.CurrentSTab:Deactivate()
                    end
                    
                    SubTab.ActiveTS = true
                    Tab.CurrentSTab = SubTab
                    
                    Conteiner.Visible = true

                    task.wait()
                    local buttonPos = ButtonSubTab.AbsolutePosition
                    local buttonSize = ButtonSubTab.AbsoluteSize
                    local parentPos = Right_Tabs_Frame.AbsolutePosition
                    local relativeX = buttonPos.X - parentPos.X
                    
                    TweenService:Create(ViewLine, TweenInfo.new(0.15), {
                        Position = UDim2.new(0, relativeX, 1, 0),  -- Posição X calculada
                        Size = UDim2.new(0, buttonSize.X, 0, 2)    -- Largura do botão
                    }):Play()
                    
                    TweenService:Create(Title, TweenInfo.new(0.15), {
                        TextTransparency = 0.2
                    }):Play()
                end
            end
        
            function SubTab:Deactivate()
                if SubTab.ActiveTS then
                    SubTab.ActiveTS = false
                    SubTab.HoverTS = false
                    
                    Conteiner.Visible = false
                    
                    TweenService:Create(Title, TweenInfo.new(0.15), {
                        TextTransparency = 0.5
                    }):Play()
                end
            end
        
            if Tab.CurrentSTab == nil then
                Tab.CurrentSTab = SubTab
                SubTab:Activate()
            end
            
            function SubTab:Section(Settings)
                Settings.Header = Settings.Header or ""
                Settings.Side = Settings.Side or "Left"
                
                local Section = {}
                
                local bgTitle = CreateElement("Frame", {
                    Name = Settings.Header.. "_Section",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Visible = true,
                    ClipsDescendants = false,
                    Parent = Settings.Side == "Left" and left or right
                })
                
                local Section_Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AnchorPoint = Vector2.new(1, 1),
        		    Position = UDim2.new(1, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Themes.Background.Card,
                    BackgroundTransparency = 0.07,
                    BorderSizePixel = 0,
                    Visible = true,
                    ClipsDescendants = true,
                    Parent = bgTitle
                })
                
                UICorner({0, 7}, Section_Frame)
                UIStroke(1, 0, Themes.Border.Primary, Section_Frame)
                
                local ListLayoutSection = CreateElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8),
                    
                    Parent = Section_Frame
                })
                
                CreateElement("UIPadding", {
                    Parent = Section_Frame,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8)
                })
                
                local Header_Frame
                if Settings.Header ~= "" then
                     Header_Frame = CreateElement("Frame", {
                        Size = UDim2.new(1, 0, 0, 22),
                        AnchorPoint = Vector2.new(0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = false,
                        Parent = bgTitle
                    })
                    
                    local Title_Sec = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 13),
                        AnchorPoint = Vector2.new(0, 0),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(0, 4, 0, -2),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = Settings.Header,
                        TextColor3 = Themes.Text.Primary,
                        TextTransparency = 0.5,
                        TextScaled = true,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Header_Frame
                    })
                    
                    Lib:AutoUpdateText(Title_Sec)
                end 
                
                ListLayoutSection:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    task.spawn(function()
                        local contentHeight = ListLayoutSection.AbsoluteContentSize.Y
                        
                        -- Atualizar tamanho do Section_Frame
                        Section_Frame.Size = UDim2.new(1, 0, 0, contentHeight + 16)
                        
                        if Settings.Header ~= "" then
                            -- Atualizar tamanho do bgTitle (seção + header)
                            bgTitle.Size = UDim2.new(1, 0, 0, contentHeight + 34)
                            
                            -- RECALCULAR A POSIÇÃO DO HEADER também!
                            -- O Header_Frame precisa ficar sempre no topo do bgTitle
                            Header_Frame.Position = UDim2.new(0, 0, 0, 0)
                            
                            -- Recalcular posição do Section_Frame também
                            Section_Frame.Position = UDim2.new(0, 0, 0, 22) -- 22 é a altura do Header_Frame
                            Section_Frame.AnchorPoint = Vector2.new(0, 0) -- Mudei de (1, 1) para (0, 0)
                        else
                            bgTitle.Size = UDim2.new(1, 0, 0, contentHeight + 16)
                            Section_Frame.Position = UDim2.new(0, 0, 0, 0)
                            Section_Frame.AnchorPoint = Vector2.new(0, 0)
                        end
                    end)
                end)
                
                function Section:Divider()
                    local Divider = {}
        
                    local ViewLine = CreateElement("Frame", {
                        Size = UDim2.new(1, - 24, 0, 2),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Themes.Border.Secondary,
                        BackgroundTransparency = 0.9,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
        
                    UICorner({1, 0}, ViewLine)
                    
                    return Divider
                end
                
                function Section:Label(Flag, Settings)
                    Settings = Settings or {}
                    Settings.Text = Settings.Text or "Label"
                    Settings.Alignment = Settings.Alignment or "Left"
                    Settings.Bold = Settings.Bold or false
                    Settings.Subline = Settings.Subline or false
                    
                    local Label = {
                        Settings = Settings, 
                        Class = "Label",
                        IgnoreConfig = false,
                        Hover = false, 
                        Active = false,
                        _connections = {}
                    }
                    
                    local Element = Themes.Elements.Label
                    
                    Label.Settings.Text = Label.Settings.Text or "Label"
                    Label.Settings.Alignment = Label.Settings.Alignment or "Left"
                    Label.Settings.Bold = Label.Settings.Bold or false
                    Label.Settings.Subline = Label.Settings.Subline or false
                    
                    local Element_Label = CreateElement("Frame", {
                        Name = Label.Settings.Text,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        AnchorPoint = Vector2.new(0, 0),
            		    Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 7}, Element_Label)
                    UIPadding({0, 0}, {0, 8, 0, 8}, Element_Label)
                    
                    local Text = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 0),
                        AnchorPoint = Vector2.new(0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = Label.Settings.Text,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Label.Settings.Bold and Enum.Font.GothamBold or Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Label.Settings.Alignment == "Center" and Enum.TextXAlignment.Center or 
                                          Label.Settings.Alignment == "Right" and Enum.TextXAlignment.Right or 
                                          Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_Label
                    })
                    
                    -- Sublinhado no texto (4 pixels abaixo, grossura 1, transparência 0.7)
                    local Subline
                    if Label.Settings.Subline then
                        Subline = CreateElement("Frame", {
                            Size = UDim2.new(0, 0, 0, 1),
                            AnchorPoint = Vector2.new(0, 1),
                            Position = UDim2.new(0, 0, 1, 4),
                            BackgroundColor3 = Themes.Border.Secondary,
                            BackgroundTransparency = 0.7,
                            BorderSizePixel = 0,
                            Visible = true,
                            ClipsDescendants = true,
                            Parent = Text
                        })
                        UICorner({1, 0}, Subline)
                    end
                    
                    Lib:AutoUpdateText(Text)
                    
                    -- Função para atualizar o sublinhado
                    local function UpdateSubline()
                        if Subline then
                            task.wait()
                            local textSize = game:GetService("TextService"):GetTextSize(
                                Text.Text,
                                Text.TextSize,
                                Text.Font,
                                Vector2.new(10000, math.huge)
                            )
                            local textWidth = textSize.X + 2
                            Subline.Size = UDim2.new(0, textWidth, 0, 1)
                        end
                    end
                    
                    local function UpdateHeight()
                        task.wait()
                        local textHeight = Text.AbsoluteSize.Y
                        local sublineHeight = Label.Settings.Subline and 6 or 0
                        Element_Label.Size = UDim2.new(1, 0, 0, textHeight + sublineHeight + 4)
                        UpdateSubline()
                    end
                    
                    local textChangedConnection = Text:GetPropertyChangedSignal("Text"):Connect(UpdateHeight)
                    table.insert(Label._connections, textChangedConnection)
                    
                    local sizeChangedConnection = Text:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateHeight)
                    table.insert(Label._connections, sizeChangedConnection)
                    
                    function Label:SetText(text)
                        Text.Text = text
                        UpdateHeight()
                    end
                    
                    function Label:GetText()
                        return Text.Text
                    end
                    
                    function Label:SetTransparency(trans)
                        Text.TextTransparency = trans
                    end
                    
                    function Label:GetTransparency()
                        return Text.TextTransparency
                    end
                    
                    function Label:SetAlignment(alignment)
                        Text.TextXAlignment = alignment == "Center" and Enum.TextXAlignment.Center or 
                                              alignment == "Right" and Enum.TextXAlignment.Right or 
                                              Enum.TextXAlignment.Left
                        Label.Settings.Alignment = alignment
                        UpdateSubline()
                    end
                    
                    function Label:GetAlignment()
                        return Label.Settings.Alignment
                    end
                    
                    function Label:SetBold(bold)
                        Text.Font = bold and Enum.Font.GothamBold or Themes.Font.Text
                        Label.Settings.Bold = bold
                        UpdateSubline()
                    end
                    
                    function Label:GetBold()
                        return Label.Settings.Bold
                    end
                    
                    function Label:SetSubline(enabled)
                        if enabled and not Subline then
                            Subline = CreateElement("Frame", {
                                Size = UDim2.new(0, 0, 0, 1),
                                AnchorPoint = Vector2.new(0, 1),
                                Position = UDim2.new(0, 0, 1, 4),
                                BackgroundColor3 = Themes.Border.Secondary,
                                BackgroundTransparency = 0.7,
                                BorderSizePixel = 0,
                                Visible = true,
                                ClipsDescendants = true,
                                Parent = Text
                            })
                            UICorner({1, 0}, Subline)
                            UpdateSubline()
                        elseif not enabled and Subline then
                            Subline:Destroy()
                            Subline = nil
                        end
                        Label.Settings.Subline = enabled
                        UpdateHeight()
                    end
                    
                    function Label:GetSubline()
                        return Label.Settings.Subline
                    end
                    
                    function Label:SetVisible(visible)
                        Element_Label.Visible = visible
                    end
                    
                    function Label:GetVisible()
                        return Element_Label.Visible
                    end
                    
                    function Label:Remove()
                        Label:Destroy()
                    end
                    
                    function Label:Destroy()
                        for _, conn in ipairs(Label._connections) do
                            conn:Disconnect()
                        end
                        Element_Label:Destroy()
                    end
                    
                    UpdateHeight()
                    
                    if Flag then
                        Lib.Features[Flag] = Label
                    end
                    
                    return Label
                end
                
                function Section:Paragraph(Flag, Settings)
                    Settings = Settings or {}
                    Settings.Title = Settings.Title or "Title"
                    Settings.Text = Settings.Text or "Paragraph"
                    Settings.Bold = Settings.Bold or {Type = "Title", Enabled = false}
                    
                    local Paragraph = {
                        Settings = Settings, 
                        Class = "Paragraph",
                        IgnoreConfig = false,
                        Hover = false, 
                        Active = false,
                        _connections = {}
                    }
                    
                    local Element = Themes.Elements.Paragraph
                    
                    Paragraph.Settings.Title = Paragraph.Settings.Title or "Title"
                    Paragraph.Settings.Text = Paragraph.Settings.Text or "Paragraph"
                    Paragraph.Settings.Bold = Paragraph.Settings.Bold or {Type = "Title", Enabled = false}
                    
                    local Element_Paragraph = CreateElement("Frame", {
                        Name = Paragraph.Settings.Title,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        AnchorPoint = Vector2.new(0, 0),
            		    Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 0.07,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 7}, Element_Paragraph)
                    UIStroke(1, 0.2, Themes.Border.Primary, Element_Paragraph)
                    UIPadding({0, 0}, {0, 8, 0, 8}, Element_Paragraph)
                    
                    -- Frame do Título
                    local Frame_Title = CreateElement("Frame", {
                        Name = "Title_Frame",
                        Size = UDim2.new(1, 0, 0, 25),
                        AnchorPoint = Vector2.new(0.5, 0),
            		    Position = UDim2.new(0.5, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = false,
                        Parent = Element_Paragraph
                    })
                
                    -- Título
                    local Title = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = Paragraph.Settings.Title,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.3,
                        TextScaled = false,
                        TextSize = 14,
                        Font = (Paragraph.Settings.Bold.Type == "Title" or Paragraph.Settings.Bold.Type == "Both") and Paragraph.Settings.Bold.Enabled and Enum.Font.GothamBold or Themes.Font.Title,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Frame_Title
                    })
                    
                    -- Linha divisória
                    CreateElement("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        AnchorPoint = Vector2.new(0.5, 1),
                        Position = UDim2.new(0.5, 0, 1, 0),
                        BackgroundColor3 = Themes.Border.Secondary,
                        BackgroundTransparency = 0.7,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Frame_Title
                    })
                    
                    -- Texto do parágrafo
                    local Text = CreateElement("TextLabel", {
                        Size = UDim2.new(1, 0, 0, 0),
                        AnchorPoint = Vector2.new(0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Position = UDim2.new(0, 0, 0, 28),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = false,
                        
                        Text = Paragraph.Settings.Text,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.5,
                        TextScaled = false,
                        TextSize = 12,
                        Font = (Paragraph.Settings.Bold.Type == "Text" or Paragraph.Settings.Bold.Type == "Both") and Paragraph.Settings.Bold.Enabled and Enum.Font.GothamBold or Themes.Font.Text,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        
                        Parent = Element_Paragraph
                    })
                    
                    Lib:AutoUpdateText(Title)
                    
                    -- Função para atualizar altura
                    local function UpdateHeight()
                        task.wait()
                        local textHeight = Text.AbsoluteSize.Y
                        Element_Paragraph.Size = UDim2.new(1, 0, 0, textHeight + 32)
                    end
                    
                    local textChangedConnection = Text:GetPropertyChangedSignal("Text"):Connect(UpdateHeight)
                    table.insert(Paragraph._connections, textChangedConnection)
                    
                    local sizeChangedConnection = Text:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateHeight)
                    table.insert(Paragraph._connections, sizeChangedConnection)
                    
                    -- Função para atualizar bold
                    local function UpdateBold()
                        local boldType = Paragraph.Settings.Bold.Type
                        local enabled = Paragraph.Settings.Bold.Enabled
                        
                        if boldType == "Title" or boldType == "Both" then
                            Title.Font = enabled and Enum.Font.GothamBold or Themes.Font.Title
                        end
                        
                        if boldType == "Text" or boldType == "Both" then
                            Text.Font = enabled and Enum.Font.GothamBold or Themes.Font.Text
                        end
                    end
                    
                    -- Funções públicas
                    function Paragraph:SetTitle(title)
                        Title.Text = title
                        Paragraph.Settings.Title = title
                    end
                    
                    function Paragraph:GetTitle()
                        return Paragraph.Settings.Title
                    end
                    
                    function Paragraph:SetText(text)
                        Text.Text = text
                        UpdateHeight()
                    end
                    
                    function Paragraph:GetText()
                        return Text.Text
                    end
                    
                    function Paragraph:SetBold(type, enabled)
                        Paragraph.Settings.Bold.Type = type or Paragraph.Settings.Bold.Type
                        Paragraph.Settings.Bold.Enabled = enabled ~= nil and enabled or Paragraph.Settings.Bold.Enabled
                        UpdateBold()
                    end
                    
                    function Paragraph:GetBold()
                        return Paragraph.Settings.Bold
                    end
                    
                    function Paragraph:SetTransparency(trans)
                        Text.TextTransparency = trans
                    end
                    
                    function Paragraph:GetTransparency()
                        return Text.TextTransparency
                    end
                    
                    function Paragraph:SetVisible(visible)
                        Element_Paragraph.Visible = visible
                    end
                    
                    function Paragraph:GetVisible()
                        return Element_Paragraph.Visible
                    end
                    
                    function Paragraph:Remove()
                        Paragraph:Destroy()
                    end
                    
                    function Paragraph:Destroy()
                        for _, conn in ipairs(Paragraph._connections) do
                            conn:Disconnect()
                        end
                        Element_Paragraph:Destroy()
                    end
                    
                    UpdateHeight()
                    
                    if Flag then
                        Lib.Features[Flag] = Paragraph
                    end
                    
                    return Paragraph
                end
                
                function Section:Button(Flag, Settings)
                    local Button = {
                        Settings = Settings, 
                        Class = "Button",
                        IgnoreConfig = false,
                        Hover = false, 
                        Active = false
                    }
                    
                    local Element = Themes.Elements.Button
                    
                    Button.Settings.Name = Button.Settings.Name or "Button"
                    Button.Settings.Callback = Button.Settings.Callback or function() end
                    
                    local Element_Button = CreateElement("Frame", {
                        Name = Button.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
            		    Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 0.07,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 7}, Element_Button)
                    UIStroke(1, 0.2, Themes.Border.Primary, Element_Button)
                    UIPadding({0, 0}, {0, 8, 0, 8}, Element_Button)
                    
                    local Title = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 13),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = Button.Settings.Name,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_Button
                    })
                    
                    local Stroke_Thumb = CreateElement("Frame", {
                        Name = Button.Settings.Name,
                        Size = UDim2.fromOffset(10, 10),
                        AnchorPoint = Vector2.new(1, 0.5),
            		    Position = UDim2.new(1, 0, 0.5, 0),
                        BackgroundColor3 = Element.Thumb,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Element_Button
                    })
                    
                    local Center_Thumb = CreateElement("Frame", {
                        Name = Button.Settings.Name,
                        Size = UDim2.fromOffset(8, 8),
                        AnchorPoint = Vector2.new(0.5, 0.5),
            		    Position = UDim2.new(0.5, 0, 0.5, 0),
                        BackgroundColor3 = Element.Thumb,
                        BackgroundTransparency = 0.6,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Stroke_Thumb
                    })
                    
                    UICorner({1, 0}, Center_Thumb)
                    UICorner({1, 0}, Stroke_Thumb)
                    UIStroke(1, 0.6, Element.Thumb, Stroke_Thumb)
                    
                    local OnClick = CreateElement("TextButton", {
                        Parent = Element_Button,
                        BackgroundTransparency = 1.000,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        AutoButtonColor = false,
                        Text = "",
                        TextSize = 0.000,
                    })
                    
                    Lib:AutoUpdateText(Title)
                    Lib:HoverElements(Button.Active, Button.Hover, OnClick, Title)
                    
                    local function Callback()
                        pcall(Button.Settings.Callback)
                    end
                    
                    OnClick.MouseButton1Click:Connect(function()
                        Callback()
                    end)
                    
                    if Flag then
                        Lib.Features[Flag] = Button
                    end
                    
                    return Button
                end
                
                function Section:Toggle(Flag, Settings)
                    Settings = Settings or {}
                    Settings.Name = Settings.Name or "Toggle"
                    Settings.Default = Settings.Default or false
                    Settings.Style = Settings.Style or 1 -- 1 = Moderno, 2 = Bolinha
                    Settings.Callback = Settings.Callback or function() end

                    pcall(Settings.Callback, Settings.Default)
                
                    local Toggle = {
                        Settings = Settings, 
                        Class = "Toggle",
                        Value = Settings.Default,
                        IgnoreConfig = false,
                        Hover = false, 
                        Active = false,
                        _connections = {}
                    }
                    
                    local Element = Themes.Elements.Toggle
                    
                    Toggle.Settings.Name = Toggle.Settings.Name or "Toggle"
                    Toggle.Settings.Default = Toggle.Settings.Default or false
                    Toggle.Settings.Style = Toggle.Settings.Style or 1
                    Toggle.Settings.Callback = Toggle.Settings.Callback or function() end
                    
                    pcall(Toggle.Settings.Callback, Toggle.Settings.Default)
                    
                    local Element_Toggle = CreateElement("Frame", {
                        Name = Toggle.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
            		    Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 7}, Element_Toggle)
                    
                    local Title = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 13),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = Toggle.Settings.Name,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_Toggle
                    })
                    
                    Lib:AutoUpdateText(Title)
                    
                    -- ============================================
                    -- STYLE 1: MODERNO
                    -- ============================================
                    if Toggle.Settings.Style == 1 then
                        UIPadding({0, 0}, {0, 5, 0, 0}, Element_Toggle)
                        
                        local Element_Track = CreateElement("Frame", {
                            Size = UDim2.new(0, 38, 0, 17),
                            AnchorPoint = Vector2.new(1, 0.5),
            		        Position = UDim2.new(1, -5, 0.5, 0),
                            BackgroundColor3 = Element.Track,
                            BackgroundTransparency = 0.07,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            Parent = Element_Toggle
                        })
                        
                        UICorner({0, 7}, Element_Track)
                        UIStroke(1, 0.2, Themes.Border.Primary, Element_Track)
                        UIPadding({0, 0}, {0, 3, 0, 3}, Element_Track)
                        
                        local Element_Thumb = CreateElement("Frame", {
                            Size = UDim2.fromOffset(12, 12),
                            AnchorPoint = Vector2.new(0, 0.5),
            		        Position = UDim2.new(0, 0, 0.5, 0),
                            BackgroundColor3 = Element.Thumb,
                            BackgroundTransparency = 0.7,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            Parent = Element_Track
                        })
                        
                        UICorner({0, 4}, Element_Thumb)
                        
                        local function Activate()
                            TweenService:Create(Element_Thumb, TweenInfo.new(0.2), {
                                BackgroundTransparency = 0.3,
                                AnchorPoint = Vector2.new(1, 0.5),
            		            Position = UDim2.new(1, 0, 0.5, 0),
                            }):Play()
                        end
                        
                        local function Desactivate()
                            TweenService:Create(Element_Thumb, TweenInfo.new(0.2), {
                                BackgroundTransparency = 0.7,
                                AnchorPoint = Vector2.new(0, 0.5),
            		            Position = UDim2.new(0, 0, 0.5, 0),
                            }):Play()
                        end
                        
                        local OnClick = CreateElement("TextButton", {
                            Parent = Element_Toggle,
                            BackgroundTransparency = 1.000,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 1, 0),
                            AutoButtonColor = false,
                            Text = "",
                            TextSize = 0.000,
                        })
                        
                        Lib:HoverElements(Toggle.Active, Toggle.Hover, OnClick, Title)
                        
                        local Toggle_State = Toggle.Value
                        
                        local function Callback()
                            Toggle_State = not Toggle_State
                            Toggle.Value = Toggle_State
                            pcall(Toggle.Settings.Callback, Toggle_State)
                            if Toggle_State then
                                Activate()
                            else
                                Desactivate()
                            end
                        end
                        
                        OnClick.MouseButton1Click:Connect(function()
                            Callback()
                        end)
                        
                        if Toggle_State then
                            Activate()
                        else
                            Desactivate()
                        end
                        
                        -- ============================================
                        -- MÉTODOS PÚBLICOS
                        -- ============================================
                        function Toggle:SetValue(value)
                            if value ~= Toggle_State then
                                Toggle_State = value
                                Toggle.Value = value
                                if value then
                                    Activate()
                                else
                                    Desactivate()
                                end
                                pcall(Toggle.Settings.Callback, value)
                            end
                        end
                        
                        function Toggle:GetValue()
                            return Toggle_State
                        end
                        
                        function Toggle:SetName(text)
                            Title.Text = text
                        end
                        
                        function Toggle:GetName()
                            return Title.Text
                        end
                        
                        function Toggle:Destroy()
                            Element_Toggle:Destroy()
                        end
                        
                    -- ============================================
                    -- STYLE 2: BOLINHA
                    -- ============================================
                    elseif Toggle.Settings.Style == 2 then
                        UIPadding({0, 0}, {0, 8, 0, 8}, Element_Toggle)
                        UIStroke(1, 0.2, Themes.Border.Primary, Element_Toggle)
                        Element_Toggle.BackgroundTransparency = 0.07
                        
                        local Element_Track = CreateElement("Frame", {
                            Size = UDim2.fromOffset(10, 10),
                            AnchorPoint = Vector2.new(1, 0.5),
            		        Position = UDim2.new(1, 0, 0.5, 0),
                            BackgroundColor3 = Element.Track,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            Parent = Element_Toggle
                        })
                        
                        UICorner({1, 0}, Element_Track)
                        
                        local Stroke_Thumb = CreateElement("Frame", {
                            Name = "Stroke_Thumb",
                            Size = UDim2.fromOffset(8, 8),
                            AnchorPoint = Vector2.new(0.5, 0.5),
            		        Position = UDim2.new(0.5, 0, 0.5, 0),
                            BackgroundColor3 = Element.Thumb,
                            BackgroundTransparency = 0.3,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            Parent = Element_Track
                        })
                        
                        UICorner({1, 0}, Stroke_Thumb)
                        UIStroke(1, 0.5, Element.Thumb, Element_Track)
                        
                        local OnClick = CreateElement("TextButton", {
                            Parent = Element_Toggle,
                            BackgroundTransparency = 1.000,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 1, 0),
                            AutoButtonColor = false,
                            Text = "",
                            TextSize = 0.000,
                        })
                        
                        Lib:HoverElements(Toggle.Active, Toggle.Hover, OnClick, Title)
                        
                        local Toggle_State = Toggle.Value
                        
                        local function Activate()
                            TweenService:Create(Stroke_Thumb, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0.15,
                            }):Play()
                        end
                        
                        local function Desactivate()
                            TweenService:Create(Stroke_Thumb, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 1,
                            }):Play()
                        end
                        
                        local function Callback()
                            Toggle_State = not Toggle_State
                            Toggle.Value = Toggle_State
                            pcall(Toggle.Settings.Callback, Toggle_State)
                            if Toggle_State then
                                Activate()
                            else
                                Desactivate()
                            end
                        end
                        
                        OnClick.MouseButton1Click:Connect(function()
                            Callback()
                        end)
                        
                        if Toggle_State then
                            Activate()
                        else
                            Desactivate()
                        end
                        
                        -- ============================================
                        -- MÉTODOS PÚBLICOS
                        -- ============================================
                        function Toggle:SetValue(value)
                            if value ~= Toggle_State then
                                Toggle_State = value
                                Toggle.Value = value
                                if value then
                                    Activate()
                                else
                                    Desactivate()
                                end
                                pcall(Toggle.Settings.Callback, value)
                            end
                        end
                        
                        function Toggle:GetValue()
                            return Toggle_State
                        end
                        
                        function Toggle:SetName(text)
                            Title.Text = text
                        end
                        
                        function Toggle:GetName()
                            return Title.Text
                        end
                        
                        function Toggle:Destroy()
                            Element_Toggle:Destroy()
                        end
                    end
                    
                    if Flag then
                        Lib.Features[Flag] = Toggle
                    end
                    
                    return Toggle
                end
                
                function Section:Checkbox(Flag, Settings)
    Settings = Settings or {}
    Settings.Name = Settings.Name or "Checkbox"
    Settings.Default = Settings.Default or false
    Settings.Callback = Settings.Callback or function() end

    pcall(Settings.Callback, Settings.Default)

    local Checkbox = {
        Settings = Settings,
        Class = "Checkbox",
        Value = Settings.Default,
        IgnoreConfig = false,
        Hover = false,
        Active = false,
        _connections = {}
    }

    local Element = Themes.Elements.Checkbox

    Checkbox.Settings.Name = Checkbox.Settings.Name or "Checkbox"
    Checkbox.Settings.Default = Checkbox.Settings.Default or false
    Checkbox.Settings.Callback = Checkbox.Settings.Callback or function() end

    pcall(Checkbox.Settings.Callback, Checkbox.Settings.Default)

    local Element_Checkbox = CreateElement("Frame", {
        Name = Checkbox.Settings.Name,
        Size = UDim2.new(1, 0, 0, 30),
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Element.Primary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Section_Frame
    })

    UICorner({0, 7}, Element_Checkbox)
    UIPadding({0, 0}, {0, 5, 0, 0}, Element_Checkbox)

    local Title = CreateElement("TextLabel", {
        Size = UDim2.new(0, 0, 0, 13),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = true,
        ClipsDescendants = true,

        Text = Checkbox.Settings.Name,
        TextColor3 = Element.Text,
        TextTransparency = 0.4,
        TextScaled = false,
        TextSize = 13,
        Font = Themes.Font.Text,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        Parent = Element_Checkbox
    })

    local Element_Track = CreateElement("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        BackgroundColor3 = Element.Track,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Visible = true,
        Active = true,
        ClipsDescendants = true,
        Parent = Element_Checkbox
    })

    UICorner({0, 5}, Element_Track)
    UIStroke(1, 0.2, Themes.Border.Primary, Element_Track)

    local Icon = CreateElement("ImageLabel", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ImageColor3 = Element.Thumb,
        Image = "rbxassetid://" .. tostring(Icons:GetIcon("Check")),
        ImageTransparency = 1,
        Size = UDim2.fromOffset(15, 15),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = Element_Track,
    })

    UICorner({0, 4}, Element_Thumb)

    local OnClick = CreateElement("TextButton", {
        Parent = Element_Checkbox,
        BackgroundTransparency = 1.000,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        AutoButtonColor = false,
        Text = "",
        TextSize = 0.000,
    })

    Lib:AutoUpdateText(Title)
    Lib:HoverElements(Checkbox.Active, Checkbox.Hover, OnClick, Title)

    local Checkbox_State = Checkbox.Value

    local function Activate()
        TweenService:Create(Icon, TweenInfo.new(0.2), {
            ImageTransparency = 0.3,
        }):Play()
    end

    local function Desactivate()
        TweenService:Create(Icon, TweenInfo.new(0.2), {
            ImageTransparency = 1,
        }):Play()
    end

    local function Callback()
        Checkbox_State = not Checkbox_State
        Checkbox.Value = Checkbox_State
        pcall(Checkbox.Settings.Callback, Checkbox_State)
        if Checkbox_State then
            Activate()
        else
            Desactivate()
        end
    end

    OnClick.MouseButton1Click:Connect(function()
        Callback()
    end)

    if Checkbox_State then
        Activate()
    else
        Desactivate()
    end

    -- ============================================
    -- MÉTODOS PÚBLICOS PARA SAVE/LOAD
    -- ============================================

    function Checkbox:GetValue()
        return Checkbox_State
    end

    function Checkbox:SetValue(value)
        Checkbox_State = value
        Checkbox.Value = value
        if value then
            Activate()
        else
            Desactivate()
        end
        pcall(Checkbox.Settings.Callback, value)
    end

    function Checkbox:Toggle()
        Callback()
    end

    function Checkbox:SetName(text)
        Title.Text = text
        Checkbox.Settings.Name = text
    end

    function Checkbox:GetName()
        return Title.Text
    end

    function Checkbox:SetVisible(visible)
        Element_Checkbox.Visible = visible
    end

    function Checkbox:GetVisible()
        return Element_Checkbox.Visible
    end

    function Checkbox:Destroy()
        for _, conn in ipairs(Checkbox._connections or {}) do
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end
        Element_Checkbox:Destroy()
    end

    -- ============================================
    -- REGISTRAR PARA SAVE/LOAD
    -- ============================================

    if Flag then
        Lib.Features[Flag] = Checkbox
        -- Registrar no sistema de save/load
        if SaveLoadSystem and SaveLoadSystem.RegisterCheckbox then
            SaveLoadSystem:RegisterCheckbox(Flag, Checkbox)
        end
    end

    return Checkbox
end
                
                function Section:Slider(Flag, Settings)
                    Settings = Settings or {}
                    Settings.Name = Settings.Name or "Slider"
                    Settings.DisplayMethod = Settings.DisplayMethod or "Value"
                    Settings.Default = Settings.Default or 50
                    Settings.Minimum = Settings.Minimum or 0
                    Settings.Maximum = Settings.Maximum or 100
                    Settings.Precision = Settings.Precision or 0
                    Settings.Callback = Settings.Callback or function() end

                    pcall(Settings.Callback, Settings.Default)
                
                    local Slider = {
                        Settings = Settings, 
                        Class = "Slider",
                        Value = nil,
                        Minimun = Settings.Minimum,
                        Maximun = Settings.Maximum,
                        _connections = {},
                        IgnoreConfig = false,
                        Hover = false, 
                        Active = false
                    }
                    
                    local Element = Themes.Elements.Slider
                    
                    Slider.Settings.Name = Slider.Settings.Name or "Slider"
                    Slider.Settings.Default = Slider.Settings.Default or 50
                    Slider.Settings.Minimum = Slider.Settings.Minimum or 0
                    Slider.Settings.Maximum = Slider.Settings.Maximum or 100
                    Slider.Settings.Precision = Slider.Settings.Precision or 0
                    Slider.Settings.DisplayMethod = Slider.Settings.DisplayMethod or "Value"
                    Slider.Settings.Callback = Slider.Settings.Callback or function() end
                    
                    Slider.Value = math.clamp(Slider.Settings.Default, Slider.Settings.Minimum, Slider.Settings.Maximum)
                    
                    local DisplayMethods = {
                        Hundredths = function(sliderValue, precision)
                            return string.format("%.2f", sliderValue)
                        end,
                        Tenths = function(sliderValue, precision)
                            return string.format("%.1f", sliderValue)
                        end,
                        Round = function(sliderValue, precision)
                            if precision and precision > 0 then
                                return string.format("%." .. precision .. "f", sliderValue)
                            else
                                return tostring(math.round(sliderValue))
                            end
                        end,
                        Degrees = function(sliderValue, precision)
                            local formattedValue = precision and precision > 0 and string.format("%." .. precision .. "f", sliderValue) or tostring(math.round(sliderValue))
                            return formattedValue .. "°"
                        end,
                        Percent = function(sliderValue, minimum, maximum, precision)
                            local percentage = ((sliderValue - minimum) / (maximum - minimum)) * 100
                            if precision and precision > 0 then
                                return string.format("%." .. precision .. "f", percentage) .. "%"
                            else
                                return tostring(math.round(percentage)) .. "%"
                            end
                        end,
                        Value = function(sliderValue, precision)
                            if precision and precision > 0 then
                                return string.format("%." .. precision .. "f", sliderValue)
                            else
                                return tostring(math.round(sliderValue))
                            end
                        end
                    }
                    
                    local function GetDisplayValue(value)
                        local method = DisplayMethods[Slider.Settings.DisplayMethod] or DisplayMethods.Value
                        
                        if Slider.Settings.DisplayMethod == "Percent" then
                            return method(value, Slider.Settings.Minimum, Slider.Settings.Maximum, Slider.Settings.Precision)
                        else
                            return method(value, Slider.Settings.Precision)
                        end
                    end
                    
                    local Element_Slider = CreateElement("Frame", {
                        Name = Slider.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
            		    Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 7}, Element_Slider)
                    UIPadding({0, 0}, {0, 5, 0, 5}, Element_Slider)
                    
                    local Title = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 13),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = Slider.Settings.Name,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_Slider
                    })
                    
                    local Element_Line = CreateElement("Frame", {
                        Size = UDim2.new(0, 0, 0, 2),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = Element.Line,
                        BackgroundTransparency = 0.4,
                        BorderSizePixel = 0,
                        Visible = true,
                        Active = true,
                        ClipsDescendants = false,
                        Parent = Element_Slider
                    })
                    
                    UICorner({0, 5}, Element_Line)
                    
                    local Element_Track = CreateElement("Frame", {
                        Size = UDim2.new(0.5, 0, 1, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = Element.Track,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = true,
                        Active = true,
                        ClipsDescendants = false,
                        Parent = Element_Line
                    })
                    
                    UICorner({0, 5}, Element_Track)
                    
                    local Element_Thumb = CreateElement("Frame", {
                        Size = UDim2.fromOffset(14, 14),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 7, 0.5, 0),
                        BackgroundColor3 = Element.Thumb,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = true,
                        Active = true,
                        ClipsDescendants = false,
                        Parent = Element_Track
                    })
                    
                    UICorner({1, 0}, Element_Thumb)
                    
                    local Display_Value = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 13),
                        AnchorPoint = Vector2.new(1, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = GetDisplayValue(Slider.Value),
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_Slider
                    })
                    
                    local SliderButton = CreateElement("TextButton", {
                        Parent = Element_Line,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 2.5, 0),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutoButtonColor = false,
                        Text = "",
                        TextSize = 0,
                    })
                    
                    Lib:HoverElements(Slider.Active, Slider.Hover, Title, Title)
                    
                    local TextSize = game:GetService("TextService"):GetTextSize(
                        Title.Text,
                        Title.TextSize,
                        Title.Font,
                        Vector2.new(10000, math.huge)
                    )
                    
                    local ValueSize = game:GetService("TextService"):GetTextSize(
                        Display_Value.Text,
                        Display_Value.TextSize,
                        Display_Value.Font,
                        Vector2.new(10000, math.huge)
                    )
                    
                    Title.Size = UDim2.new(0, TextSize.X, 0, TextSize.Y)
                    Element_Line.Size = UDim2.new(1, - TextSize.X - ValueSize.X - 20, 0, 2)
                    Element_Line.Position = UDim2.new(1, - ValueSize.X - 13, 0.5, 0)
                    
                    Display_Value:GetPropertyChangedSignal("Text"):Connect(function()
                	    task.wait()
                	    local vl = game:GetService("TextService"):GetTextSize(
                            Display_Value.Text,
                            Display_Value.TextSize,
                            Display_Value.Font,
                            Vector2.new(10000, math.huge)
                        )
                	    
                	    Element_Line.Size = UDim2.new(1, - TextSize.X - vl.X - 20, 0, 2)
                        Element_Line.Position = UDim2.new(1, - vl.X - 13, 0.5, 0)
                	end)
                	
                	local function UpdateSliderVisual()
                        local min = Slider.Settings.Minimum
                        local max = Slider.Settings.Maximum
                        local value = Slider.Value
                        local ratio = (value - min) / (max - min)
                        ratio = math.clamp(ratio, 0, 1)
                        Element_Track.Size = UDim2.new(ratio, 0, 1, 0)
                        Element_Thumb.Position = UDim2.new(1, 0, 0.5, 0)
                        Display_Value.Text = GetDisplayValue(value)
                    end
                    
                    local function SetValue(newValue, fromUserInput)
                        local min = Slider.Settings.Minimum
                        local max = Slider.Settings.Maximum
                        local precision = Slider.Settings.Precision
                        
                        if precision and precision > 0 then
                            local multiplier = 10 ^ precision
                            newValue = math.floor(newValue * multiplier + 0.5) / multiplier
                        else
                            newValue = math.round(newValue)
                        end
                        
                        newValue = math.clamp(newValue, min, max)
                        
                        if Slider.Value ~= newValue then
                            Slider.Value = newValue
                            UpdateSliderVisual()
                            task.spawn(function()
                                if fromUserInput then
                                    pcall(Slider.Settings.Callback, newValue)
                                end
                            end)
                        end
                    end
                    
                    local isDragging = false
                
                    local function GetValueFromPosition(positionX)
                        local absolutePosition = Element_Line.AbsolutePosition.X
                        local absoluteSize = Element_Line.AbsoluteSize.X
                        
                        local relativePosition = (positionX - absolutePosition) / absoluteSize
                        relativePosition = math.clamp(relativePosition, 0, 1)
                        
                        local min = Slider.Settings.Minimum
                        local max = Slider.Settings.Maximum
                        local value = min + (relativePosition * (max - min))
                        
                        return value
                    end
                    
                    local function StartDrag(input)
                        isDragging = true
                        Slider.Active = true
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local value = GetValueFromPosition(input.Position.X)
                            SetValue(value, true)
                        end
                    end
                    
                    local function UpdateDrag(input)
                        if not isDragging then return end
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            local value = GetValueFromPosition(input.Position.X)
                            SetValue(value, true)
                        end
                    end
                    
                    local function StopDrag()
                        if isDragging then
                            isDragging = false
                            Slider.Active = false
                        end
                    end
                    
                    local function SetupInputEvents()
                        Slider._connections.InputBegan = SliderButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                StartDrag(input)
                            end
                        end)
                        
                        Slider._connections.InputChanged = SliderButton.InputChanged:Connect(function(input)
                            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
                                UpdateDrag(input)
                            end
                        end)
                        
                        Slider._connections.InputEnded = SliderButton.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                StopDrag()
                            end
                        end)
                        
                        Slider._connections.GlobalInputEnded = UserInputService.InputEnded:Connect(function(input)
                            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
                                StopDrag()
                            end
                        end)
                    end
                    
                    SetupInputEvents()
                    
                    function Slider:SetValue(value)
                        local min = Slider.Settings.Minimum
                        local max = Slider.Settings.Maximum
                        local precision = Slider.Settings.Precision
                        
                        if precision and precision > 0 then
                            local multiplier = 10 ^ precision
                            value = math.floor(value * multiplier + 0.5) / multiplier
                        else
                            value = math.round(value)
                        end
                        
                        value = math.clamp(value, min, max)
                        Slider.Value = value
                        UpdateSliderVisual()
                        pcall(Slider.Settings.Callback, value)
                    end
                    
                    function Slider:GetValue()
                        return Slider.Value
                    end
                    
                    function Slider:GetDisplayMethod()
                        return Slider.Settings.DisplayMethod
                    end
                    
                    function Slider:SetName(text)
                        Title.Text = text
                    end
                    
                    function Slider:GetName()
                        return Title.Text
                    end
                    
                    function Slider:Destroy()
                        for _, conn in pairs(Slider._connections) do
                            if conn and conn.Disconnect then
                                conn:Disconnect()
                            end
                        end
                        Element_Slider:Destroy()
                    end
                    
                    UpdateSliderVisual()
                    
                    if Flag then
                        Lib.Features[Flag] = Slider
                    end
                    
                    return Slider
                end
                
                function Section:Dropdown(Flag, Settings)
                    local Dropdown = {
                        Settings = Settings,
                        SelectedValues = nil,
                        DropdownElements = {},
                        IsOpen = false,
                        Active = false,
                        Hover = false
                    }
                    
                    local Element = Themes.Elements.Dropdown
                    
                    Dropdown.Settings.Name = Dropdown.Settings.Name or "Dropdown"
                    Dropdown.Settings.Values = Dropdown.Settings.Values or {"Option 1", "Option 2"}
                    Dropdown.Settings.Default = Dropdown.Settings.Default or "Option 1"
                    Dropdown.Settings.Open = Dropdown.Settings.Open or false
                    Dropdown.Settings.MultiSelection = Dropdown.Settings.MultiSelection or false
                    Dropdown.Settings.Callback = Dropdown.Settings.Callback or function() end
                    
                    Dropdown.IsOpen = Dropdown.Settings.Open
                    
                    if Dropdown.Settings.MultiSelection then
                        Dropdown.SelectedValues = {}
                        
                        if Dropdown.Settings.Default then
                            if type(Dropdown.Settings.Default) == "table" then
                                for _, defaultValue in ipairs(Dropdown.Settings.Default) do
                                    if table.find(Dropdown.Settings.Values, defaultValue) then
                                        table.insert(Dropdown.SelectedValues, defaultValue)
                                    end
                                end
                            else
                                if table.find(Dropdown.Settings.Values, Dropdown.Settings.Default) then
                                    table.insert(Dropdown.SelectedValues, Dropdown.Settings.Default)
                                end
                            end
                        end
                    else
                        if Dropdown.Settings.Default and table.find(Dropdown.Settings.Values, Dropdown.Settings.Default) then
                            Dropdown.SelectedValues = Dropdown.Settings.Default
                        else
                            Dropdown.SelectedValues = Dropdown.Settings.Values[1] or ""
                        end
                    end
                    
                    local Dropdown_F = CreateElement("Frame", {
                        Name = Dropdown.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 8),
                        Parent = Dropdown_F
                    })
                    
                    CreateElement("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Thickness = 1,
                        Color = Themes.Border.Primary,
                        Parent = Dropdown_F,
                    })
                    
                    local Title_F = CreateElement("Frame", {
                        Name = "Title_".. Dropdown.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Dropdown_F
                    })
                    
                    local LINE = CreateElement("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        AnchorPoint = Vector2.new(1, 1),
                        Position = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Themes.Border.Primary,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = false,
                        ClipsDescendants = true,
                        Parent = Title_F
                    })
                    
                    local function TruncateTextToFit(text, maxWidth, textSize, font)
                        if not text or text == "" then return "" end
                        
                        local fullSize = game:GetService("TextService"):GetTextSize(
                            text,
                            textSize,
                            font,
                            Vector2.new(10000, math.huge)
                        )
                        
                        if fullSize.X <= maxWidth then
                            return text
                        end
                        
                        local truncated = text
                        local ellipsis = "..."
                        
                        for i = #text, 1, -1 do
                            local testText = text:sub(1, i) .. ellipsis
                            local testSize = game:GetService("TextService"):GetTextSize(
                                testText,
                                textSize,
                                font,
                                Vector2.new(10000, math.huge)
                            )
                            
                            if testSize.X <= maxWidth then
                                return testText
                            end
                        end
                        
                        return ellipsis
                    end
                    
                    local function GetSelectedText()
                        if Dropdown.Settings.MultiSelection then
                            if #Dropdown.SelectedValues > 0 then
                                return table.concat(Dropdown.SelectedValues, ", ")
                            else
                                return "None"
                            end
                        else
                            return tostring(Dropdown.SelectedValues)
                        end
                    end
                    
                    local function GetCallbackValue()
                        if Dropdown.Settings.MultiSelection then
                            if #Dropdown.SelectedValues > 0 then
                                return table.concat(Dropdown.SelectedValues, ", ")
                            else
                                return ""
                            end
                        else
                            return tostring(Dropdown.SelectedValues)
                        end
                    end
                    
                    local Title_Fs = CreateElement("Frame", {
                        Size = UDim2.new(0, 0, 1, 0),
                        AutomaticSize = Enum.AutomaticSize.X,
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Title_F
                    })
                    
                    local Title_Dropdown = CreateElement("TextLabel", {
                        Name = "Title_Dropdown",
                        Size = UDim2.new(0, 0, 0, 13),
                        AutomaticSize = Enum.AutomaticSize.X,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 8, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = "",
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Title_Fs
                    })
                
                    local Icon = CreateElement("ImageLabel", {
                        Name = "Icon",
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ImageColor3 = Element.Text,
                        Image = "rbxassetid://6031090990",
                        Rotation = 180,
                        ImageTransparency = 0.4,
                        Size = UDim2.fromOffset(13, 13),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -8, 0.5, 0),
                        Parent = Title_F,
                    })
                    
                    local OnClick = CreateElement("TextButton", {
                        Name = "OnClick",
                        Parent = Title_F,
                        BackgroundTransparency = 1.000,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        AutoButtonColor = false,
                        Text = "",
                        TextSize = 0.000,
                    })
                    
                    Lib:HoverElements(Dropdown.Active, Dropdown.Hover, OnClick, Title_Dropdown)
                    
                    local function UpdateTitle()
                        local fullText = Dropdown.Settings.Name.. ": ".. GetSelectedText()
                        
                        local availableWidth = Title_F.AbsoluteSize.X - 8 - 13 - 5 - 8
                        
                        if availableWidth > 0 then
                            local truncated = TruncateTextToFit(fullText, availableWidth, Title_Dropdown.TextSize, Title_Dropdown.Font)
                            Title_Dropdown.Text = truncated
                        else
                            Title_Dropdown.Text = fullText
                        end
                        
                        local textSize = game:GetService("TextService"):GetTextSize(
                            Title_Dropdown.Text,
                            Title_Dropdown.TextSize,
                            Title_Dropdown.Font,
                            Vector2.new(10000, math.huge)
                        )
                        Title_Dropdown.Size = UDim2.new(0, textSize.X + 2, 0, textSize.Y + 2)
                    end
                    
                    Title_F:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                        UpdateTitle()
                    end)
                    
                    local Content_Dropdown_F = CreateElement("Frame", {
                        Name = "Content_".. Dropdown.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 0),
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 0, 1, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Dropdown_F
                    })
                    
                    local UIListLayout = CreateElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 8),
                        Parent = Content_Dropdown_F
                    })
                    
                    CreateElement("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        Parent = Content_Dropdown_F
                    })
                    
                    CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 8),
                        Parent = Content_Dropdown_F
                    })
                    
                    local AnimationConnection
                    local CurrentTween
                    
                    local function ExecuteCallback()
                        if Dropdown.Settings.Callback then
                            task.spawn(function()
                                local callbackValue = GetCallbackValue()
                                Dropdown.Settings.Callback(callbackValue)
                            end)
                        end
                    end
                    
                    local function AnimateDropdown(open)
                        if CurrentTween then
                            CurrentTween:Cancel()
                        end
                        
                        TweenService:Create(Icon, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Rotation = open and 0 or 180
                        }):Play()
                        
                        local contentSize = UIListLayout.AbsoluteContentSize.Y
                        local targetHeight = open and (30 + contentSize + 16) or 30
                        local contentTargetHeight = open and (contentSize + 16) or 0
                        
                        CurrentTween = TweenService:Create(Dropdown_F, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, targetHeight)
                        })
                        CurrentTween:Play()
                        
                        TweenService:Create(Content_Dropdown_F, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, contentTargetHeight)
                        }):Play()
                        
                        LINE.Visible = true
                        TweenService:Create(LINE, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = open and 0 or 1
                        }):Play()
                    end
                
                    local function CreateDropdownItem(value, index)
                        local Button_F = CreateElement("Frame", {
                            Name = tostring(value),
                            Size = UDim2.new(1, 0, 0, 30),
                            AnchorPoint = Vector2.new(0, 0),
                            Position = UDim2.new(0, 0, 0, 0),
                            BackgroundColor3 = Element.Primary,
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Visible = true,
                            ClipsDescendants = true,
                            LayoutOrder = index,
                            Parent = Content_Dropdown_F
                        })
                        
                        table.insert(Dropdown.DropdownElements, Button_F)
                        
                        CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 8),
                            Parent = Button_F
                        })
                        
                        CreateElement("UIStroke", {
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                            Thickness = 1,
                            Color = Themes.Border.Primary,
                            Parent = Button_F,
                        })
                        
                        local Title_Button = CreateElement("TextLabel", {
                            Name = "Title_Button",
                            Size = UDim2.new(0, 0, 0, 13),
                            AutomaticSize = Enum.AutomaticSize.X,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 8, 0.5, 0),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Visible = true,
                            ClipsDescendants = true,
                            
                            Text = tostring(value),
                            TextColor3 = Element.Text,
                            TextTransparency = 0.4,
                            TextScaled = false,
                            TextSize = 14,
                            Font = Themes.Font.Text,
                            TextWrapped = true,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            
                            Parent = Button_F
                        })
                        
                        if Dropdown.Settings.MultiSelection then
                            local InvisCircle = CreateElement("Frame", {
                                Name = "InvisCircle",
                                Size = UDim2.fromOffset(11, 11),
                                AnchorPoint = Vector2.new(1, 0.5),
                                Position = UDim2.new(1, -8, 0.5, 0),
                                BackgroundColor3 = Element.Primary,
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                Visible = true,
                                ClipsDescendants = true,
                                Parent = Button_F
                            })
                            
                            CreateElement("UICorner", {
                                CornerRadius = UDim.new(1, 0),
                                Parent = InvisCircle
                            })
                            
                            CreateElement("UIStroke", {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                Thickness = 1,
                                Transparency = 0.6,
                                Color = Element.Track,
                                Parent = InvisCircle,
                            })
                            
                            local CenterBall = CreateElement("Frame", {
                                Name = "CenterBall",
                                Size = UDim2.fromOffset(8, 8),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                BackgroundColor3 = Element.Thumb,
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                Visible = true,
                                ClipsDescendants = true,
                                Parent = InvisCircle
                            })
                            
                            CreateElement("UICorner", {
                                CornerRadius = UDim.new(1, 0),
                                Parent = CenterBall
                            })
                            
                            local isSelected = table.find(Dropdown.SelectedValues, value) ~= nil
                            CenterBall.BackgroundTransparency = isSelected and 0.6 or 1
                            Title_Button.TextTransparency = isSelected and 0 or 0.4
                        else
                            local isSelected = Dropdown.SelectedValues == value
                            Title_Button.TextTransparency = isSelected and 0 or 0.4
                        end
                        
                        local ItemOnClick = CreateElement("TextButton", {
                            Name = "OnClick",
                            Parent = Button_F,
                            BackgroundTransparency = 1.000,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 1, 0),
                            AutoButtonColor = false,
                            Text = "",
                            TextSize = 0.000,
                        })
                        
                        ItemOnClick.MouseButton1Click:Connect(function()
                            if Dropdown.Settings.MultiSelection then
                                local index = table.find(Dropdown.SelectedValues, value)
                                if index then
                                    table.remove(Dropdown.SelectedValues, index)
                                else
                                    table.insert(Dropdown.SelectedValues, value)
                                end
                                
                                local InvisCircle = Button_F:FindFirstChild("InvisCircle")
                                if InvisCircle then
                                    local CenterBall = InvisCircle:FindFirstChild("CenterBall")
                                    if CenterBall then
                                        local isSelected = table.find(Dropdown.SelectedValues, value) ~= nil
                                        TweenService:Create(CenterBall, TweenInfo.new(0.15), {
                                            BackgroundTransparency = isSelected and 0.5 or 1
                                        }):Play()
                                        
                                        TweenService:Create(Title_Button, TweenInfo.new(0.15), {
                                            TextTransparency = isSelected and 0 or 0.4
                                        }):Play()
                                    end
                                end
                                
                                UpdateTitle()
                                ExecuteCallback()
                            else
                                Dropdown.SelectedValues = value
                                
                                Dropdown.IsOpen = false
                                AnimateDropdown(false)
                                
                                for _, item in pairs(Content_Dropdown_F:GetChildren()) do
                                    if item:IsA("Frame") and item.Name ~= "UIListLayout" and item.Name ~= "UIPadding" and item.Name ~= "UICorner" then
                                        local itemTitle = item:FindFirstChild("Title_Button")
                                        if itemTitle then
                                            local isSelected = item.Name == tostring(value)
                                            TweenService:Create(itemTitle, TweenInfo.new(0.15), {
                                                TextTransparency = isSelected and 0 or 0.4
                                            }):Play()
                                        end
                                    end
                                end
                                
                                UpdateTitle()
                                ExecuteCallback()
                            end
                        end)
                        
                        return Button_F
                    end
                    
                    local function CreateDropdownItems()
                        for _, element in pairs(Dropdown.DropdownElements) do
                            if element and element.Parent then
                                element:Destroy()
                            end
                        end
                        Dropdown.DropdownElements = {}
                        
                        for i, value in ipairs(Dropdown.Settings.Values) do
                            CreateDropdownItem(value, i)
                        end
                    end
                    
                    local function ToggleDropdown()
                        Dropdown.IsOpen = not Dropdown.IsOpen
                        
                        if Dropdown.IsOpen then
                            CreateDropdownItems()
                            task.wait()
                        end
                        
                        AnimateDropdown(Dropdown.IsOpen)
                    end
                    
                    if AnimationConnection then
                        AnimationConnection:Disconnect()
                    end
                    
                    AnimationConnection = UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if Dropdown.IsOpen then
                            local contentSize = UIListLayout.AbsoluteContentSize.Y
                            local targetHeight = 30 + contentSize + 16
                            
                            if CurrentTween then
                                CurrentTween:Cancel()
                            end
                            
                            CurrentTween = TweenService:Create(Dropdown_F, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(1, 0, 0, targetHeight)
                            })
                            CurrentTween:Play()
                            
                            TweenService:Create(Content_Dropdown_F, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(1, 0, 0, contentSize + 16)
                            }):Play()
                        end
                    end)
                    
                    OnClick.MouseButton1Click:Connect(function()
                        ToggleDropdown()
                    end)
                    
                    function Dropdown:AddValue(value)
                        table.insert(Dropdown.Settings.Values, value)
                        if Dropdown.IsOpen then
                            CreateDropdownItems()
                        end
                        UpdateTitle()
                        ExecuteCallback()
                    end
                    
                    function Dropdown:DelValue(value)
                        local index = table.find(Dropdown.Settings.Values, value)
                        if index then
                            table.remove(Dropdown.Settings.Values, index)
                            
                            if Dropdown.Settings.MultiSelection then
                                local selectedIndex = table.find(Dropdown.SelectedValues, value)
                                if selectedIndex then
                                    table.remove(Dropdown.SelectedValues, selectedIndex)
                                end
                            elseif Dropdown.SelectedValues == value then
                                Dropdown.SelectedValues = Dropdown.Settings.Values[1] or ""
                            end
                            
                            if Dropdown.IsOpen then
                                CreateDropdownItems()
                            end
                            UpdateTitle()
                            ExecuteCallback()
                        end
                    end
                    
                    function Dropdown:EditValue(oldValue, newValue)
                        local index = table.find(Dropdown.Settings.Values, oldValue)
                        if index then
                            Dropdown.Settings.Values[index] = newValue
                            
                            if Dropdown.Settings.MultiSelection then
                                local selectedIndex = table.find(Dropdown.SelectedValues, oldValue)
                                if selectedIndex then
                                    Dropdown.SelectedValues[selectedIndex] = newValue
                                end
                            elseif Dropdown.SelectedValues == oldValue then
                                Dropdown.SelectedValues = newValue
                            end
                            
                            if Dropdown.IsOpen then
                                CreateDropdownItems()
                            end
                            UpdateTitle()
                            ExecuteCallback()
                        end
                    end
                    
                    function Dropdown:GetValue()
                        return GetCallbackValue()
                    end
                    
                    function Dropdown:GetValues()
                        return Dropdown.Settings.Values
                    end
                    
                    function Dropdown:GetMultiSelection()
                        return Dropdown.Settings.MultiSelection
                    end
                    
                    function Dropdown:SetValue(value)
                        if Dropdown.Settings.MultiSelection then
                            if type(value) == "table" then
                                Dropdown.SelectedValues = value
                            elseif type(value) == "string" then
                                if value == "" then
                                    Dropdown.SelectedValues = {}
                                else
                                    Dropdown.SelectedValues = {}
                                    for item in value:gmatch("[^,]+") do
                                        table.insert(Dropdown.SelectedValues, item:match("^%s*(.-)%s*$"))
                                    end
                                end
                            else
                                Dropdown.SelectedValues = {value}
                            end
                        else
                            Dropdown.SelectedValues = value
                        end
                        
                        UpdateTitle()
                        
                        if Dropdown.IsOpen then
                            CreateDropdownItems()
                        end
                        
                        ExecuteCallback()
                    end
                    
                    function Dropdown:SetName(newName)
                        Dropdown.Settings.Name = newName
                        UpdateTitle()
                    end
                    
                    function Dropdown:GetName()
                        return Dropdown.Settings.Name
                    end
                    
                    function Dropdown:Destroy()
                        if AnimationConnection then
                            AnimationConnection:Disconnect()
                        end
                        if CurrentTween then
                            CurrentTween:Cancel()
                        end
                        Dropdown_F:Destroy()
                    end
                    
                    CreateDropdownItems()
                    UpdateTitle()
                    
                    task.spawn(function()
                        wait(0.1)
                        ExecuteCallback()
                    end)
                    
                    Content_Dropdown_F.Size = UDim2.new(1, 0, 0, 0)
                    
                    if Flag then
                        Lib.Features[Flag] = Dropdown
                    end
                    
                    return Dropdown
                end
                
                function Section:Input(Flag, Settings)
                    Settings = Settings or {}
                    Settings.Name = Settings.Name or "Input"
                    Settings.Default = Settings.Default or ""
                    Settings.Placeholder = Settings.Placeholder or ""
                    Settings.Numeric = Settings.Numeric or false
                    Settings.ClearOnFocus = Settings.ClearOnFocus or false
                    Settings.Callback = Settings.Callback or function() end

                    pcall(Settings.Callback, Settings.Default)
                
                    local Input = {
                        Settings = Settings,
                        Class = "Input",
                        Value = Settings.Default,
                        IgnoreConfig = false,
                        Hover = false,
                        Active = false,
                        _connections = {}
                    }
                    
                    local Element = Themes.Elements.Input
                    
                    Input.Settings.Name = Input.Settings.Name or "Input"
                    Input.Settings.Default = Input.Settings.Default or ""
                    Input.Settings.Placeholder = Input.Settings.Placeholder or ""
                    Input.Settings.ClearOnFocus = Input.Settings.ClearOnFocus or false
                    Input.Settings.Numeric = Input.Settings.Numeric or false
                    Input.Settings.Callback = Input.Settings.Callback or function() end
                    
                    pcall(Input.Settings.Callback, Input.Settings.Default)
                    
                    local Element_Input = CreateElement("Frame", {
                        Name = Input.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
            		    Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 7}, Element_Input)
                    UIPadding({0, 0}, {0, 8, 0, 8}, Element_Input)
                    
                    local Title = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 13),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = Input.Settings.Name,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_Input
                    })
                    
                    local Element_Track = CreateElement("Frame", {
                        Size = UDim2.new(0, 65, 0, 20),
                        AnchorPoint = Vector2.new(1, 0.5),
            		    Position = UDim2.new(1, 0, 0.5, 0),
                        BackgroundColor3 = Element.Track,
                        BackgroundTransparency = 0.07,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Element_Input
                    })
                    
                    UICorner({0, 7}, Element_Track)
                    UIStroke(1, 0.2, Themes.Border.Primary, Element_Track)
                    UIPadding({0, 0}, {0, 4, 0, 4}, Element_Track)
                    
                    local Icon = CreateElement("ImageLabel", {
                        Name = "Icon",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ImageColor3 = Element.Icon,
                        Image = "rbxassetid://" .. tostring(Icons:GetIcon("Keyboard")),
                        ImageTransparency = 0.4,
                        Size = UDim2.fromOffset(15, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 4, 0.5, 0),
                        Parent = Element_Track,
                    })
                    
                    local TextBox = CreateElement("TextBox", {
                        Size = UDim2.new(1, -24, 1, 0),
                        Position = UDim2.new(0, 22, 0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Text = tostring(Input.Settings.Default),
                        PlaceholderText = Input.Settings.Placeholder,
                        TextColor3 = Element.Text,
                        PlaceholderColor3 = Element.Placeholder,
                        TextTransparency = 0.4,
                        TextSize = 12,
                        Font = Themes.Font.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        ClipsDescendants = true,
                        ClearTextOnFocus = Input.Settings.ClearOnFocus,
                        Parent = Element_Track
                    })
                    
                    local OnClick = CreateElement("TextButton", {
                        Parent = Element_Input,
                        BackgroundTransparency = 1.000,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -64, 1, 0),
                        AutoButtonColor = false,
                        Text = "",
                        TextSize = 0.000,
                    })
                    
                    Lib:AutoUpdateText(Title)
                    
                    local function UpdateInputBoxSize()
                        task.wait()
                        local textToMeasure = TextBox.Text ~= "" and TextBox.Text or TextBox.PlaceholderText
                        local textSize = game:GetService("TextService"):GetTextSize(
                            textToMeasure,
                            TextBox.TextSize,
                            TextBox.Font,
                            Vector2.new(10000, math.huge)
                        )
                        
                        local parentWidth = Element_Input.AbsoluteSize.X
                        local titleSize = game:GetService("TextService"):GetTextSize(
                            Title.Text,
                            Title.TextSize,
                            Title.Font,
                            Vector2.new(10000, math.huge)
                        )
                        
                        local maxWidth = parentWidth - titleSize.X - 30
                        local newWidth = math.min(textSize.X + 45, math.max(maxWidth, 65))
                        Element_Track.Size = UDim2.new(0, newWidth, 0, 20)
                    end
                    
                    local function HandleInput(value)
                        if Input.Settings.Numeric then
                            local num = tonumber(value)
                            if num then
                                Input.Value = num
                                TextBox.Text = tostring(num)
                                pcall(Input.Settings.Callback, num)
                            else
                                Input.Value = value
                                pcall(Input.Settings.Callback, value)
                            end
                        else
                            Input.Value = value
                            pcall(Input.Settings.Callback, value)
                        end
                        UpdateInputBoxSize()
                    end
                    
                    -- Mudança: callback em tempo real (cada caractere digitado)
                    local textConnection = TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                        HandleInput(TextBox.Text)
                    end)
                    table.insert(Input._connections, textConnection)
                    
                    local focusConnection = TextBox.Focused:Connect(function()
                        Input.Active = true
                        TweenService:Create(Element_Track, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.12
                        }):Play()
                        TweenService:Create(Title, TweenInfo.new(0.15), {
                            TextTransparency = 0
                        }):Play()
                    end)
                    table.insert(Input._connections, focusConnection)
                    
                    local lostFocusConnection = TextBox.FocusLost:Connect(function(enterPressed)
                        Input.Active = false
                        TweenService:Create(Element_Track, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.07
                        }):Play()
                        
                        if not Input.Hover then
                            TweenService:Create(Title, TweenInfo.new(0.15), {
                                TextTransparency = 0.4
                            }):Play()
                        end
                        
                        if Input.Settings.Numeric then
                            local num = tonumber(TextBox.Text)
                            if num then
                                TextBox.Text = tostring(num)
                                Input.Value = num
                            else
                                TextBox.Text = tostring(Input.Value)
                            end
                        end
                    end)
                    table.insert(Input._connections, lostFocusConnection)
                    
                    local mouseEnterConnection = OnClick.MouseEnter:Connect(function()
                        Input.Hover = true
                        if not Input.Active then
                            TweenService:Create(Title, TweenInfo.new(0.15), {
                                TextTransparency = 0
                            }):Play()
                        end
                    end)
                    table.insert(Input._connections, mouseEnterConnection)
                    
                    local mouseLeaveConnection = OnClick.MouseLeave:Connect(function()
                        Input.Hover = false
                        if not Input.Active then
                            TweenService:Create(Title, TweenInfo.new(0.15), {
                                TextTransparency = 0.4
                            }):Play()
                        end
                    end)
                    table.insert(Input._connections, mouseLeaveConnection)
                    
                    function Input:GetValue()
                        return Input.Value
                    end
                    
                    function Input:SetValue(value)
                        if Input.Settings.Numeric then
                            value = tonumber(value) or 0
                        end
                        Input.Value = value
                        TextBox.Text = tostring(value)
                        pcall(Input.Settings.Callback, value)
                        UpdateInputBoxSize()
                    end
                    
                    function Input:GetText()
                        return tostring(TextBox.Text)
                    end
                    
                    function Input:SetText(text)
                        TextBox.Text = text
                    end
                    
                    function Input:Clear()
                        TextBox.Text = ""
                        Input.Value = Input.Settings.Numeric and 0 or ""
                    end
                    
                    function Input:Destroy()
                        for _, conn in ipairs(Input._connections) do
                            conn:Disconnect()
                        end
                        Element_Input:Destroy()
                    end
                    
                    UpdateInputBoxSize()
                    
                    if Flag then
                        Lib.Features[Flag] = Input
                    end
                    
                    return Input
                end
                
                function Section:KeyBind(Flag, Settings)
                    Settings = Settings or {}
                    Settings.Name = Settings.Name or "KeyBind"
                    Settings.Default = Settings.Default or "None"
                    Settings.Placeholder = Settings.Placeholder or "Bind"
                    Settings.Hold = Settings.Hold or false
                    Settings.Callback = Settings.Callback or function() end

                    pcall(Settings.Callback, Settings.Default)
                
                    local KeyBind = {
                        Settings = Settings,
                        Class = "KeyBind",
                        Value = Settings.Default,
                        IsListening = false,
                        IgnoreConfig = false,
                        Hover = false,
                        Active = false,
                        _connections = {}
                    }
                    
                    local Element = Themes.Elements.KeyBind
                    
                    KeyBind.Settings.Name = KeyBind.Settings.Name or "KeyBind"
                    KeyBind.Settings.Default = KeyBind.Settings.Default or "None"
                    KeyBind.Settings.Placeholder = KeyBind.Settings.Placeholder or "Bind"
                    KeyBind.Settings.Hold = KeyBind.Settings.Hold or false
                    KeyBind.Settings.Callback = KeyBind.Settings.Callback or function() end
                    
                    pcall(KeyBind.Settings.Callback, KeyBind.Settings.Default)
                    
                    local Element_KeyBind = CreateElement("Frame", {
                        Name = KeyBind.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
            		    Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 7}, Element_KeyBind)
                    --UIStroke(1, 0.2, Themes.Border.Primary, Element_KeyBind)
                    UIPadding({0, 0}, {0, 8, 0, 8}, Element_KeyBind)
                    
                    local Title = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 0, 0, 13),
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = KeyBind.Settings.Name,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_KeyBind
                    })
                    
                    local Element_Track = CreateElement("Frame", {
                        Size = UDim2.new(0, 65, 0, 20),
                        AnchorPoint = Vector2.new(1, 0.5),
            		    Position = UDim2.new(1, 0, 0.5, 0),
                        BackgroundColor3 = Element.Track,
                        BackgroundTransparency = 0.07,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = Element_KeyBind
                    })
                    
                    UICorner({0, 7}, Element_Track)
                    UIStroke(1, 0.2, Themes.Border.Primary, Element_Track)
                    UIPadding({0, 0}, {0, 4, 0, 4}, Element_Track)
                    
                    local Display = CreateElement("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        
                        Text = KeyBind.Settings.Default,
                        TextColor3 = Element.Text,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 12,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        
                        Parent = Element_Track
                    })
                    
                    local OnClick = CreateElement("TextButton", {
                        Parent = Element_Track,
                        BackgroundTransparency = 1.000,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        AutoButtonColor = false,
                        Text = "",
                        TextSize = 0.000,
                    })
                    
                    Lib:AutoUpdateText(Title)
                    
                    -- Sistema do KeyBind
                    local inputConnection
                    
                    local function UpdateDisplay(key)
                        local text = key ~= "None" and key or "None"
                        Display.Text = text
                        TweenService:Create(Display, TweenInfo.new(0.15), {
                            TextTransparency = 0.4
                        }):Play()
                    end
                    
                    local function StartListening()
                        KeyBind.IsListening = true
                        KeyBind.Active = true
                        Display.Text = "..."
                        TweenService:Create(Element_Track, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.12
                        }):Play()
                        TweenService:Create(Display, TweenInfo.new(0.15), {
                            TextTransparency = 0
                        }):Play()
                        TweenService:Create(Title, TweenInfo.new(0.15), {
                            TextTransparency = 0
                        }):Play()
                    end
                    
                    local function StopListening(key)
                        KeyBind.IsListening = false
                        KeyBind.Active = false
                        
                        if key then
                            KeyBind.Value = key
                            UpdateDisplay(key)
                            -- Callback com a tecla selecionada
                            pcall(KeyBind.Settings.Callback, key)
                        else
                            UpdateDisplay(KeyBind.Value)
                        end
                        
                        TweenService:Create(Element_Track, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.07
                        }):Play()
                        TweenService:Create(Display, TweenInfo.new(0.15), {
                            TextTransparency = 0.4
                        }):Play()
                        
                        if not KeyBind.Hover then
                            TweenService:Create(Title, TweenInfo.new(0.15), {
                                TextTransparency = 0.4
                            }):Play()
                        end
                    end
                    
                    local function SetupKeybindListener()
                        if inputConnection then
                            inputConnection:Disconnect()
                        end
                        
                        inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed then return end
                            
                            if not KeyBind.IsListening then
                                if input.KeyCode ~= Enum.KeyCode.None and KeyBind.Value ~= "None" then
                                    local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                                    if keyName == KeyBind.Value then
                                        if KeyBind.Settings.Hold then
                                            -- Hold: retorna true quando pressiona
                                            pcall(KeyBind.Settings.Callback, true)
                                        else
                                            -- Click: retorna o nome da tecla
                                            pcall(KeyBind.Settings.Callback, keyName)
                                        end
                                    end
                                end
                                return
                            end
                            
                            if input.KeyCode ~= Enum.KeyCode.None and 
                               input.KeyCode ~= Enum.KeyCode.Escape and
                               input.KeyCode ~= Enum.KeyCode.LeftShift and
                               input.KeyCode ~= Enum.KeyCode.RightShift and
                               input.KeyCode ~= Enum.KeyCode.LeftControl and
                               input.KeyCode ~= Enum.KeyCode.RightControl then
                                local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                                StopListening(keyName)
                            end
                        end)
                    end
                    
                    -- Eventos de clique
                    OnClick.MouseButton1Click:Connect(function()
                        if KeyBind.IsListening then
                            StopListening()
                        else
                            StartListening()
                        end
                    end)
                    
                    -- Hover personalizado
                    local mouseEnterConnection = Element_KeyBind.MouseEnter:Connect(function()
                        KeyBind.Hover = true
                        if not KeyBind.Active then
                            TweenService:Create(Title, TweenInfo.new(0.15), {
                                TextTransparency = 0
                            }):Play()
                        end
                    end)
                    table.insert(KeyBind._connections, mouseEnterConnection)
                    
                    local mouseLeaveConnection = Element_KeyBind.MouseLeave:Connect(function()
                        KeyBind.Hover = false
                        if not KeyBind.Active then
                            TweenService:Create(Title, TweenInfo.new(0.15), {
                                TextTransparency = 0.4
                            }):Play()
                        end
                    end)
                    table.insert(KeyBind._connections, mouseLeaveConnection)
                    
                    SetupKeybindListener()
                    
                    -- Funções públicas
                    function KeyBind:GetKey()
                        return KeyBind.Value
                    end
                    
                    function KeyBind:SetKey(key)
                        KeyBind.Value = key
                        UpdateDisplay(key)
                        pcall(KeyBind.Settings.Callback, key)
                    end
                    
                    function KeyBind:Reset()
                        KeyBind.Value = "None"
                        UpdateDisplay("None")
                    end
                    
                    function KeyBind:StartListening()
                        StartListening()
                    end
                    
                    function KeyBind:StopListening()
                        StopListening()
                    end
                    
                    function KeyBind:Destroy()
                        if inputConnection then
                            inputConnection:Disconnect()
                        end
                        for _, conn in ipairs(KeyBind._connections) do
                            conn:Disconnect()
                        end
                        Element_KeyBind:Destroy()
                    end
                    
                    if Flag then
                        Lib.Features[Flag] = KeyBind
                    end
                    
                    return KeyBind
                end
                
                function Section:Colorpicker(Flag, Settings)
                    Settings = Settings or {}
                    Settings.Name = Settings.Name or "Colorpicker"
                    Settings.Default = Settings.Default or Color3.fromRGB(255, 255, 255)
                    Settings.Cursor = Settings.Cursor or false
                    Settings.Callback = Settings.Callback or function() end

                    local Colorpicker = {
                        Settings = Settings,
                        Class = "Colorpicker",
                        IgnoreConfig = false,
                        Hover = false,
                        Active = false,
                        IsOpen = false,
                        _connections = {}
                    }
                    
                    local Element = Themes.Elements.Colorpicker
                    
                    Colorpicker.Settings.Name = Colorpicker.Settings.Name or "Colorpicker"
                    Colorpicker.Settings.Default = Colorpicker.Settings.Default or Color3.fromRGB(255, 255, 255)
                    Colorpicker.Settings.Cursor = Colorpicker.Settings.Cursor or false
                    Colorpicker.Settings.Callback = Colorpicker.Settings.Callback or function() end
                    
                    -- Elemento principal
                    local Colorpicker_F = CreateElement("Frame", {
                        Name = Colorpicker.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 0.07,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Section_Frame
                    })
                    
                    UICorner({0, 8}, Colorpicker_F)
                    UIStroke(1, 0.2, Themes.Border.Primary, Colorpicker_F)
                    
                    -- Title Frame
                    local Title_F = CreateElement("Frame", {
                        Name = "Title_".. Colorpicker.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 30),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Element.Primary,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = false,
                        Parent = Colorpicker_F,
                        ZIndex = 2,
                    })
                    
                    -- Linha divisória
                    local LINE = CreateElement("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        AnchorPoint = Vector2.new(1, 1),
                        Position = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Themes.Border.Primary,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = false,
                        ClipsDescendants = true,
                        Parent = Title_F
                    })
                    
                    -- Title Label (sem Frame intermediário)
                    local Title_Colorpicker = CreateElement("TextLabel", {
                        Name = "Title_Colorpicker",
                        Size = UDim2.new(0, 0, 0, 13),
                        AutomaticSize = Enum.AutomaticSize.X,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 8, 0.5, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Text = Colorpicker.Settings.Name,
                        TextColor3 = Themes.Text.Primary,
                        TextTransparency = 0.4,
                        TextScaled = false,
                        TextSize = 13,
                        Font = Themes.Font.Text,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        Parent = Title_F,
                        ZIndex = 3,
                    })
                    
                    -- Preview da cor
                    local View_F = CreateElement("Frame", {
                        Size = UDim2.new(0, 20, 0, 20),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -8, 0.5, 0),
                        BackgroundColor3 = Colorpicker.Settings.Default,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Title_F,
                        ZIndex = 3,
                    })
                    
                    UICorner({0, 5}, View_F)
                    UIStroke(1, 0.2, Themes.Border.Primary, View_F)
                    
                    local OnClick = CreateElement("TextButton", {
                        Name = "OnClick",
                        Parent = Title_F,
                        BackgroundTransparency = 1.000,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        AutoButtonColor = false,
                        Text = "",
                        TextSize = 0.000,
                        ZIndex = 4,
                    })
                    
                    Lib:HoverElements(Colorpicker.Active, Colorpicker.Hover, OnClick, Title_Colorpicker)
                    
                    -- CONTENT DO COLORPICKER
                    local Content_Colorpicker_F = CreateElement("Frame", {
                        Name = "Content_".. Colorpicker.Settings.Name,
                        Size = UDim2.new(1, 0, 0, 0),
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 0, 1, 0),
                        BackgroundColor3 = Themes.Background.Card,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Colorpicker_F,
                        ZIndex = 1,
                    })
                    
                    UICorner({0, 8}, Content_Colorpicker_F)
                --  UIStroke(1, 0.2, Themes.Border.Primary, Content_Colorpicker_F)
                    
                    CreateElement("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        Parent = Content_Colorpicker_F
                    })
                    
                    -- SELETOR DE COR
                    local Colorpicker_Selector = CreateElement("Frame", {
                        Size = UDim2.new(1, -23, 0, 100),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Content_Colorpicker_F,
                        ZIndex = 1,
                    })
                    
                    UICorner({0, 8}, Colorpicker_Selector)
                    UIStroke(1, 0.2, Themes.Border.Primary, Colorpicker_Selector)
                    
                    local UIGradient = Instance.new("UIGradient")
                    UIGradient.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), 
                        ColorSequenceKeypoint.new(1.00, Colorpicker.Settings.Default)
                    }
                    UIGradient.Rotation = 0
                    UIGradient.Parent = Colorpicker_Selector
                    
                    local BlackOverlay = CreateElement("ImageLabel", {
                        Name = "BlackOverlay",
                        Parent = Colorpicker_Selector,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1.000,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 1,
                        Image = "rbxassetid://5107152095",
                    })
                    
                    UICorner({0, 7}, BlackOverlay)
                    
                    local Cursor = CreateElement("ImageLabel", {
                        Name = "Cursor",
                        Parent = Colorpicker_Selector,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1.000,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        ImageTransparency = Colorpicker.Settings.Cursor and 1 or 0,
                        Size = UDim2.new(0, 14, 0, 14),
                        ZIndex = 2,
                        Image = "rbxassetid://6023427086",
                    })
                    
                    -- BARRA RAINBOW VERTICAL
                    local Colorpicker_RainbowBar = CreateElement("Frame", {
                        Size = UDim2.new(0, 15, 0, 100),
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Visible = true,
                        ClipsDescendants = true,
                        Parent = Content_Colorpicker_F,
                        ZIndex = 1,
                    })
                    
                    UICorner({0, 3}, Colorpicker_RainbowBar)
                    UIStroke(1, 0.2, Themes.Border.Primary, Colorpicker_RainbowBar)
                    
                    local Rainbow_Cursor = CreateElement("ImageLabel", {
                        Name = "Rainbow_Cursor",
                        Parent = Colorpicker_RainbowBar,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1.000,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 14, 0, 14),
                        ImageTransparency = Colorpicker.Settings.Cursor and 1 or 0,
                        ZIndex = 2,
                        Image = "rbxassetid://6023427086",
                    })
                    
                    local UIGradient_Rainbow = Instance.new("UIGradient")
                    UIGradient_Rainbow.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 4)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                    }
                    UIGradient_Rainbow.Rotation = 90
                    UIGradient_Rainbow.Parent = Colorpicker_RainbowBar
                    
                    -- Variáveis para animação
                    local CurrentTween
                    
                    -- SISTEMA DE FUNCIONAMENTO
                    local draggingColor = false
                    local draggingCConteiner = false
                    local hue, sat, brightness = 0, 1, 1
                    local currentColor = Colorpicker.Settings.Default
                    
                    local selectorInputConnection, selectorMoveConnection, selectorEndConnection
                    local rainbowInputConnection, rainbowMoveConnection, rainbowEndConnection
                    
                    local function sendColorCallback(color)
                        currentColor = color
                        local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                        task.spawn(function()
                            pcall(Colorpicker.Settings.Callback, Color3.fromRGB(r, g, b))
                        end)
                    end
                    
                    local function updateCConteinerColor(input)
                        local mousePos = input.Position
                        if not Colorpicker_Selector then return end
                        
                        local selectorPosition = Colorpicker_Selector.AbsolutePosition
                        local selectorSize = Colorpicker_Selector.AbsoluteSize
                    
                        if mousePos.X >= selectorPosition.X and mousePos.Y >= selectorPosition.Y and
                            mousePos.X <= selectorPosition.X + selectorSize.X and mousePos.Y <= selectorPosition.Y + selectorSize.Y then
                            
                            sat = math.clamp((mousePos.X - selectorPosition.X) / selectorSize.X, 0, 1)
                            brightness = 1 - math.clamp((mousePos.Y - selectorPosition.Y) / selectorSize.Y, 0, 1)
                    
                            currentColor = Color3.fromHSV(hue, sat, brightness)
                            View_F.BackgroundColor3 = currentColor
                            sendColorCallback(currentColor)
                            
                            Cursor.Position = UDim2.new(sat, 0, 1 - brightness, 0)
                        end
                    end
                    
                    local function updateColorSlider(input)
                        local mousePos = input.Position
                        if not Colorpicker_RainbowBar then return end
                        
                        local colorPosition = Colorpicker_RainbowBar.AbsolutePosition
                        local colorSize = Colorpicker_RainbowBar.AbsoluteSize
                    
                        hue = math.clamp((mousePos.Y - colorPosition.Y) / colorSize.Y, 0, 1)
                    
                        UIGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromHSV(hue, 1, 1))
                        }
                    
                        Rainbow_Cursor.Position = UDim2.new(0.5, 0, hue, 0)
                    
                        currentColor = Color3.fromHSV(hue, sat, brightness)
                        View_F.BackgroundColor3 = currentColor
                        sendColorCallback(currentColor)
                    end
                    
                    local function setInitialColor(color)
                        hue, sat, brightness = color:ToHSV()
                        
                        UIGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
                        }
                        
                        Cursor.Position = UDim2.new(sat, 0, 1 - brightness, 0)
                        Rainbow_Cursor.Position = UDim2.new(0.5, 0, hue, 0)
                        
                        View_F.BackgroundColor3 = color
                        currentColor = color
                        sendColorCallback(color)
                    end
                    
                    local function connectSelectorInput()
                        if selectorInputConnection then selectorInputConnection:Disconnect() end
                        if selectorMoveConnection then selectorMoveConnection:Disconnect() end
                        if selectorEndConnection then selectorEndConnection:Disconnect() end
                        
                        selectorInputConnection = Colorpicker_Selector.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                draggingCConteiner = true
                                updateCConteinerColor(input)
                            end
                        end)
                        table.insert(Colorpicker._connections, selectorInputConnection)
                        
                        selectorMoveConnection = UserInputService.InputChanged:Connect(function(input)
                            if draggingCConteiner and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                                updateCConteinerColor(input)
                            end
                        end)
                        table.insert(Colorpicker._connections, selectorMoveConnection)
                        
                        selectorEndConnection = UserInputService.InputEnded:Connect(function(input)
                            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                                draggingCConteiner = false
                            end
                        end)
                        table.insert(Colorpicker._connections, selectorEndConnection)
                    end
                    
                    local function connectRainbowInput()
                        if rainbowInputConnection then rainbowInputConnection:Disconnect() end
                        if rainbowMoveConnection then rainbowMoveConnection:Disconnect() end
                        if rainbowEndConnection then rainbowEndConnection:Disconnect() end
                        
                        rainbowInputConnection = Colorpicker_RainbowBar.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                draggingColor = true
                                updateColorSlider(input)
                            end
                        end)
                        table.insert(Colorpicker._connections, rainbowInputConnection)
                        
                        rainbowMoveConnection = UserInputService.InputChanged:Connect(function(input)
                            if draggingColor and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                                updateColorSlider(input)
                            end
                        end)
                        table.insert(Colorpicker._connections, rainbowMoveConnection)
                        
                        rainbowEndConnection = UserInputService.InputEnded:Connect(function(input)
                            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                                draggingColor = false
                            end
                        end)
                        table.insert(Colorpicker._connections, rainbowEndConnection)
                    end
                    
                    -- Função para animar a abertura/fechamento
                    local function AnimateColorpicker(open)
                        if CurrentTween then
                            CurrentTween:Cancel()
                        end
                        
                        local targetHeight = open and 117 or 0
                        
                        -- Animar a altura do colorpicker
                        CurrentTween = TweenService:Create(Colorpicker_F, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, open and (30 + 117) or 30)
                        })
                        CurrentTween:Play()
                        
                        -- Animar a altura do conteúdo
                        TweenService:Create(Content_Colorpicker_F, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, targetHeight)
                        }):Play()
                        
                        -- Animar a linha divisora
                        LINE.Visible = true
                        TweenService:Create(LINE, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = open and 0 or 1
                        }):Play()
                    end
                    
                    -- Função para alternar
                    local function ToggleColorpicker()
                        Colorpicker.IsOpen = not Colorpicker.IsOpen
                        Colorpicker.Active = Colorpicker.IsOpen
                        
                        if Colorpicker.IsOpen then
                            connectSelectorInput()
                            connectRainbowInput()
                        end
                        
                        AnimateColorpicker(Colorpicker.IsOpen)
                    end
                    
                    OnClick.MouseButton1Click:Connect(function()
                        ToggleColorpicker()
                    end)
                    
                    -- Inicializar com cor padrão
                    setInitialColor(currentColor)
                    
                    -- Fechar ao clicar fora
                    local closeConnection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and Colorpicker.IsOpen then
                            local mousePos = input.Position
                            local colorpickerPos = Colorpicker_F.AbsolutePosition
                            local colorpickerSize = Colorpicker_F.AbsoluteSize
                            
                            local totalHeight = 30 + (Colorpicker.IsOpen and 117 or 0)
                            
                            local clickedInside = 
                                (mousePos.X >= colorpickerPos.X and mousePos.X <= colorpickerPos.X + colorpickerSize.X and
                                 mousePos.Y >= colorpickerPos.Y and mousePos.Y <= colorpickerPos.Y + totalHeight)
                            
                            if not clickedInside then
                                Colorpicker.IsOpen = false
                                Colorpicker.Active = false
                                AnimateColorpicker(false)
                            end
                        end
                    end)
                    table.insert(Colorpicker._connections, closeConnection)
                    
                    Lib:AutoUpdateText(Title_Colorpicker)
                    
                    -- MÉTODOS PÚBLICOS
                    function Colorpicker:SetColor(color)
                        if typeof(color) == "Color3" then
                            setInitialColor(color)
                            task.spawn(function()
                                pcall(Colorpicker.Settings.Callback, color)
                            end)
                        end
                        return self
                    end
                    
                    function Colorpicker:GetColor()
                        return currentColor
                    end
                    
                    function Colorpicker:GetHSV()
                        return hue, sat, brightness
                    end
                    
                    function Colorpicker:SetHSV(h, s, b)
                        hue = h or hue
                        sat = s or sat
                        brightness = b or brightness
                        local color = Color3.fromHSV(hue, sat, brightness)
                        setInitialColor(color)
                        return self
                    end
                    
                    function Colorpicker:SetVisibility(state)
                        Colorpicker_F.Visible = state or false
                        return self
                    end
                    
                    function Colorpicker:Destroy()
                        for _, conn in ipairs(Colorpicker._connections) do
                            conn:Disconnect()
                        end
                        Colorpicker_F:Destroy()
                    end
                    
                    if Flag then
                        Lib.Features[Flag] = Colorpicker
                    end
                    
                    return Colorpicker
                end
                
                return Section
            end
            
            return SubTab
        end 
        
        return Tab
    end
    
    function StorageTabs:Dialog(Settings)
        Settings.Title = Settings.Title or "Diálogo"
        Settings.Description = Settings.Description or "Descrição do diálogo"
        Settings.Buttons = Settings.Buttons or {{Name = "OK", Callback = function() end}}
        
        local Element = Themes.Elements.Dialog
        local DialogFunctions = {}
        
        local base = Window
        
        local dialogCanvas = CreateElement("CanvasGroup", {
            Name = "DialogCanvas_" .. HttpService:GenerateGUID(false):sub(1, 8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            GroupTransparency = 1,
            ZIndex = 99999999,
            Parent = base
        })
        
        local dialog = CreateElement("Frame", {
            Name = "Dialog",
            BackgroundColor3 = Element.Primary,
            BackgroundTransparency = 0.35,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Active = true,
            ZIndex = 99999999,
            Parent = dialogCanvas
        })
        
        UICorner({0, 10}, dialog)
        
        local prompt = CreateElement("Frame", {
            Name = "Prompt",
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Element.Secondary,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(280, 0),
            ZIndex = 99999999,
            Parent = dialog
        })
        
        local promptUIScale = CreateElement("UIScale", {
            Name = "BaseUIScale",
            Scale = 0.95,
            Parent = prompt
        })
        
        UIStroke(1, 0.9, Themes.Border.Primary, prompt)
        UICorner({0, 10}, prompt)
        
        UIPadding({0, 20}, {0, 20, 0, 20}, prompt)
        
        local paragraph = CreateElement("Frame", {
            Name = "Paragraph",
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 38),
            Parent = prompt
        })
        
        local paragraphHeader = CreateElement("TextLabel", {
            Name = "ParagraphHeader",
            RichText = true,
            Text = Settings.Title,
            TextColor3 = Element.Title,
            TextSize = 18,
            TextTransparency = 0.4,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0),
            Font = Themes.Font.Title,
            Parent = paragraph
        })
        
        CreateElement("UIListLayout", {
            Padding = UDim.new(0, 15),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = paragraph
        })
        
        local paragraphBody = CreateElement("TextLabel", {
            Name = "ParagraphBody",
            RichText = true,
            Text = Settings.Description,
            TextColor3 = Element.Text,
            TextSize = 14,
            TextTransparency = 0.5,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Size = UDim2.fromScale(1, 0),
            Font = Themes.Font.Text,
            Parent = paragraph
        })
        
        local interactions = CreateElement("Frame", {
            Name = "Interactions",
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = prompt
        })
        
        CreateElement("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = interactions
        })
        
        UIPadding({0, 20}, {0, 0, 0, 0}, interactions)
        
        CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = prompt
        })
        
        local canvasIn = TweenService:Create(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 0 })
        local canvasOut = TweenService:Create(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 1 })
        
        local scaleIn = TweenService:Create(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 1 })
        local scaleOut = TweenService:Create(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 0.95 })
        
        local dialogConnections = {}
        
        function dialogIn()
            canvasIn:Play()
            scaleIn:Play()
            canvasIn.Completed:Wait()
        end
        
        function dialogOut()
            if not dialogCanvas.Parent then return end
            
            for _, connection in pairs(dialogConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            
            canvasOut:Play()
            scaleOut:Play()
            canvasOut.Completed:Wait()
            dialogCanvas:Destroy()
        end
        
        local closeOnClickOutsideConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dialogCanvas.GroupTransparency == 0 then
                local mousePos = input.Position
                local promptPos = prompt.AbsolutePosition
                local promptSize = prompt.AbsoluteSize
                
                local clickedInsidePrompt = 
                    mousePos.X >= promptPos.X and mousePos.X <= promptPos.X + promptSize.X and
                    mousePos.Y >= promptPos.Y and mousePos.Y <= promptPos.Y + promptSize.Y
                    
                if not clickedInsidePrompt then
                    dialogOut()
                end
            end
        end)
        
        table.insert(dialogConnections, closeOnClickOutsideConnection)
        
        for i, v in ipairs(Settings.Buttons) do
            local buttonIndex = i
            local buttonData = v
            
            local button = CreateElement("TextButton", {
                Name = "Button_" .. buttonIndex,
                Text = buttonData.Name,
                TextColor3 = Element.Title,
                TextSize = 15,
                TextTransparency = 0.5,
                TextTruncate = Enum.TextTruncate.AtEnd,
                AutoButtonColor = false,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Element.Buttons,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 0),
                Font = Themes.Font.Text,
                Parent = interactions
            })
            
            UIPadding({0, 9}, {0, 10, 0, 10}, button)
            UICorner({0, 10}, button)
            
            local TweenSettings = {
                DefaultTransparency = 0,
                DefaultTransparency2 = 0.5,
                HoverTransparency = 0.3,
                HoverTransparency2 = 0.6,
                EasingStyle = Enum.EasingStyle.Sine
            }
            
            function ChangeState(State)
                if State == "Idle" then
                    TweenService:Create(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
                        BackgroundTransparency = TweenSettings.DefaultTransparency,
                        TextTransparency = TweenSettings.DefaultTransparency2
                    }):Play()
                elseif State == "Hover" then
                    TweenService:Create(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
                        BackgroundTransparency = TweenSettings.HoverTransparency,
                        TextTransparency = TweenSettings.HoverTransparency2
                    }):Play()
                end
            end
            
            local clickConnection = button.MouseButton1Click:Connect(function()
                if dialogCanvas.GroupTransparency ~= 0 then return end
                
                if buttonData.Callback then
                    buttonData.Callback()
                end
                
                dialogOut()
            end)
            
            local enterConnection = button.MouseEnter:Connect(function()
                ChangeState("Hover")
            end)
            
            local leaveConnection = button.MouseLeave:Connect(function()
                ChangeState("Idle")
            end)
            
            table.insert(dialogConnections, clickConnection)
            table.insert(dialogConnections, enterConnection)
            table.insert(dialogConnections, leaveConnection)
        end
        
        dialogIn()
        
        function DialogFunctions:UpdateTitle(New)
            paragraphHeader.Text = New
        end
        
        function DialogFunctions:UpdateDescription(New)
            paragraphBody.Text = New
        end
        
        function DialogFunctions:Cancel()
            dialogOut()
        end
        
        function DialogFunctions:Close()
            dialogOut()
        end
        
        return DialogFunctions
    end
    
    function StorageTabs:Notification(Settings)
        Settings.Title = Settings.Title or "Notificação"
        Settings.Message = Settings.Message or "Mensagem da notificação"
        Settings.Duration = Settings.Duration or 3
        Settings.ShowProgress = Settings.ShowProgress or false
        Settings.Position = Settings.Position or "Screen" -- "Screen" ou "Menu"
        
        local Notification = {}
        local Element = Themes.Elements.Notification
        
        local notificationId = HttpService:GenerateGUID(false):sub(1, 8)
        local isClosing = false
        local progressTween
        local closeTimer
        
        -- Sistema de notificações
        if not StorageTabs.NotificationSystem then
            StorageTabs.NotificationSystem = {
                Notifications = {},
                NextPosition = 15
            }
        end
        
        if StorageTabs.NotificationSystem.IsReorganizing then
            task.wait(0.1)
        end
        
        -- Determinar o pai da notificação
        local parentLayer
        local isScreen = Settings.Position == "Screen"
        
        if isScreen then
            -- Notificação na tela (ScreenGui)
            if not ScreenGui:FindFirstChild("NotificationLayer") then
                local notificationLayer = CreateElement("Frame", {
                    Name = "NotificationLayer",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 300, 1, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    ZIndex = math.huge,
                    Parent = ScreenGui
                })
            end
            parentLayer = ScreenGui:FindFirstChild("NotificationLayer")
        else
            -- Notificação no menu (dentro da Window)
            if not ConteinerFuns:FindFirstChild("NotificationLayer") then
                local notificationLayer = CreateElement("Frame", {
                    Name = "NotificationLayer",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 260, 1, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    ZIndex = math.huge,
                    Parent = ConteinerFuns
                })
            end
            parentLayer = ConteinerFuns:FindFirstChild("NotificationLayer")
        end
        
        -- Calcular posição
        local currentY = 15
        for _, notifData in pairs(StorageTabs.NotificationSystem.Notifications) do
            if notifData and notifData.Frame and notifData.Frame.Parent and not notifData.IsClosing then
                currentY = currentY + notifData.Frame.AbsoluteSize.Y + 8
            end
        end
        
        local startY = currentY
        local offsetX = isScreen and 300 or 260
        
        local notificationFrame = CreateElement("Frame", {
            Name = "Notification_" .. notificationId,
            BackgroundColor3 = Element.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(1, offsetX + 20, 0, startY),
            AnchorPoint = Vector2.new(1, 0),
            ZIndex = math.huge,
            Parent = parentLayer
        })
        
        UICorner({0, 8}, notificationFrame)
        UIStroke(1, 0.15, Themes.Border.Primary, notificationFrame)
        
        local Container = CreateElement("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = notificationFrame
        })
    
        UIPadding({0, 6}, {0, 10, 0, 10}, Container)
    
        local HeaderFrame = CreateElement("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 18),
            Parent = Container
        })
        
        local titleLabel = CreateElement("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 18),
            Text = Settings.Title,
            TextColor3 = Element.Title,
            TextSize = 12,
            TextTransparency = 0.2,
            Font = Themes.Font.Title,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = HeaderFrame
        })
        
        local closeButton = CreateElement("TextButton", {
            Name = "CloseButton",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(1, -14, 0, 2),
            Text = "",
            AutoButtonColor = false,
            Parent = HeaderFrame
        })
        
        local closeCircle = CreateElement("Frame", {
            Name = "CloseCircle",
            BackgroundColor3 = Themes.Border.Primary,
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = closeButton
        })
        
        UICorner({1, 0}, closeCircle)
        
        local Icon = CreateElement("ImageLabel", {
            BackgroundTransparency = 1,
            ImageColor3 = Themes.Image.Primary,
            Image = "rbxassetid://4536216511",
            ImageTransparency = 0.3,
            Size = UDim2.fromScale(1, 1),
            Parent = closeCircle,
        })
        
        local messageFrame = CreateElement("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 22),
            Parent = Container
        })
        
        local messageLabel = CreateElement("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            Text = Settings.Message,
            TextColor3 = Element.Text,
            TextSize = 11,
            TextTransparency = 0.4,
            Font = Themes.Font.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = messageFrame
        })
        
        local progressBar
        if Settings.ShowProgress then
            local progressContainer = CreateElement("Frame", {
                Name = "ProgressContainer",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, 0),
                AnchorPoint = Vector2.new(0, 1),
                Parent = Container
            })
            
            local progressBackground = CreateElement("Frame", {
                Name = "ProgressBackground",
                BackgroundColor3 = Themes.Border.Primary,
                BackgroundTransparency = 0.95,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = progressContainer
            })
            
            UICorner({1, 0}, progressBackground)
            
            progressBar = CreateElement("Frame", {
                Name = "ProgressBar",
                BackgroundColor3 = Themes.Highlight.Blue,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = progressBackground
            })
            
            UICorner({1, 0}, progressBar)
        end
        
        function calculateHeights()
            local textService = game:GetService("TextService")
            local maxWidth = isScreen and 270 or 230
            local maxLines = 4
            local lineHeight = 14
            
            local textSize = textService:GetTextSize(
                Settings.Message,
                11,
                Themes.Font.Text,
                Vector2.new(maxWidth, 10000)
            )
            
            local lineCount = math.ceil(textSize.Y / lineHeight)
            local actualLines = math.min(lineCount, maxLines)
            local messageHeight = actualLines * lineHeight
            
            local paddingTopBottom = 12
            local headerHeight = 18
            local progressHeight = Settings.ShowProgress and 2 or 0
            
            local totalHeight = paddingTopBottom + headerHeight + messageHeight + progressHeight + 4
            
            messageLabel.Size = UDim2.new(1, 0, 0, messageHeight)
            messageFrame.Size = UDim2.new(1, 0, 0, messageHeight)
            Container.Size = UDim2.new(1, 0, 0, totalHeight)
            notificationFrame.Size = UDim2.new(1, 0, 0, totalHeight)
            
            return totalHeight
        end
        
        local totalHeight = calculateHeights()
        
        notificationFrame.Position = UDim2.new(1, offsetX + 20, 0, startY)
        
        closeButton.MouseEnter:Connect(function()
            TweenService:Create(closeCircle, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.5
            }):Play()
        end)
        
        closeButton.MouseLeave:Connect(function()
            TweenService:Create(closeCircle, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.8
            }):Play()
        end)
        
        function animateIn()
            if isClosing then return end
            
            local slideIn = TweenService:Create(notificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
                Position = UDim2.new(1, -15, 0, startY)
            })
            
            slideIn:Play()
            
            local newY = startY + totalHeight + 8
            for id, notifData in pairs(StorageTabs.NotificationSystem.Notifications) do
                if notifData and notifData.Frame and notifData.Frame.Parent and id ~= notificationId and not notifData.IsClosing then
                    if notifData.StartY >= startY then
                        local targetY = notifData.StartY + totalHeight + 8
                        TweenService:Create(notifData.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
                            Position = UDim2.new(1, -15, 0, targetY)
                        }):Play()
                        notifData.StartY = targetY
                        newY = targetY + notifData.Frame.AbsoluteSize.Y + 8
                    end
                end
            end
            
            StorageTabs.NotificationSystem.NextPosition = newY
            
            if Settings.ShowProgress and progressBar then
                task.delay(0.4, function()
                    if not isClosing then
                        progressTween = TweenService:Create(progressBar, TweenInfo.new(Settings.Duration, Enum.EasingStyle.Linear), {
                            Size = UDim2.new(0, 0, 1, 0)
                        })
                        progressTween:Play()
                    end
                end)
            end
        end
        
        function reorganizeNotifications()
            if StorageTabs.NotificationSystem.IsReorganizing then return end
            StorageTabs.NotificationSystem.IsReorganizing = true
            
            local newY = 15
            local notificationsToUpdate = {}
            
            for id, notifData in pairs(StorageTabs.NotificationSystem.Notifications) do
                if notifData and notifData.Frame and notifData.Frame.Parent and not notifData.IsClosing then
                    table.insert(notificationsToUpdate, {
                        Id = id,
                        Data = notifData,
                        TargetY = newY
                    })
                    newY = newY + notifData.Frame.AbsoluteSize.Y + 8
                end
            end
            
            StorageTabs.NotificationSystem.NextPosition = newY
            
            for _, notifInfo in ipairs(notificationsToUpdate) do
                if notifInfo.Data.StartY ~= notifInfo.TargetY then
                    TweenService:Create(notifInfo.Data.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -15, 0, notifInfo.TargetY)
                    }):Play()
                    notifInfo.Data.StartY = notifInfo.TargetY
                end
            end
            
            task.wait(0.35)
            StorageTabs.NotificationSystem.IsReorganizing = false
        end
        
        function animateOut()
            if isClosing then return end
            isClosing = true
            
            StorageTabs.NotificationSystem.Notifications[notificationId].IsClosing = true
            
            if progressTween then 
                progressTween:Cancel() 
            end
            
            if closeTimer then 
                closeTimer:Disconnect()
            end
            
            local slideOut = TweenService:Create(notificationFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, offsetX + 20, 0, startY)
            })
            
            local fadeOut = TweenService:Create(notificationFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0.8
            })
            
            slideOut:Play()
            fadeOut:Play()
            
            slideOut.Completed:Connect(function()
                if notificationFrame and notificationFrame.Parent then
                    notificationFrame:Destroy()
                    
                    StorageTabs.NotificationSystem.Notifications[notificationId] = nil
                    
                    task.delay(0.1, reorganizeNotifications)
                end
            end)
        end
        
        if Settings.Duration > 0 then
            closeTimer = game:GetService("RunService").Heartbeat:Connect(function() end)
            
            if Settings.ShowProgress then
                task.delay(Settings.Duration + 0.4, animateOut)
            else
                task.delay(Settings.Duration, animateOut)
            end
        end
        
        closeButton.MouseButton1Click:Connect(animateOut)
        
        StorageTabs.NotificationSystem.Notifications[notificationId] = {
            Frame = notificationFrame,
            StartY = startY,
            TotalHeight = totalHeight,
            IsClosing = false,
            Position = Settings.Position,
            Close = animateOut
        }
        
        task.delay(0.05, animateIn)
        
        function Notification:UpdateTitle(newTitle)
            titleLabel.Text = newTitle
        end
        
        function Notification:UpdateMessage(newMessage)
            Settings.Message = newMessage
            messageLabel.Text = newMessage
            calculateHeights()
        end
        
        function Notification:Close()
            animateOut()
        end
        
        function Notification:GetId()
            return notificationId
        end
        
        return Notification
    end

    function StorageTabs:SaveLoad(Settings)
    return SaveLoadSystem:SetupWithLib(StorageTabs)
end
    
	return StorageTabs
end

function Lib:Demo()
    local Window = Lib:Window({
        Title = "AiCode Demo",
        Theme = "Darker",
        ShowUserInfo = false,
        AcrylicBlur = false,
        Button = {Enabled = true},
        Size = {550, 350},
        KeyBind = Enum.KeyCode.K
    })
    

    local HomeTab = Window:Tab({
        Icon = "Home",
    })
    
    -- Subtabs
    local BasicsSubTab = HomeTab:SubTab({ Name = "Basics" })
    local AdvancedSubTab = HomeTab:SubTab({ Name = "Advanced" })
    local TextSubTab = HomeTab:SubTab({ Name = "Text" })
    local InputSubTab = HomeTab:SubTab({ Name = "Inputs" })
    
    local SaveManager = Window:SaveLoad({})
    
    -- ============================================
    -- BASICS TAB
    -- ============================================
    local BasicsSection1 = BasicsSubTab:Section({
        Header = "Buttons & Toggles",
        Side = "Left"
    })
    
    -- Button
    BasicsSection1:Button("DemoButton", {
        Name = "Click Me!",
        Callback = function()
            print("Button clicked!")
            Window:Notification({
                Title = "Success",
                Message = "Operation completed successfully!",
                Duration = 3,
                Position = "Screen",
                ShowProgress = false
            })
        end
    })
    
    -- Toggle Style 1 - Modern
    local ToggleModern = BasicsSection1:Toggle("ToggleModern", {
        Name = "Modern Toggle",
        Default = false,
        Style = 1,
        Callback = function(value)
            print("Modern Toggle:", value)
        end
    })
    SaveLoadSystem:RegisterToggle("ToggleModern", ToggleModern)
    
    -- Toggle Style 2 - Ball
    local ToggleBall = BasicsSection1:Toggle("ToggleBall", {
        Name = "Ball Toggle",
        Default = false,
        Style = 2,
        Callback = function(value)
            print("Ball Toggle:", value)
        end
    })
    
    -- Checkbox
    local CheckboxDemo = BasicsSection1:Checkbox("CheckboxDemo", {
        Name = "Checkbox",
        Default = true,
        Callback = function(value)
            print("Checkbox:", value)
        end
    })
    
    local BasicsSection2 = BasicsSubTab:Section({
        Header = "Sliders & Dropdowns",
        Side = "Right"
    })
    
    -- Colorpicker
    local ColorpickerDemo = BasicsSection2:Colorpicker("ColorpickerDemo", {
        Name = "Color Picker",
        Default = Color3.fromRGB(255, 100, 50),
        Cursor = true,
        Callback = function(color)
            print("Color:", color)
        end
    })
    
    -- Slider
    local SliderDemo = BasicsSection2:Slider("SliderDemo", {
        Name = "Volume",
        Default = 50,
        Minimum = 0,
        Maximum = 100,
        Precision = 0,
        DisplayMethod = "Percent",
        Callback = function(value)
            print("Slider:", value)
        end
    })
    
    -- Dropdown Single
    local DropdownDemo = BasicsSection2:Dropdown("DropdownDemo", {
        Name = "Select Option",
        Values = {"Option 1", "Option 2", "Option 3"},
        Default = "Option 1",
        MultiSelection = false,
        Callback = function(value)
            print("Dropdown:", value)
        end
    })
    
    local AdvancedSection1 = AdvancedSubTab:Section({
        Header = "Multi Selection & Precision",
        Side = "Left"
    })
    
    -- Multi Dropdown
    local MultiDropdownDemo = AdvancedSection1:Dropdown("MultiDropdownDemo", {
        Name = "Multi Select",
        Values = {"Apple", "Banana", "Orange", "Grape", "Watermelon"},
        Default = {"Apple", "Orange"},
        MultiSelection = true,
        Callback = function(value)
            print("Multi Dropdown:", value)
        end
    })
    
    -- Precision Slider
    local PrecisionSlider = AdvancedSection1:Slider("PrecisionSlider", {
        Name = "Precision Slider",
        Default = 0.5,
        Minimum = 0,
        Maximum = 1,
        Precision = 3,
        DisplayMethod = "Value",
        Callback = function(value)
            print("Precision Slider:", value)
        end
    })
    
    local AdvancedSection2 = AdvancedSubTab:Section({
        Header = "Special Sliders",
        Side = "Right"
    })
    
    -- Degrees Slider
    local DegreesSlider = AdvancedSection2:Slider("DegreesSlider", {
        Name = "Degrees",
        Default = 45,
        Minimum = 0,
        Maximum = 360,
        Precision = 0,
        DisplayMethod = "Degrees",
        Callback = function(value)
            print("Degrees:", value)
        end
    })
    
    -- Hundredths Slider
    local HundredthsSlider = AdvancedSection2:Slider("HundredthsSlider", {
        Name = "Hundredths",
        Default = 50.50,
        Minimum = 0,
        Maximum = 100,
        Precision = 2,
        DisplayMethod = "Hundredths",
        Callback = function(value)
            print("Hundredths:", value)
        end
    })
    
    local TextSection1 = TextSubTab:Section({
        Header = "Labels",
        Side = "Left"
    })
    
    -- Simple Label
    TextSection1:Label("LabelSimple", {
        Text = "Simple Label"
    })
    
    -- Bold Label
    TextSection1:Label("LabelBold", {
        Text = "Bold Label",
        Bold = true
    })
    
    -- Underline Label
    TextSection1:Label("LabelUnderline", {
        Text = "Underline Label",
        Subline = true
    })
    
    -- Bold + Underline
    TextSection1:Label("LabelBoth", {
        Text = "Bold + Underline",
        Bold = true,
        Subline = true
    })
    
    local TextSection2 = TextSubTab:Section({
        Header = "Paragraphs",
        Side = "Right"
    })
    
    -- Simple Paragraph
    TextSection2:Paragraph("ParagraphSimple", {
        Title = "Information",
        Text = "This is a simple paragraph that can be used to display information to the user."
    })
    
    -- Bold Title Paragraph
    TextSection2:Paragraph("ParagraphBoldTitle", {
        Title = "Bold Title",
        Text = "Normal text here...",
        Bold = {Type = "Title", Enabled = true}
    })
    
    -- Bold Text Paragraph
    TextSection2:Paragraph("ParagraphBoldText", {
        Title = "Normal Title",
        Text = "Bold text here...",
        Bold = {Type = "Text", Enabled = true}
    })
    
    -- Bold Both Paragraph
    TextSection2:Paragraph("ParagraphBoldBoth", {
        Title = "Bold Title",
        Text = "Bold text here...",
        Bold = {Type = "Both", Enabled = true}
    })

    local InputSection1 = InputSubTab:Section({
        Header = "Inputs",
        Side = "Left"
    })
    
    -- Text Input
    local TextInput = InputSection1:Input("TextInput", {
        Name = "Username",
        Placeholder = "Type your username...",
        Default = "Player",
        Callback = function(value)
            print("Text Input:", value)
        end
    })
    
    -- Numeric Input
    local NumericInput = InputSection1:Input("NumericInput", {
        Name = "Age",
        Placeholder = "Enter age...",
        Numeric = true,
        Default = 18,
        Callback = function(value)
            print("Numeric Input:", value)
        end
    })
    
    -- Clear on Focus Input
    local ClearInput = InputSection1:Input("ClearInput", {
        Name = "Clear on Focus",
        Placeholder = "Click to clear...",
        Default = "Clear me",
        ClearOnFocus = true,
        Callback = function(value)
            print("Clear Input:", value)
        end
    })
    
    local InputSection2 = InputSubTab:Section({
        Header = "Keybinds",
        Side = "Right"
    })
    
    -- Click Keybind
    local ClickKeybind = InputSection2:KeyBind("ClickKeybind", {
        Name = "Toggle Menu",
        Default = "K",
        Hold = false,
        Callback = function(key)
            print("Key pressed:", key)
        end
    })
    
    -- Hold Keybind
    local HoldKeybind = InputSection2:KeyBind("HoldKeybind", {
        Name = "Sprint",
        Default = "LeftShift",
        Hold = true,
        Callback = function(state)
            print("Hold state:", state)
        end
    })
    
    -- Default Keybind
    local DefaultKeybind = InputSection2:KeyBind("DefaultKeybind", {
        Name = "Interact",
        Default = "E",
        Hold = false,
        Callback = function(key)
            print("Interact:", key)
        end
    })
    
    local DialogSection = InputSubTab:Section({
        Header = "Dialogs & Notifications",
        Side = "Right"
    })
    
    -- Dialog Button
    DialogSection:Button("ShowDialog", {
        Name = "Show Dialog",
        Callback = function()
            Window:Dialog({
                Title = "Confirmation",
                Description = "Are you sure you want to continue? This action cannot be undone.",
                Buttons = {
                    {
                        Name = "Yes",
                        Callback = function()
                            print("Yes clicked!")
                            Window:Notification({
                                Title = "Confirmed",
                                Message = "You clicked Yes!",
                                Duration = 2,
                                Position = "Screen"
                            })
                        end
                    },
                    {
                        Name = "No",
                        Callback = function()
                            print("No clicked!")
                            Window:Notification({
                                Title = "Cancelled",
                                Message = "Operation cancelled!",
                                Duration = 2,
                                Position = "Screen"
                            })
                        end
                    }
                }
            })
        end
    })
    
    -- Screen Notification
    DialogSection:Button("ScreenNotification", {
        Name = "Screen Notification",
        Callback = function()
            Window:Notification({
                Title = "Screen Notification",
                Message = "This is a notification on the screen!",
                Duration = 3,
                Position = "Screen",
                ShowProgress = true
            })
        end
    })
    
    -- Menu Notification
    DialogSection:Button("MenuNotification", {
        Name = "Menu Notification",
        Callback = function()
            Window:Notification({
                Title = "Menu Notification",
                Message = "This is a notification inside the menu!",
                Duration = 3,
                Position = "Menu",
                ShowProgress = true
            })
        end
    })

    return Window
end

return Lib
