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
    Folder = “AiCode”,
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
    Icon: Ícone da aba (ex: "Home", "Settings", "Gear", "User")
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

```luau
--[[
    Name: Texto exibido no botão
    Callback: Função executada ao clicar
]]
```

Toggle (Interruptor)

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
    Name: Texto exibido no toggle
    Default: Valor inicial (true/false)
    Style: Estilo do toggle (1 = Moderno, 2 = Bola)
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
    Name: Texto exibido no checkbox
    Default: Valor inicial (true/false)
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
    Name: Texto exibido no color picker
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
    Name: Texto exibido no slider
    Default: Valor inicial
    Minimum: Valor mínimo
    Maximum: Valor máximo
    Precision: Casas decimais
    DisplayMethod: Formato de exibição ("Percent", "Value", "Degrees", "Hundredths")
    Callback: Função executada ao alterar valor
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
    Name: Texto exibido no dropdown
    Values: Lista de opções
    Default: Valor padrão
    MultiSelection: Permitir múltipla seleção (true/false)
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
    Text: Texto exibido no label
    Bold: Texto em negrito (true/false)
    Subline: Texto sublinhado (true/false)
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
    Bold.Type: "Title", "Text" ou "Both"
    Bold.Enabled: true/false
]]
```

Input

```luau
Section:Input("InputId", {
    Name = "Input",
    Placeholder = "Digite algo...",
    Numeric = false,
    ClearOnFocus = false,
    Default = "Texto",
    Callback = function(value)
        print("Input:", value)
    end
})
```

```luau
--[[
    Name: Texto exibido no input
    Placeholder: Texto de placeholder
    Numeric: Apenas números (true/false)
    ClearOnFocus: Limpar ao focar (true/false)
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
    Name: Texto exibido no toggle
    Default: Valor inicial (true/false)
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
    Name: Texto exibido no keybind
    Default: Tecla padrão (ex: "K", "LeftShift")
    Hold: Modo de segurar (true/false)
    Callback: Função executada ao pressionar
]]
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
    end
})
```

```luau
--[[
    Title: Título do diálogo
    Description: Descrição do diálogo
    Buttons: Lista de botões com Name e Callback
]]
```

```luau
-- Notificações
Section:Button("NotificationId", {
    Name = "Notificação na Tela",
    Callback = function()
        Window:Notification({
            Title = "Notificação",
            Message = "Esta é uma notificação!",
            Duration = 3,
            Position = "Screen",
            ShowProgress = true
        })
    end
})
```

```luau
--[[
    Title: Título da notificação
    Message: Mensagem da notificação
    Duration: Duração em segundos
    Position: "Screen" ou "Menu"
    ShowProgress: Mostrar barra de progresso (true/false)
]]
```

Save/Load

```luau
local SaveManager = Window:SaveLoad({})
```

```luau
--[[
    Sistema de salvamento automático
    Preserva o estado de todos os elementos
]]
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

Checkbox

```luau
checkbox:SetValue(true) -- Definir estado
checkbox:GetValue() -- Obter estado atual
checkbox:SetVisibility(true) -- Visibilidade
checkbox:Destroy() -- Destruir
```

---

🎨 Temas Disponíveis

· "Darker" - Tema escuro (padrão)
· "Light" - Tema claro
· "Rose" - Tema rose
· "Ocean" - Tema oceano
· "Forest" - Tema floresta
· "Midnight" - Tema noturno
· "Eclipse" - Tema vermelho escuro

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
```

---

⚙️ Sistema de Salvamento Automático

A biblioteca possui um sistema de salvamento automático que preserva o estado dos elementos entre sessões.

```luau
local SaveManager = Window:SaveLoad({})
```

Elementos salvos automaticamente:

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
