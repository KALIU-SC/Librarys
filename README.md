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
    Folder = "AiCode",
    Size = {550, 350},
    AcrylicBlur = false,
    Button = {
        Enabled = true,
        Size = {45, 45},
        Position = {30, 30}
    },
    KeyBind = Enum.KeyCode.K
})
```

```luau
--[[
    Title: Título da janela
    Theme: "Darker", "Light", "Rose", "Ocean", "Forest", "Midnight", "Eclipse"
    Folder: Pasta para salvar configurações
    Size: Tamanho da janela {Largura, Altura}
    AcrylicBlur: Efeito de blur (true/false)
    Button: Configurações do botão de fechar
        Enabled: true/false
        Size: {Largura, Altura}
        Position: {X, Y}
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
    Icon: Ícone da aba ("Home", "Settings", "Gear", "User")
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
    Name: Nome da sub-aba
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
    Side: "Left" ou "Right"
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

```luau
--[[
    Name: Texto do botão
    Callback: Função executada ao clicar
]]
```

Toggle

```luau
Section:Toggle("ToggleId", {
    Name = "Toggle Moderno",
    Default = false,
    Style = 1,
    Callback = function(value)
        print("Toggle:", value)
    end
})
```

```luau
--[[
    Name: Texto do toggle
    Default: true/false
    Style: 1 (Moderno) ou 2 (Bola)
    Callback: Função executada ao alternar
]]
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

```luau
--[[
    Name: Texto do checkbox
    Default: true/false
    Callback: Função executada ao alternar
]]
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

```luau
--[[
    Name: Texto do color picker
    Default: Cor inicial (Color3)
    Cursor: Mostrar cursor (true/false)
    Callback: Função executada ao selecionar cor
]]
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

```luau
--[[
    Name: Texto do slider
    Default: Valor inicial
    Minimum: Valor mínimo
    Maximum: Valor máximo
    Precision: Casas decimais (0, 1, 2, 3)
    DisplayMethod: "Percent", "Value", "Degrees", "Hundredths"
    Callback: Função executada ao alterar
]]
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
```

```luau
--[[
    Name: Texto do dropdown
    Values: Lista de opções
    Default: Valor padrão
    MultiSelection: true/false
    Callback: Função executada ao selecionar
]]
```

Label

```luau
Section:Label("LabelId", {
    Text = "Rótulo Simples",
    Bold = false,
    Subline = false
})
```

```luau
--[[
    Text: Texto do label
    Bold: true/false
    Subline: true/false
]]
```

Paragraph

```luau
Section:Paragraph("ParagraphId", {
    Title = "Informação Importante",
    Text = "Este é um parágrafo com informações detalhadas.",
    Bold = {Type = "Title", Enabled = true}
})
```

```luau
--[[
    Title: Título do parágrafo
    Text: Conteúdo do parágrafo
    Bold.Type: "Title", "Text", "Both"
    Bold.Enabled: true/false
]]
```

Input

```luau
Section:Input("InputId", {
    Name = "Usuário",
    Placeholder = "Digite seu usuário...",
    Numeric = false,
    ClearOnFocus = false,
    Default = "Player",
    Callback = function(value)
        print("Input:", value)
    end
})
```

```luau
--[[
    Name: Texto do input
    Placeholder: Texto de placeholder
    Numeric: true/false
    ClearOnFocus: true/false
    Default: Valor padrão
    Callback: Função executada ao alterar
]]
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
```

```luau
--[[
    Name: Texto do toggle
    Default: true/false
    KeyCode: Tecla para alternar (Enum.KeyCode)
    Callback: Função executada ao alternar
]]
```

```luau
-- KeyBind com Hold
Section:KeyBind("KeyBindId", {
    Name = "Correr",
    Default = "LeftShift",
    Hold = true,
    Callback = function(state)
        print("Segurando:", state)
    end
})
```

```luau
--[[
    Name: Texto do keybind
    Default: Tecla padrão
    Hold: true/false
    Callback: Função executada ao pressionar
]]
```

---

💬 Diálogos e Notificações

Dialog

```luau
Window:Dialog({
    Title = "Confirmação",
    Description = "Tem certeza que deseja continuar?",
    Buttons = {
        {
            Name = "Sim",
            Callback = function()
                print("Clicou em Sim")
            end
        },
        {
            Name = "Não",
            Callback = function()
                print("Clicou em Não")
            end
        }
    }
})
```

Notification

```luau
Window:Notification({
    Title = "Notificação",
    Message = "Esta é uma notificação!",
    Duration = 3,
    Position = "Screen",
    ShowProgress = true
})
```

```luau
--[[
    Title: Título da notificação
    Message: Mensagem da notificação
    Duration: Duração em segundos
    Position: "Screen" ou "Menu"
    ShowProgress: true/false
]]
```

---

💾 Save/Load

```luau
local SaveManager = Window:SaveLoad({})
```

---

🎨 Temas Disponíveis

· "Darker" - Tema escuro (padrão)
· "Light" - Tema claro
· "Rose" - Tema rosa
· "Ocean" - Tema oceano
· "Forest" - Tema floresta
· "Midnight" - Tema meia-noite
· "Eclipse" - Tema eclipse

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

📄 Licença

MIT License - Use como quiser!

---

Desenvolvido com ❤️ por KALIU-SC

```
```
