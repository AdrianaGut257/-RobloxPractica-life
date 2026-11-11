local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Progreso = require(Shared:WaitForChild("Progreso"))
local Interfaz = require(script.Parent.Interfaz)

local Hud = {}

local T = Interfaz.TEMA
local crear = Interfaz.crear
local rgb = Color3.fromRGB

local ESTADOS_LIA = {
	Siguiendo = { "Te sigue de cerca", T.textoSuave },
	Esperando = { "Te está esperando", T.textoSuave },
	Fuego = { "Calentita junto al fuego", T.verde },
	Cerca = { "Agarrada a tu mano...", rgb(255, 200, 120) },
	Asustada = { "¡Tiene miedo! Ve a consolarla", T.rojo },
	Sentada = { "Sentada a tu lado", T.verde },
}

function Hud.crear(gui: ScreenGui, pantalla: ScreenGui, estado: Instance)
	local jugador = Players.LocalPlayer
	local hud = {}

	local escala = crear("UIScale", { Parent = gui })
	local function ajustarEscala()
		local camara = workspace.CurrentCamera
		local alto = if camara then camara.ViewportSize.Y else 800
		escala.Scale = math.clamp(alto / 820, 0.6, 1)
	end
	ajustarEscala()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
	end

	local reloj = Interfaz.panel({
		Name = "Reloj",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(330, 92),
		Parent = gui,
	})
	local faseTxt = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 28,
		Size = UDim2.new(1, -100, 0, 32),
		Position = UDim2.fromOffset(12, 3),
		Text = "",
		Parent = reloj,
	})
	local tiempoTxt = Interfaz.texto({
		TextSize = 18,
		TextColor3 = T.textoSuave,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.fromOffset(80, 32),
		Position = UDim2.new(1, -92, 0, 3),
		Text = "",
		Parent = reloj,
	})
	local barraTiempo = Interfaz.barra({
		Position = UDim2.new(0, 12, 0, 38),
		Size = UDim2.new(1, -24, 0, 8),
		Parent = reloj,
		color = T.oro,
	})
	local tira = crear("Frame", {
		Position = UDim2.new(0, 12, 0, 52),
		Size = UDim2.new(1, -24, 0, 32),
		BackgroundTransparency = 1,
		Parent = reloj,
	}, {
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
	})
	local nEtapas = #Config.ETAPAS
	local puntos = {}
	for i, etapa in Config.ETAPAS do
		local x = (i - 1) / (nEtapas - 1)
		if i < nEtapas then
			crear("Frame", {
				Name = "Linea",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(x, 14, 0.5, 0),
				Size = UDim2.new(1 / (nEtapas - 1), -28, 0, 3),
				BackgroundColor3 = T.borde,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				Parent = tira,
			})
		end
		local punto = crear("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(x, 0, 0.5, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = rgb(40, 44, 40),
			Text = etapa.icono,
			TextSize = 15,
			Font = T.fuente,
			TextColor3 = T.texto,
			Parent = tira,
		}, { Interfaz.esquinas(14), Interfaz.contorno(T.borde, 1, 0.6) })
		puntos[i] = punto
	end

	local objetivo = Interfaz.panel({
		Name = "Objetivo",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 108),
		Size = UDim2.fromOffset(560, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.35,
		Parent = gui,
	})
	Interfaz.relleno(8).Parent = objetivo
	local objetivoTxt = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 16,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		Parent = objetivo,
	})

	local izquierda = crear("Frame", {
		Name = "Izquierda",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(260, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		crear("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local panelFuego = Interfaz.panel({ Size = UDim2.fromOffset(260, 108), LayoutOrder = 1, Parent = izquierda })
	local fuegoTitulo = Interfaz.texto({ Text = "🔥 FUEGO", TextSize = 15, Size = UDim2.new(1, -24, 0, 22), Position = UDim2.fromOffset(12, 8), Parent = panelFuego })
	local barraFuego = Interfaz.barra({ Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 18), Parent = panelFuego, color = T.fuego })
	local luzTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 14, Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(12, 60), Text = "", Parent = panelFuego })
	local enemigosTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 13, TextColor3 = T.textoSuave, Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(12, 82), Text = "", Parent = panelFuego })

	local panelVida = Interfaz.panel({ Size = UDim2.fromOffset(260, 74), LayoutOrder = 2, Parent = izquierda })
	Interfaz.texto({ Text = "❤️", TextSize = 16, Size = UDim2.fromOffset(24, 22), Position = UDim2.fromOffset(10, 10), Parent = panelVida })
	local barraVida = Interfaz.barra({ Position = UDim2.new(0, 38, 0, 12), Size = UDim2.new(1, -50, 0, 18), Parent = panelVida, color = T.vida })
	Interfaz.texto({ Text = "🍖", TextSize = 16, Size = UDim2.fromOffset(24, 22), Position = UDim2.fromOffset(10, 42), Parent = panelVida })
	local barraHambre = Interfaz.barra({ Position = UDim2.new(0, 38, 0, 44), Size = UDim2.new(1, -50, 0, 18), Parent = panelVida, color = T.hambre })
	local filaFrio = crear("Frame", { Size = UDim2.new(1, 0, 0, 32), Position = UDim2.fromOffset(0, 72), BackgroundTransparency = 1, Visible = false, Parent = panelVida })
	Interfaz.texto({ Text = "❄️", TextSize = 16, Size = UDim2.fromOffset(24, 22), Position = UDim2.fromOffset(10, 2), Parent = filaFrio })
	local barraFrio = Interfaz.barra({ Position = UDim2.new(0, 38, 0, 4), Size = UDim2.new(1, -50, 0, 18), Parent = filaFrio, color = T.frio })

	local derecha = crear("Frame", {
		Name = "Derecha",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(220, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		crear("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local mochila = Interfaz.panel({ Size = UDim2.fromOffset(220, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = derecha })
	Interfaz.relleno(12).Parent = mochila
	crear("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = mochila })
	Interfaz.texto({ Text = "🎒 MOCHILA", TextSize = 15, TextColor3 = T.oro, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, Parent = mochila })
	local filas = {}
	for i, recurso in Config.RECURSOS_MOCHILA do
		filas[recurso] = Interfaz.texto({
			Font = T.fuenteMedia,
			TextSize = 15,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = 1 + i,
			Text = "",
			Parent = mochila,
		})
	end
	local botonComer = Interfaz.boton({ Text = "🍎 Comer  [F]", Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 10, Parent = mochila })

	local panelLia = Interfaz.panel({ Size = UDim2.fromOffset(220, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = derecha })
	Interfaz.relleno(12).Parent = panelLia
	crear("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = panelLia })
	local liaTitulo = Interfaz.texto({ Text = "👧 LÍA", TextSize = 15, TextColor3 = T.lia, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, Parent = panelLia })
	local barraLia = Interfaz.barra({ Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 2, Parent = panelLia, color = T.verde })
	local liaEstadoTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 13, TextWrapped = true, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 3, Text = "", Parent = panelLia })
	crear("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.borde, BackgroundTransparency = 0.7, BorderSizePixel = 0, LayoutOrder = 4, Parent = panelLia })
	local paginasTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 14, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 5, Text = "", Parent = panelLia })
	local tesorosTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 14, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 6, Text = "", Parent = panelLia })
	local botonCuaderno = Interfaz.boton({ Text = "📖 Cuaderno  [J]", Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 7, Parent = panelLia })

	hud.alComer = function() end
	hud.alCuaderno = function() end
	botonComer.Activated:Connect(function()
		hud.alComer()
	end)
	botonCuaderno.Activated:Connect(function()
		hud.alCuaderno()
	end)

	local avisos = crear("Frame", {
		Name = "Avisos",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -96),
		Size = UDim2.fromOffset(580, 240),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		crear("UIListLayout", {
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local contadorAvisos = 0

	function hud.notificar(texto: string, color: Color3?)
		contadorAvisos += 1
		local grupo = crear("CanvasGroup", {
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = T.panel,
			BackgroundTransparency = 0.2,
			GroupTransparency = 1,
			LayoutOrder = contadorAvisos,
			Parent = avisos,
		}, { Interfaz.esquinas(10), Interfaz.relleno(8) })
		local etiqueta = Interfaz.texto({
			Font = T.fuenteMedia,
			TextSize = 16,
			TextColor3 = color or T.texto,
			TextWrapped = true,
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = texto,
			Parent = grupo,
		})
		crear("UISizeConstraint", { MaxSize = Vector2.new(560, math.huge), Parent = etiqueta })
		TweenService:Create(grupo, TweenInfo.new(0.25), { GroupTransparency = 0 }):Play()
		local hijos = {}
		for _, h in avisos:GetChildren() do
			if h:IsA("CanvasGroup") then
				table.insert(hijos, h)
			end
		end
		if #hijos > 5 then
			table.sort(hijos, function(a, b)
				return a.LayoutOrder < b.LayoutOrder
			end)
			hijos[1]:Destroy()
		end
		local duracion = math.clamp(#texto / 18, 4, 9)
		task.delay(duracion, function()
			if grupo.Parent then
				local t = TweenService:Create(grupo, TweenInfo.new(0.5), { GroupTransparency = 1 })
				t:Play()
				t.Completed:Wait()
				grupo:Destroy()
			end
		end)
	end

	local anuncio = crear("CanvasGroup", {
		Name = "Anuncio",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.38),
		Size = UDim2.fromOffset(840, 150),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		Parent = gui,
	})
	local anuncioTitulo = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 60,
		TextColor3 = T.oro,
		TextStrokeTransparency = 0.3,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 66),
		Text = "",
		Parent = anuncio,
	})
	local anuncioSub = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 20,
		TextStrokeTransparency = 0.4,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 70),
		Position = UDim2.fromOffset(0, 70),
		Text = "",
		Parent = anuncio,
	})
	local idAnuncio = 0
	function hud.anunciar(titulo: string, subtitulo: string?)
		idAnuncio += 1
		local este = idAnuncio
		anuncioTitulo.Text = titulo
		anuncioSub.Text = subtitulo or ""
		Interfaz.fundido(anuncio, true, 0.6)
		task.delay(5, function()
			if idAnuncio == este then
				Interfaz.fundido(anuncio, false, 1.2)
			end
		end)
	end

	function hud.mostrar(visible: boolean)
		for _, hijo in { reloj, objetivo, izquierda, derecha } do
			hijo.Visible = visible
		end
	end

	local dano = crear("Frame", {
		Name = "Dano",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(180, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = pantalla,
	})
	local escarcha = crear("Frame", {
		Name = "Escarcha",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(170, 215, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = pantalla,
	})

	local marcador = crear("BillboardGui", {
		Name = "MarcadorLia",
		Size = UDim2.fromOffset(44, 44),
		StudsOffset = Vector3.new(0, 4, 0),
		AlwaysOnTop = true,
		Enabled = false,
		Parent = pantalla.Parent,
	})
	crear("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(40, 34, 20),
		BackgroundTransparency = 0.2,
		Text = "👧",
		TextSize = 24,
		Font = T.fuente,
		Parent = marcador,
	}, { Interfaz.esquinas(22), Interfaz.contorno(T.lia, 2, 0) })

	local function refrescarEstado()
		local fase = estado:GetAttribute("Fase") or "Dia"
		local restante = estado:GetAttribute("TiempoRestante") or 0
		local duracion = estado:GetAttribute("DuracionFase") or 1
		if fase == "Dia" then
			faseTxt.Text = "☀️  Día " .. (estado:GetAttribute("Dia") or 1)
			barraTiempo.poner(restante / duracion, nil, T.oro)
		elseif fase == "Noche" then
			faseTxt.Text = "🌙  Noche " .. (estado:GetAttribute("NocheActual") or 1)
			barraTiempo.poner(restante / duracion, nil, T.noche)
		elseif fase == "UltimaNoche" then
			faseTxt.Text = "🌕  La última noche"
			barraTiempo.poner(restante / duracion, nil, T.rojo)
		else
			faseTxt.Text = "🌅  ¡Amanece!"
			barraTiempo.poner(1, nil, T.verde)
		end
		tiempoTxt.Text = if fase == "Final" then "" else Interfaz.formatoTiempo(restante)
		objetivoTxt.Text = "🎯  " .. Progreso.objetivo(estado, jugador)

		local etapa = estado:GetAttribute("Etapa") or 1
		for i, punto in puntos do
			if i < etapa then
				punto.BackgroundColor3 = rgb(70, 110, 60)
			elseif i == etapa then
				punto.BackgroundColor3 = rgb(170, 120, 40)
			else
				punto.BackgroundColor3 = rgb(40, 44, 40)
			end
		end

		local combustible = estado:GetAttribute("Combustible") or 0
		local maximo = estado:GetAttribute("CombustibleMax") or 100
		local nivel = estado:GetAttribute("NivelFuego") or 1
		fuegoTitulo.Text = "🔥 HOGUERA  ·  Nivel " .. nivel
		local colorFuego = if combustible < maximo * 0.25 then T.rojo else T.fuego
		barraFuego.poner(combustible / maximo, string.format("%d / %d", math.floor(combustible), maximo), colorFuego)

		local enemigos = estado:GetAttribute("EnemigosVivos") or 0
		enemigosTxt.Text = if enemigos > 0 then "🌫️ " .. enemigos .. " Brumosos rondando" else ""

		local animo = estado:GetAttribute("AnimoLia") or 70
		local cara = if animo >= Config.LIA.CONTENTA then "😊" elseif animo >= Config.LIA.ASUSTADA then "😐" else "😢"
		local colorLia = if animo >= Config.LIA.CONTENTA then T.verde elseif animo >= Config.LIA.ASUSTADA then T.oro else T.rojo
		liaTitulo.Text = "👧 LÍA  " .. cara
		barraLia.poner(animo / Config.LIA.ANIMO_MAXIMO, "Ánimo  " .. math.floor(animo), colorLia)
		local info = ESTADOS_LIA[estado:GetAttribute("EstadoLia") or "Siguiendo"] or ESTADOS_LIA.Siguiendo
		liaEstadoTxt.Text = info[1]
		liaEstadoTxt.TextColor3 = info[2]
		paginasTxt.Text = string.format("📜 Notas  %d / %d", estado:GetAttribute("PaginasEncontradas") or 0, Historia.TOTAL_PAGINAS)
		tesorosTxt.Text = string.format("🎁 Tesoros  %d / %d", estado:GetAttribute("TesorosEncontrados") or 0, Historia.TOTAL_TESOROS)
	end

	local function refrescarJugador()
		for recurso, fila in filas do
			fila.Text = string.format("%s  %s:  %d", Config.ICONOS_RECURSOS[recurso], Config.NOMBRES_RECURSOS[recurso], jugador:GetAttribute(recurso) or 0)
		end
		local hambre = jugador:GetAttribute("Hambre") or 100
		barraHambre.poner(hambre / Config.HAMBRE.MAXIMA, string.format("Hambre  %d%%", math.floor(hambre)), if hambre < 20 then T.rojo else T.hambre)
		local calor = jugador:GetAttribute("Calor") or Config.FRIO.MAXIMO
		local enFrio = jugador:GetAttribute("EnFrio") == true
		local mostrarFrio = enFrio or calor < Config.FRIO.MAXIMO - 1
		filaFrio.Visible = mostrarFrio
		panelVida.Size = UDim2.fromOffset(260, if mostrarFrio then 104 else 74)
		barraFrio.poner(calor / Config.FRIO.MAXIMO, string.format("Calor  %d%%", math.floor(calor)), if calor < 25 then T.rojo else T.frio)
		local f = math.clamp(1 - calor / 40, 0, 1)
		TweenService:Create(escarcha, TweenInfo.new(0.8), { BackgroundTransparency = 1 - f * 0.3 }):Play()
		objetivoTxt.Text = "🎯  " .. Progreso.objetivo(estado, jugador)
	end

	local function refrescarLuz()
		local fase = estado:GetAttribute("Fase") or "Dia"
		local combustible = estado:GetAttribute("Combustible") or 0
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
		local centro = estado:GetAttribute("CentroLuz")
		local radio = estado:GetAttribute("RadioLuz") or 0
		local protegido = false
		if raiz and typeof(centro) == "Vector3" and radio > 0 then
			local d = Vector3.new(raiz.Position.X - centro.X, 0, raiz.Position.Z - centro.Z).Magnitude
			protegido = d <= radio
		end
		if not estado:GetAttribute("CampamentoEncendido") then
			luzTxt.Text = "🪵 Hoguera sin encender"
			luzTxt.TextColor3 = T.textoSuave
		elseif combustible <= 0 then
			luzTxt.Text = "🌑 ¡El fuego está apagado!"
			luzTxt.TextColor3 = T.rojo
		elseif protegido then
			luzTxt.Text = "✨ A salvo junto al fuego"
			luzTxt.TextColor3 = T.verde
		elseif fase == "Dia" or fase == "Final" then
			luzTxt.Text = "☀️ De día la Bruma se esconde"
			luzTxt.TextColor3 = T.textoSuave
		else
			luzTxt.Text = "⚠️ Estás fuera de la luz"
			luzTxt.TextColor3 = rgb(255, 170, 90)
		end

		local lia = CollectionService:GetTagged("Lia")[1]
		local cabeza = lia and lia:FindFirstChild("Head") :: BasePart?
		if cabeza and raiz then
			marcador.Adornee = cabeza
			marcador.Enabled = (cabeza.Position - raiz.Position).Magnitude > 45
		else
			marcador.Enabled = false
		end
	end

	local function conectarPersonaje(personaje: Model)
		local hum = personaje:WaitForChild("Humanoid", 10) :: Humanoid
		if not hum then
			return
		end
		local anterior = hum.Health
		local function vida()
			barraVida.poner(hum.Health / hum.MaxHealth, string.format("Vida  %d", math.ceil(hum.Health)))
			if hum.Health < anterior - 0.5 then
				dano.BackgroundTransparency = 0.75
				TweenService:Create(dano, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
			end
			anterior = hum.Health
		end
		vida()
		hum.HealthChanged:Connect(vida)
	end

	estado.AttributeChanged:Connect(refrescarEstado)
	jugador.AttributeChanged:Connect(refrescarJugador)
	jugador.CharacterAdded:Connect(conectarPersonaje)
	if jugador.Character then
		task.spawn(conectarPersonaje, jugador.Character)
	end
	refrescarEstado()
	refrescarJugador()
	task.spawn(function()
		while true do
			refrescarLuz()
			task.wait(0.25)
		end
	end)

	return hud
end

return Hud
