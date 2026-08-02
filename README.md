```markdown
# 🚀 AiCode Library

Uma biblioteca de UI moderna e intuitiva para Roblox, projetada para facilitar a criação de interfaces elegantes.

---

## 📥 Instalação

```luau
local AiCode = loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIU-SC/Librarys/refs/heads/main/src.lua"))()
```

---

🏗️ Criando uma Janela

```luau
local Window = AiCode:Window({
    Title = "AiCode",
    Theme = "Darker",
    ShowUserInfo = false,
    AcrylicBlur = false,
    Button = {Enabled = true},
    Size = {550, 350},
    KeyBind = Enum.KeyCode.K
})
```

```luau
--[[
    Title: Título da janela
    Theme: "Darker" ou "Light"
    ShowUserInfo: Mostrar informações do usuário (true/false)
    AcrylicBlur: Efeito de blur (true/false)
    Button: Configurações do botão de fechar
    Size: Tamanho da janela {Largura, Altura}
    KeyBind: Tecla para abrir/fechar (Enum.KeyCode)
]]
```

---

📑 Abas e Sub-Abas

Criando uma Aba

```luau
local Tab = Window:Tab({
    Icon = "Home"
})
```

```luau
--[[
    Icon: Ícone da aba (ex: "Home", "Settings", "Gear")
]]
```

Criando uma Sub-Aba

```luau
local SubTab = Tab:SubTab({
    Name = "Configurações"
})
```

```luau
--[[
    Name: Nome da sub-aba que aparecerá no menu
]]
```

Criando uma Seção

```luau
local Section = SubTab:Section({
    Header = "Título da Seção",
    Side = "Left"
})
```

```luau
--[[
    Header: Título da seção
    Side: Lado da tela - "Left" ou "Right"
]]
```

---

🎮 Elementos UI

Botão

```luau
Section:Button("ButtonId", {
    Name = "Clique Aqui!",
    Callback = function()
        print("Botão clicado!")
    end
})
```

Toggle (Interruptor)

```luau
-- Estilo 1 (Moderno)
Section:Toggle("ToggleId", {
    Name = "Toggle Moderno",
    Default = false,
    Style = 1,
    Callback = function(value)
        print("Toggle:", value)
    end
})

-- Estilo 2 (Bola)
Section:Toggle("ToggleId2", {
    Name = "Toggle Bola",
    Default = false,
    Style = 2,
    Callback = function(value)
        print("Toggle:", value)
    end
})
```

Checkbox

```luau
Section:Checkbox("CheckboxId", {
    Name = "Ativar Recurso",
    Default = true,
    Callback = function(value)
        print("Checkbox:", value)
    end
})
```

Color Picker

```luau
local colorpicker = Section:Colorpicker("ColorpickerId", {
    Name = "Selecionar Cor",
    Default = Color3.fromRGB(255, 100, 50),
    Cursor = true,
    Callback = function(color)
        print("Cor selecionada:", color)
    end
})
```

Slider

```luau
Section:Slider("SliderId", {
    Name = "Volume",
    Default = 50,
    Minimum = 0,
    Maximum = 100,
    Precision = 0,
    DisplayMethod = "Percent",
    Callback = function(value)
        print("Valor:", value)
    end
})
```

Dropdown

```luau
-- Seleção Única
Section:Dropdown("DropdownId", {
    Name = "Selecione uma Opção",
    Values = {"Opção 1", "Opção 2", "Opção 3"},
    Default = "Opção 1",
    MultiSelection = false,
    Callback = function(value)
        print("Selecionado:", value)
    end
})

-- Múltipla Seleção
Section:Dropdown("DropdownId2", {
    Name = "Selecione Várias",
    Values = {"Maçã", "Banana", "Laranja", "Uva"},
    Default = {"Maçã", "Laranja"},
    MultiSelection = true,
    Callback = function(value)
        print("Selecionados:", value)
    end
})
```

Label

```luau
Section:Label("LabelId", {
    Text = "Rótulo Simples"
})

Section:Label("LabelId2", {
    Text = "Rótulo Negrito",
    Bold = true
})

Section:Label("LabelId3", {
    Text = "Rótulo Sublinhado",
    Subline = true
})
```

Paragraph

```luau
Section:Paragraph("ParagraphId", {
    Title = "Informação Importante",
    Text = "Este é um parágrafo com informações detalhadas.",
    Bold = {Type = "Title", Enabled = true}
})
```

Input

```luau
-- Texto
Section:Input("InputId", {
    Name = "Usuário",
    Placeholder = "Digite seu usuário...",
    Default = "Player",
    Callback = function(value)
        print("Texto:", value)
    end
})

-- Numérico
Section:Input("InputId2", {
    Name = "Idade",
    Placeholder = "Digite sua idade...",
    Numeric = true,
    Default = 18,
    Callback = function(value)
        print("Número:", value)
    end
})

