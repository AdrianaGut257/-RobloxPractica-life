local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Interfaz = require(script.Parent.Interfaz)

local Ventanas = {}

local T = Interfaz.TEMA
local crear = Interfaz.crear
local rgb = Color3.fromRGB

local function botonCerrar(padre: Instance, color: Color3)
	return crear("TextButton", {
		Text = "✕",
		Font = T.fuente,
		TextSize = 22,
		TextColor3 = color,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 6),
		Size = UDim2.fromOffset(36, 36),
		Modal = true,
		ZIndex = 3,
		Parent = padre,
	})
end

local function hex(c: Color3): string
	return string.format("#%02x%02x%02x", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

function Ventanas.crear(gui: ScreenGui, pantalla: ScreenGui, estado: Instance, remotos: Folder)
	local jugador = Players.LocalPlayer
	local v = {}

	local cuaderno = crear("CanvasGroup", {
		Name = "Cuaderno",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.53),
		Size = UDim2.fromOffset(660, 520),
		BackgroundColor3 = T.pergamino,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 5,
		Parent = gui,
	}, {
		Interfaz.esquinas(14),
		Interfaz.contorno(rgb(150, 108, 60), 3, 0),
	})
	crear("Frame", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 1, -20),
		BackgroundTransparency = 1,
		Parent = cuaderno,
	}, { Interfaz.esquinas(10), Interfaz.contorno(rgb(190, 150, 95), 1, 0.2) })
	local cerrarCuaderno = botonCerrar(cuaderno, T.tinta)

	local pestanas = crear("Frame", {
		Position = UDim2.fromOffset(24, 18),
		Size = UDim2.new(1, -90, 0, 34),
		BackgroundTransparency = 1,
		Parent = cuaderno,
	}, { crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }) })
	local botonesPestana = {}
	for i, info in { { "Notas", "📜 Notas" }, { "Dibujos", "🖍️ Dibujos de Lía" }, { "Tesoros", "🎁 Tesoros" } } do
		botonesPestana[info[1]] = crear("TextButton", {
			Text = info[2],
			Font = T.fuente,
			TextSize = 15,
			TextColor3 = T.tinta,
			BackgroundColor3 = rgb(225, 205, 165),
			Size = UDim2.fromOffset(if i == 2 then 190 else 130, 32),
			LayoutOrder = i,
			Parent = pestanas,
		}, { Interfaz.esquinas(8) })
	end

	local contenido = crear("Frame", {
		Position = UDim2.fromOffset(20, 60),
		Size = UDim2.new(1, -40, 1, -76),
		BackgroundTransparency = 1,
		Parent = cuaderno,
	})

	local hoja = crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = contenido })
	local tituloHoja = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 32,
		TextColor3 = T.tinta,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 38),
		Position = UDim2.fromOffset(0, 4),
		Text = "",
		Parent = hoja,
	})
	local autorHoja = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 18,
		TextColor3 = rgb(130, 90, 50),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.fromOffset(0, 42),
		Text = "",
		Parent = hoja,
	})
	crear("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 70),
		Size = UDim2.new(0.6, 0, 0, 1),
		BackgroundColor3 = rgb(150, 108, 60),
		BorderSizePixel = 0,
		Parent = hoja,
	})
	local cuerpo = crear("ScrollingFrame", {
		Position = UDim2.fromOffset(14, 80),
		Size = UDim2.new(1, -28, 1, -130),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = rgb(150, 108, 60),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = hoja,
	})
	local textoHoja = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 21,
		TextColor3 = T.tinta,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -10, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		Parent = cuerpo,
	})
	local pieHoja = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 17,
		TextColor3 = rgb(130, 90, 50),
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(1, -140, 0, 28),
		Text = "",
		Parent = hoja,
	})
	local function flecha(texto: string, x: number, ancla: number)
		return crear("TextButton", {
			Text = texto,
			Font = T.fuente,
			TextSize = 20,
			TextColor3 = T.tinta,
			BackgroundColor3 = rgb(225, 205, 165),
			AnchorPoint = Vector2.new(ancla, 1),
			Position = UDim2.new(x, 0, 1, -6),
			Size = UDim2.fromOffset(44, 32),
			Parent = hoja,
		}, { Interfaz.esquinas(8) })
	end
	local anterior = flecha("◀", 0, 0)
	local siguiente = flecha("▶", 1, 1)

	local tesoros = crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = contenido })
	local rejilla = crear("Frame", {
		Size = UDim2.new(1, 0, 1, -80),
		BackgroundTransparency = 1,
		Parent = tesoros,
	}, {
		crear("UIGridLayout", {
			CellSize = UDim2.fromOffset(112, 100),
			CellPadding = UDim2.fromOffset(10, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local descripcionTesoro = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 20,
		TextColor3 = T.tinta,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -4),
		Size = UDim2.new(1, 0, 0, 70),
		Text = "",
		Parent = tesoros,
	})
	local celdas = {}
	for n, datos in Historia.TESOROS do
		local celda = crear("TextButton", {
			Text = "",
			BackgroundColor3 = rgb(230, 214, 178),
			LayoutOrder = n,
			AutoButtonColor = true,
			Parent = rejilla,
		}, { Interfaz.esquinas(10), Interfaz.contorno(rgb(170, 130, 80), 1, 0.4) })
		local icono = Interfaz.texto({
			Text = "?",
			TextSize = 34,
			TextColor3 = T.tinta,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 56),
			Position = UDim2.fromOffset(0, 6),
			Parent = celda,
		})
		local nombre = Interfaz.texto({
			Font = T.fuenteMedia,
			Text = "",
			TextSize = 12,
			TextColor3 = T.tinta,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, -8, 0, 32),
			Position = UDim2.fromOffset(4, 62),
			Parent = celda,
		})
		celda.Activated:Connect(function()
			if estado:GetAttribute("Tesoro_" .. n) then
				descripcionTesoro.Text = datos.icono .. "  " .. datos.nombre .. ": " .. datos.descripcion
			else
				descripcionTesoro.Text = "Todavía no lo habéis encontrado. Busca cosas que brillan por el camino."
			end
		end)
		celdas[n] = { icono = icono, nombre = nombre }
	end

	local pestana = "Notas"
	local actual: { [string]: number? } = { Notas = nil, Dibujos = nil }
	local pedida: number? = nil

	local function encontrados(prefijo: string, total: number)
		local lista = {}
		for n = 1, total do
			if estado:GetAttribute(prefijo .. n) then
				table.insert(lista, n)
			end
		end
		return lista
	end

	local function listaDePestana()
		if pestana == "Notas" then
			return encontrados("Pagina_", Historia.TOTAL_PAGINAS)
		end
		return encontrados("Mirador_", Historia.TOTAL_MIRADORES)
	end

	local function pintarHoja()
		local lista = listaDePestana()
		if pestana == "Notas" and pedida and not table.find(lista, pedida) then
			table.insert(lista, pedida)
			table.sort(lista)
		end
		local esDibujo = pestana == "Dibujos"
		textoHoja.Font = if esDibujo then T.fuenteMano else T.fuenteHistoria
		textoHoja.TextSize = if esDibujo then 26 else 21
		if #lista == 0 then
			tituloHoja.Text = if esDibujo then "Dibujos de Lía" else "Tu cuaderno"
			autorHoja.Text = ""
			textoHoja.Text = if esDibujo
				then "Lía todavía no ha dibujado nada.\n\nBuscad bancos con vistas (🪑 brillan un poco) y sentaos un rato: a Lía le encanta dibujar lo que ve."
				else "Todavía no has encontrado ninguna nota.\n\nBusca papeles que brillan por el camino: la abuela Rosa los dejó para vosotros."
			pieHoja.Text = ""
			anterior.Visible = false
			siguiente.Visible = false
			return
		end
		local n = actual[pestana]
		if not n or not table.find(lista, n) then
			n = lista[#lista]
			actual[pestana] = n
		end
		local indice = table.find(lista, n) or 1
		if esDibujo then
			local datos = Historia.MIRADORES[n :: number]
			tituloHoja.Text = "🖍️ " .. datos.titulo
			autorHoja.Text = "Dibujo de Lía"
			textoHoja.Text = "«" .. datos.dibujo .. "»\n\n" .. table.concat(datos.lineas, "\n")
			pieHoja.Text = string.format("Dibujo %d de %d", indice, Historia.TOTAL_MIRADORES)
		else
			local datos = Historia.PAGINAS[n :: number]
			tituloHoja.Text = datos.titulo
			autorHoja.Text = datos.autor
			textoHoja.Text = datos.texto
			pieHoja.Text = string.format("Nota %d  ·  %d de %d encontradas", n, #lista, Historia.TOTAL_PAGINAS)
		end
		cuerpo.CanvasPosition = Vector2.zero
		anterior.Visible = indice > 1
		siguiente.Visible = indice < #lista
	end

	local function pintarTesoros()
		for n, datos in Historia.TESOROS do
			local c = celdas[n]
			if estado:GetAttribute("Tesoro_" .. n) then
				c.icono.Text = datos.icono
				c.nombre.Text = datos.nombre
			else
				c.icono.Text = "?"
				c.nombre.Text = ""
			end
		end
		descripcionTesoro.Text = string.format(
			"La colección de Lía: %d de %d tesoros. Toca uno para ver qué es.",
			estado:GetAttribute("TesorosEncontrados") or 0,
			Historia.TOTAL_TESOROS
		)
	end

	local function pintarCuaderno()
		for nombre, boton in botonesPestana do
			boton.BackgroundColor3 = if nombre == pestana then rgb(196, 160, 104) else rgb(225, 205, 165)
		end
		hoja.Visible = pestana ~= "Tesoros"
		tesoros.Visible = pestana == "Tesoros"
		if pestana == "Tesoros" then
			pintarTesoros()
		else
			pintarHoja()
		end
	end

	for nombre, boton in botonesPestana do
		boton.Activated:Connect(function()
			pestana = nombre
			pintarCuaderno()
		end)
	end
	local function moverHoja(paso: number)
		local lista = listaDePestana()
		local indice = table.find(lista, actual[pestana]) or #lista
		local nuevo = lista[math.clamp(indice + paso, 1, #lista)]
		if nuevo then
			actual[pestana] = nuevo
			pintarHoja()
		end
	end
	anterior.Activated:Connect(function()
		moverHoja(-1)
	end)
	siguiente.Activated:Connect(function()
		moverHoja(1)
	end)

	local taller = crear("CanvasGroup", {
		Name = "Taller",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.53),
		Size = UDim2.fromOffset(640, 520),
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.05,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 5,
		Parent = gui,
	}, { Interfaz.esquinas(14), Interfaz.contorno(T.oro, 2, 0.3) })
	Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 32,
		TextColor3 = T.oro,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -80, 0, 40),
		Position = UDim2.fromOffset(40, 12),
		Text = "🔨 Mesa del campamento",
		Parent = taller,
	})
	local llevasTxt = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 16,
		TextColor3 = T.textoSuave,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -40, 0, 22),
		Position = UDim2.fromOffset(20, 54),
		Text = "",
		Parent = taller,
	})
	local lista = crear("ScrollingFrame", {
		Position = UDim2.fromOffset(18, 86),
		Size = UDim2.new(1, -36, 1, -100),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = T.oro,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = taller,
	}, { crear("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local cerrarTaller = botonCerrar(taller, T.texto)

	local tarjetas = {}
	for i, receta in Config.RECETAS do
		local tarjeta = crear("Frame", {
			Size = UDim2.new(1, -8, 0, 86),
			BackgroundColor3 = rgb(36, 40, 34),
			BackgroundTransparency = 0.1,
			LayoutOrder = i,
			Parent = lista,
		}, { Interfaz.esquinas(10), Interfaz.contorno(T.borde, 1, 0.75) })
		Interfaz.texto({
			Text = receta.icono,
			TextSize = 34,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromOffset(56, 86),
			Parent = tarjeta,
		})
		Interfaz.texto({
			Text = receta.nombre,
			TextSize = 18,
			Size = UDim2.new(1, -220, 0, 22),
			Position = UDim2.fromOffset(60, 8),
			Parent = tarjeta,
		})
		Interfaz.texto({
			Text = receta.descripcion,
			Font = T.fuenteMedia,
			TextSize = 13,
			TextColor3 = T.textoSuave,
			TextWrapped = true,
			Size = UDim2.new(1, -220, 0, 32),
			Position = UDim2.fromOffset(60, 30),
			Parent = tarjeta,
		})
		local coste = Interfaz.texto({
			Font = T.fuenteMedia,
			TextSize = 15,
			RichText = true,
			Size = UDim2.new(1, -220, 0, 20),
			Position = UDim2.fromOffset(60, 62),
			Text = "",
			Parent = tarjeta,
		})
		local boton = Interfaz.boton({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(140, 40),
			TextWrapped = true,
			Text = "Fabricar",
			Parent = tarjeta,
		})
		boton.Activated:Connect(function()
			remotos.Fabricar:FireServer(receta.id)
		end)
		tarjetas[receta.id] = { receta = receta, coste = coste, boton = boton }
	end

	local function pintarTaller()
		local partes = {}
		for _, recurso in Config.RECURSOS_MOCHILA do
			table.insert(partes, Config.ICONOS_RECURSOS[recurso] .. " " .. (jugador:GetAttribute(recurso) or 0))
		end
		llevasTxt.Text = "Llevas:   " .. table.concat(partes, "    ")

		for _, t in tarjetas do
			local receta = t.receta
			local trozos = {}
			local alcanza = true
			for _, recurso in Config.RECURSOS_MOCHILA do
				local n = receta.coste[recurso]
				if n then
					local tengo = jugador:GetAttribute(recurso) or 0
					if tengo < n then
						alcanza = false
					end
					local color = if tengo >= n then T.verde else T.rojo
					table.insert(trozos, string.format('<font color="%s">%s %d</font>', hex(color), Config.ICONOS_RECURSOS[recurso], n))
				end
			end
			t.coste.Text = "Cuesta:  " .. table.concat(trozos, "   ")

			local desbloqueada, motivo = Config.recetaDesbloqueada(receta, estado)
			if receta.unica and jugador:GetAttribute(receta.unica) then
				t.boton.Text = "✔ Ya lo tienes"
				t.boton.TextSize = 15
				t.boton.BackgroundColor3 = rgb(50, 80, 50)
				t.boton.Active = false
			elseif not desbloqueada then
				t.boton.Text = "🔒 " .. (motivo or "Bloqueado")
				t.boton.TextSize = 12
				t.boton.BackgroundColor3 = rgb(55, 50, 50)
				t.boton.Active = false
			else
				t.boton.Text = "Fabricar"
				t.boton.TextSize = 15
				t.boton.BackgroundColor3 = if alcanza then rgb(120, 80, 30) else rgb(70, 52, 34)
				t.boton.Active = true
			end
		end
	end

	local victoria = crear("CanvasGroup", {
		Name = "Final",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(12, 10, 8),
		BackgroundTransparency = 0.2,
		GroupTransparency = 1,
		Visible = false,
		Parent = pantalla,
	})
	local columna = crear("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.8, 0, 0.85, 0),
		BackgroundTransparency = 1,
		Parent = victoria,
	}, {
		crear("UIListLayout", {
			Padding = UDim.new(0, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		crear("UISizeConstraint", { MaxSize = Vector2.new(780, 640) }),
	})
	Interfaz.texto({
		Font = T.fuenteHistoria,
		TextScaled = true,
		TextColor3 = T.oro,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 76),
		Text = "El viaje ha terminado",
		LayoutOrder = 1,
		Parent = columna,
	})
	Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 23,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = Historia.FINAL,
		LayoutOrder = 2,
		Parent = columna,
	})
	local statsTxt = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 17,
		TextColor3 = T.textoSuave,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 44),
		Text = "",
		LayoutOrder = 3,
		Parent = columna,
	})
	local botones = crear("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
		LayoutOrder = 4,
		Parent = columna,
	}, {
		crear("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 16),
		}),
	})
	local seguir = Interfaz.boton({ Text = "Seguir mirando el mar", Size = UDim2.fromOffset(230, 44), Modal = true, Parent = botones })
	local otraVez = Interfaz.boton({ Text = "🔁 Empezar otro viaje", Size = UDim2.fromOffset(230, 44), Parent = botones })

	local function cerrarTodo()
		if cuaderno.Visible then
			Interfaz.fundido(cuaderno, false)
		end
		if taller.Visible then
			Interfaz.fundido(taller, false)
		end
	end
	v.cerrarTodo = cerrarTodo

	function v.mostrarPagina(n: number)
		cerrarTodo()
		pestana = "Notas"
		actual.Notas = n
		pedida = n
		pintarCuaderno()
		Interfaz.fundido(cuaderno, true)
	end

	function v.mostrarDibujos()
		cerrarTodo()
		pestana = "Dibujos"
		actual.Dibujos = nil
		pintarCuaderno()
		Interfaz.fundido(cuaderno, true)
	end

	function v.alternarCuaderno()
		if cuaderno.Visible and cuaderno.GroupTransparency < 0.5 then
			Interfaz.fundido(cuaderno, false)
		else
			cerrarTodo()
			pintarCuaderno()
			Interfaz.fundido(cuaderno, true)
		end
	end

	function v.abrirTaller()
		cerrarTodo()
		pintarTaller()
		Interfaz.fundido(taller, true)
	end

	function v.final()
		cerrarTodo()
		statsTxt.Text = string.format(
			"Noches sobrevividas: %d   ·   Notas: %d/%d   ·   Tesoros de Lía: %d/%d   ·   Dibujos: %d/%d",
			estado:GetAttribute("NochesSobrevividas") or 0,
			estado:GetAttribute("PaginasEncontradas") or 0,
			Historia.TOTAL_PAGINAS,
			estado:GetAttribute("TesorosEncontrados") or 0,
			Historia.TOTAL_TESOROS,
			estado:GetAttribute("MiradoresVistos") or 0,
			Historia.TOTAL_MIRADORES
		)
		Interfaz.fundido(victoria, true, 2)
	end

	cerrarCuaderno.Activated:Connect(function()
		Interfaz.fundido(cuaderno, false)
	end)
	cerrarTaller.Activated:Connect(function()
		Interfaz.fundido(taller, false)
	end)
	seguir.Activated:Connect(function()
		Interfaz.fundido(victoria, false)
	end)
	otraVez.Activated:Connect(function()
		otraVez.Text = "Preparando el viaje..."
		remotos.NuevaPartida:FireServer()
	end)

	jugador.AttributeChanged:Connect(function()
		if taller.Visible then
			pintarTaller()
		end
	end)
	estado.AttributeChanged:Connect(function(nombre)
		if taller.Visible and (nombre == "Etapa" or nombre == "NivelFuego" or nombre == "NochesSobrevividas") then
			pintarTaller()
		end
		if cuaderno.Visible and (string.sub(nombre, 1, 7) == "Pagina_" or string.sub(nombre, 1, 8) == "Mirador_" or string.sub(nombre, 1, 7) == "Tesoro_") then
			pintarCuaderno()
		end
	end)

	task.spawn(function()
		while true do
			task.wait(0.5)
			if taller.Visible and taller.GroupTransparency < 0.5 then
				local personaje = jugador.Character
				local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
				local centro = estado:GetAttribute("CentroLuz")
				if raiz and typeof(centro) == "Vector3" and (raiz.Position - centro).Magnitude > 40 then
					Interfaz.fundido(taller, false)
				end
			end
		end
	end)

	return v
end

return Ventanas
