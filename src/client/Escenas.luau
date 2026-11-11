local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Interfaz = require(script.Parent.Interfaz)

local Escenas = {}

local T = Interfaz.TEMA
local crear = Interfaz.crear
local rgb = Color3.fromRGB
local SEGUNDOS_POR_LINEA = 4.6

function Escenas.crear(pantalla: ScreenGui, hud)
	local jugador = Players.LocalPlayer
	local e = {}

	local franjas = {}
	for _, arriba in { true, false } do
		franjas[arriba] = crear("Frame", {
			AnchorPoint = Vector2.new(0, if arriba then 0 else 1),
			Position = UDim2.fromScale(0, if arriba then 0 else 1),
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Color3.new(),
			BorderSizePixel = 0,
			ZIndex = 20,
			Parent = pantalla,
		})
	end
	local function cine(activo: boolean, alto: number?)
		local h = if activo then (alto or 0.11) else 0
		for _, f in franjas do
			TweenService:Create(f, TweenInfo.new(0.8, Enum.EasingStyle.Sine), { Size = UDim2.new(1, 0, h, 0) }):Play()
		end
	end

	local capitulo = crear("CanvasGroup", {
		Name = "Capitulo",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.35,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 30,
		Parent = pantalla,
	})
	local capNumero = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 26,
		TextColor3 = T.textoSuave,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.38),
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		ZIndex = 31,
		Parent = capitulo,
	})
	local capNombre = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 70,
		TextColor3 = rgb(255, 246, 226),
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.46),
		Size = UDim2.new(1, 0, 0, 80),
		Text = "",
		ZIndex = 31,
		Parent = capitulo,
	})
	local capTexto = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 22,
		TextColor3 = T.textoSuave,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Top,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.56),
		Size = UDim2.new(0.6, 0, 0, 140),
		Text = "",
		ZIndex = 31,
		Parent = capitulo,
	})
	local idCapitulo = 0
	function e.capitulo(n: number, texto: string?)
		local etapa = Config.ETAPAS[n]
		if not etapa then
			return
		end
		idCapitulo += 1
		local este = idCapitulo
		capNumero.Text = "Capítulo " .. n
		capNombre.Text = etapa.icono .. "  " .. etapa.nombre
		capTexto.Text = texto or ""
		Interfaz.fundido(capitulo, true, 1.2)
		task.delay(if texto then 8 else 4.5, function()
			if idCapitulo == este then
				Interfaz.fundido(capitulo, false, 1.5)
			end
		end)
	end

	local masLejos = 0
	task.spawn(function()
		while true do
			task.wait(0.5)
			local personaje = jugador.Character
			local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
			if raiz then
				local n = Config.etapaEn(raiz.Position.Z)
				if n > masLejos then
					local primera = masLejos == 0
					masLejos = n
					if primera and n == 1 then
						task.wait(1)
						e.capitulo(1, Historia.INTRO)
					else
						e.capitulo(n)
					end
				end
			end
		end
	end)

	local caja = crear("CanvasGroup", {
		Name = "Subtitulos",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.86, 0),
		Size = UDim2.fromOffset(760, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.4,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 25,
		Parent = pantalla,
	}, { Interfaz.esquinas(10), Interfaz.relleno(12) })
	crear("UISizeConstraint", { MaxSize = Vector2.new(760, math.huge), Parent = caja })
	local subTexto = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 20,
		RichText = true,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		ZIndex = 26,
		Parent = caja,
	})
	local idCharla = 0
	function e.subtitulos(lineas, nombreJugador: string)
		idCharla += 1
		local este = idCharla
		cine(true, 0.08)
		Interfaz.fundido(caja, true, 0.4)
		task.spawn(function()
			for _, linea in lineas do
				if idCharla ~= este then
					return
				end
				local quien = if linea.quien == "Lia" then '<font color="#fac83c">Lía</font>' else '<font color="#9fd0ff">' .. nombreJugador .. "</font>"
				local texto = linea.texto
				local largo = utf8.len(texto) or #texto
				local paso = math.max(1, math.floor(largo / 40))
				for i = paso, largo, paso do
					if idCharla ~= este then
						return
					end
					local corte = utf8.offset(texto, i + 1)
					subTexto.Text = quien .. ":  " .. (if corte then string.sub(texto, 1, corte - 1) else texto)
					task.wait(0.03)
				end
				subTexto.Text = quien .. ":  " .. texto
				task.wait(math.max(1, SEGUNDOS_POR_LINEA - largo / paso * 0.03))
			end
			if idCharla == este then
				Interfaz.fundido(caja, false, 0.8)
				cine(false)
			end
		end)
	end

	local monologo = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 28,
		TextColor3 = rgb(255, 248, 232),
		TextStrokeTransparency = 0.5,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.86, 0),
		Size = UDim2.new(0.7, 0, 0, 90),
		Text = "",
		TextTransparency = 1,
		ZIndex = 25,
		Parent = pantalla,
	})
	local enMirador = false
	function e.mirador(n: number, camPos: Vector3, camMira: Vector3)
		local datos = Historia.MIRADORES[n]
		local camara = workspace.CurrentCamera
		if not datos or enMirador or typeof(camPos) ~= "Vector3" or typeof(camMira) ~= "Vector3" then
			return
		end
		enMirador = true
		local personaje = jugador.Character
		local hum = personaje and personaje:FindFirstChildOfClass("Humanoid")
		hud.mostrar(false)
		cine(true)
		camara.CameraType = Enum.CameraType.Scriptable
		local destino = CFrame.lookAt(camPos, camMira)
		local total = #datos.lineas * SEGUNDOS_POR_LINEA + 2
		TweenService:Create(camara, TweenInfo.new(2.5, Enum.EasingStyle.Sine), { CFrame = destino }):Play()
		task.delay(2.5, function()
			if enMirador then
				local deriva = CFrame.lookAt(camPos + (camMira - camPos).Unit * 6 + Vector3.new(0, 1.5, 0), camMira)
				TweenService:Create(camara, TweenInfo.new(total, Enum.EasingStyle.Linear), { CFrame = deriva }):Play()
			end
		end)
		local terminado = false
		local function terminar()
			if terminado then
				return
			end
			terminado = true
			enMirador = false
			TweenService:Create(monologo, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
			cine(false)
			camara.CameraType = Enum.CameraType.Custom
			hud.mostrar(true)
		end
		local conexion
		if hum then
			conexion = hum:GetPropertyChangedSignal("Sit"):Connect(function()
				if not hum.Sit then
					terminar()
				end
			end)
		end
		task.spawn(function()
			task.wait(2)
			for _, linea in datos.lineas do
				if terminado then
					break
				end
				monologo.Text = linea
				TweenService:Create(monologo, TweenInfo.new(0.8), { TextTransparency = 0, TextStrokeTransparency = 0.5 }):Play()
				task.wait(SEGUNDOS_POR_LINEA - 0.8)
				TweenService:Create(monologo, TweenInfo.new(0.6), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
				task.wait(0.8)
			end
			if conexion then
				conexion:Disconnect()
			end
			terminar()
		end)
	end

	local aviso = crear("CanvasGroup", {
		Name = "TesoroNuevo",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.2, 0),
		Size = UDim2.fromOffset(380, 120),
		BackgroundColor3 = T.pergamino,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 22,
		Parent = pantalla,
	}, { Interfaz.esquinas(14), Interfaz.contorno(rgb(170, 120, 60), 2, 0) })
	local avisoIcono = Interfaz.texto({
		Text = "",
		TextSize = 54,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(100, 120),
		ZIndex = 23,
		Parent = aviso,
	})
	Interfaz.texto({
		Font = T.fuenteHistoria,
		Text = "Un tesoro nuevo para Lía",
		TextSize = 20,
		TextColor3 = rgb(130, 90, 50),
		Size = UDim2.new(1, -110, 0, 26),
		Position = UDim2.fromOffset(100, 18),
		ZIndex = 23,
		Parent = aviso,
	})
	local avisoNombre = Interfaz.texto({
		Font = T.fuenteHistoria,
		Text = "",
		TextSize = 28,
		TextColor3 = T.tinta,
		TextWrapped = true,
		Size = UDim2.new(1, -110, 0, 34),
		Position = UDim2.fromOffset(100, 44),
		ZIndex = 23,
		Parent = aviso,
	})
	local avisoQuien = Interfaz.texto({
		Font = T.fuenteMedia,
		Text = "",
		TextSize = 14,
		TextColor3 = rgb(130, 90, 50),
		Size = UDim2.new(1, -110, 0, 20),
		Position = UDim2.fromOffset(100, 82),
		ZIndex = 23,
		Parent = aviso,
	})
	local idAviso = 0
	function e.tesoro(n: number, quien: string?)
		local datos = Historia.TESOROS[n]
		if not datos then
			return
		end
		idAviso += 1
		local este = idAviso
		avisoIcono.Text = datos.icono
		avisoNombre.Text = datos.nombre
		avisoQuien.Text = if quien then "Lo encontró " .. quien .. "  ·  Cuaderno [J]" else ""
		Interfaz.fundido(aviso, true, 0.4)
		task.delay(4.5, function()
			if idAviso == este then
				Interfaz.fundido(aviso, false, 0.8)
			end
		end)
	end

	return e
end

return Escenas