-- Limpar ao focar
Section:Input("InputId3", {
    Name = "Limpar ao Focar",
    Placeholder = "Clique para limpar...",
    Default = "Limpe-me",
    ClearOnFocus = true,
    Callback = function(value)
        print("Valor:", value)
    end
})
```

KeyBind

```luau
-- Toggle com KeyBind
Section:ToggleKeyBind("ToggleKeyId", {
    Name = "Ativar/Desativar",
    Default = false,
    KeyCode = Enum.KeyCode.C,
    Callback = function(value)
        print("Estado:", value)
    end
})

-- KeyBind Simples
Section:KeyBind("KeyBindId", {
    Name = "Abrir Menu",
    Default = "K",
    Hold = false,
    Callback = function(key)
        print("Tecla:", key)
    end
})

-- KeyBind com Hold
Section:KeyBind("KeyBindId2", {
    Name = "Correr",
    Default = "LeftShift",
    Hold = true,
    Callback = function(state)
        print("Segurando:", state)
    end
})
```

Diálogos e Notificações

```luau
-- Diálogo
Section:Button("DialogId", {
    Name = "Mostrar Diálogo",
    Callback = function()
        Window:Dialog({
            Title = "Confirmação",
            Description = "Tem certeza que deseja continuar?",
            Buttons = {
                {
                    Name = "Sim",
                    Callback = function()
                        Window:Notification({
                            Title = "Confirmado",
                            Message = "Você clicou em Sim!",
                            Duration = 2,
                            Position = "Screen"
                        })
                    end
                },
                {
                    Name = "Não",
                    Callback = function()
                        Window:Notification({
                            Title = "Cancelado",
                            Message = "Operação cancelada!",
                            Duration = 2,
                            Position = "Screen"
                        })
                    end
                }
            }
        })
    end
})

-- Notificações
Section:Button("NotificationId", {
    Name = "Notificação na Tela",
    Callback = function()
        Window:Notification({
            Title = "Notificação",
            Message = "Esta é uma notificação na tela!",
            Duration = 3,
            Position = "Screen",
            ShowProgress = true
        })
    end
})
```

Save/Load

```luau
local SaveManager = Window:SaveLoad({})
```

---

🎨 Métodos dos Elementos

Color Picker

```luau
colorpicker:SetColor(Color3.fromRGB(0, 255, 0)) -- Definir cor
colorpicker:GetColor() -- Obter cor atual
colorpicker:GetHSV() -- Obter HSV
colorpicker:SetHSV(0.5, 1, 1) -- Definir HSV
colorpicker:SetVisibility(true) -- Visibilidade
colorpicker:Destroy() -- Destruir
```

Slider

```luau
slider:SetValue(75) -- Definir valor
slider:GetValue() -- Obter valor atual
slider:SetVisibility(true) -- Visibilidade
slider:Destroy() -- Destruir
```

Dropdown

```luau
dropdown:SetValue("Opção 2") -- Definir valor
dropdown:GetValue() -- Obter valor atual
dropdown:SetVisibility(true) -- Visibilidade
dropdown:Destroy() -- Destruir
```

Toggle

```luau
toggle:SetValue(true) -- Definir estado
toggle:GetValue() -- Obter estado atual
toggle:SetVisibility(true) -- Visibilidade
toggle:Destroy() -- Destruir
```

Input

```luau
input:SetValue("Novo texto") -- Definir valor
input:GetValue() -- Obter valor atual
input:SetVisibility(true) -- Visibilidade
input:Destroy() -- Destruir
```

---

🎨 Temas Disponíveis

· "Darker" - Tema escuro (padrão)
· "Light" - Tema claro

---

📝 Exemplo Completo

```luau
local AiCode = loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIU-SC/Librarys/refs/heads/main/src.lua"))()

local Window = AiCode:Window({
    Title = "Meu Menu",
    Theme = "Darker",
    Folder = "MeuMenu",
    Size = {550, 350},
    KeyBind = Enum.KeyCode.K
})

local MainTab = Window:Tab({ Icon = "Home" })
local SettingsSub = MainTab:SubTab({ Name = "Configurações" })

local Section = SettingsSub:Section({
    Header = "Controles",
    Side = "Left"
})

Section:Toggle("Toggle", {
    Name = "Ativar",
    Default = false,
    Callback = function(value)
        print(value)
    end
})

Section:Slider("Slider", {
    Name = "Valor",
    Default = 50,
    Minimum = 0,
    Maximum = 100,
    Callback = function(value)
        print(value)
    end
})

return Window
```

---

⚙️ Sistema de Salvamento Automático

A biblioteca possui um sistema de salvamento automático que preserva o estado dos elementos entre sessões.

```luau
local SaveManager = Window:SaveLoad({})
```

Os elementos salvos incluem:

· Toggles
· Checkboxes
· Sliders
· Inputs
· Color Pickers
· Dropdowns

---

📄 Licença

MIT License - Use como quiser!

---

🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

---

Desenvolvido com ❤️ por KALIU-SC

```
```
