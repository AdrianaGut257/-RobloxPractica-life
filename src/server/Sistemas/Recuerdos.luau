local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Estado = require(script.Parent.Estado)
local Fogata = require(script.Parent.Fogata)
local Inventario = require(script.Parent.Inventario)
local Lia = require(script.Parent.Lia)
local Util = require(script.Parent.Parent.Mundo.Util)

local Recuerdos = {}

local rgb = Color3.fromRGB
local SEGUNDOS_POR_LINEA = 4.6
local charlando = false

local function iniciarPaginas()
	for _, pagina in CollectionService:GetTagged("Pagina") do
		local n = pagina:GetAttribute("Numero")
		local datos = Historia.PAGINAS[n]
		if not datos then
			continue
		end
		local prompt = Util.prompt(pagina, "Leer", "📜 " .. datos.titulo, 0, 10)
		prompt.Triggered:Connect(function(jugador)
			if Estado.get("Pagina_" .. n) then
				Estado.remotos.MostrarPagina:FireClient(jugador, n)
				return
			end
			Estado.set("Pagina_" .. n, true)
			Estado.remotos.MostrarPagina:FireClient(jugador, n)
			Estado.sumar("PaginasEncontradas", 1)
			local brillo = pagina:FindFirstChildOfClass("Sparkles")
			if brillo then
				brillo:Destroy()
			end
			for _, otro in Players:GetPlayers() do
				if otro ~= jugador then
					Estado.notificar(otro, "📜 " .. jugador.DisplayName .. " ha encontrado una nota: " .. datos.titulo .. "  (J para leerla)", rgb(255, 230, 170))
				end
			end
		end)
	end
end

local function iniciarTesoros()
	for _, tesoro in CollectionService:GetTagged("Tesoro") do
		local n = tesoro:GetAttribute("Numero")
		local datos = Historia.TESOROS[n]
		if not datos then
			continue
		end
		local prompt = Util.prompt(tesoro, "Coger", "✨ Algo brilla", 0, 9)
		prompt.Triggered:Connect(function(jugador)
			if not tesoro.Parent or Estado.get("Tesoro_" .. n) then
				return
			end
			Estado.set("Tesoro_" .. n, true)
			Estado.sumar("TesorosEncontrados", 1)
			tesoro:Destroy()
			Lia.tesoro(n)
			Estado.remotos.Tesoro:FireAllClients(n, jugador.DisplayName)
		end)
	end
end

local function iniciarMiradores()
	for _, mirador in CollectionService:GetTagged("Mirador") do
		local n = mirador:GetAttribute("Numero")
		local datos = Historia.MIRADORES[n]
		local asiento = mirador:FindFirstChild("Asiento") :: Seat?
		if not datos or not asiento then
			continue
		end
		local duracion = #datos.lineas * SEGUNDOS_POR_LINEA + 3
		local prompt = Util.prompt(asiento, "Sentarse a mirar", "🪑 " .. datos.titulo, 0, 9)
		prompt.Triggered:Connect(function(jugador)
			local hum = Inventario.humanoide(jugador)
			if not hum then
				return
			end
			pcall(function()
				asiento:Sit(hum)
			end)
			Estado.remotos.Mirador:FireClient(jugador, n, mirador:GetAttribute("CamPos"), mirador:GetAttribute("CamMira"))
			Lia.sentarJunto(asiento.CFrame, duracion)
			if not Estado.get("Mirador_" .. n) then
				Estado.set("Mirador_" .. n, true)
				Estado.sumar("MiradoresVistos", 1)
				Lia.cambiarAnimo(Config.LIA.SUBE_MIRADOR)
				task.delay(duracion, function()
					Estado.notificar(nil, "🖍️ Lía ha hecho un dibujo nuevo en el cuaderno: «" .. datos.titulo .. "»  (J)", rgb(200, 220, 255))
				end)
			end
		end)
	end
end

local botonesCharla = {}

local function refrescarCharlas()
	local actual = Estado.get("Etapa") or 1
	for etapa, boton in botonesCharla do
		boton.Enabled = etapa == actual
			and not charlando
			and Estado.get("CampamentoEncendido") == true
			and Estado.esNoche()
			and not Estado.get("Charla_" .. etapa)
	end
end

local function charlar(jugador: Player, etapa: number)
	local lineas = Historia.CHARLAS[etapa]
	if charlando or not lineas or Estado.get("Charla_" .. etapa) then
		return
	end
	local posLia = Lia.posicion()
	local centro = Fogata.centro()
	if not posLia or Util.dist2D(posLia, centro) > 30 then
		Estado.notificar(jugador, "Lía tiene que estar junto al fuego para charlar.")
		return
	end
	charlando = true
	Estado.set("Charla_" .. etapa, true)
	refrescarCharlas()
	local duracion = #lineas * SEGUNDOS_POR_LINEA + 1
	Lia.sentarEnFuego(duracion)
	for _, j in Players:GetPlayers() do
		local r = Inventario.raiz(j)
		if r and Util.dist2D(r.Position, centro) < 60 then
			Estado.remotos.Subtitulos:FireClient(j, lineas, jugador.DisplayName)
		end
	end
	task.spawn(function()
		for _, linea in lineas do
			if linea.quien == "Lia" then
				Lia.decir(linea.texto, SEGUNDOS_POR_LINEA - 0.3)
			end
			task.wait(SEGUNDOS_POR_LINEA)
		end
		Lia.cambiarAnimo(Config.LIA.SUBE_CHARLA)
		charlando = false
		refrescarCharlas()
	end)
end

local function iniciarCharlas()
	for etapa = 1, #Config.ETAPAS do
		local c = Fogata.campamento(etapa)
		if c and c.asiento then
			local boton = Util.prompt(c.asiento, "Charlar con Lía", "🔥 Junto al fuego", 0, 12)
			boton.KeyboardKeyCode = Enum.KeyCode.G
			boton.Enabled = false
			boton.Triggered:Connect(function(jugador)
				charlar(jugador, etapa)
			end)
			botonesCharla[etapa] = boton
		end
	end
	Estado.obj.AttributeChanged:Connect(function(nombre)
		if nombre == "Fase" or nombre == "Etapa" or nombre == "CampamentoEncendido" then
			refrescarCharlas()
		end
	end)
end

local function iniciarArmarios()
	for _, armario in CollectionService:GetTagged("Armario") do
		local cuerpo = armario.PrimaryPart
		if not cuerpo then
			continue
		end
		local prompt = Util.prompt(cuerpo, "Coger un abrigo", "🧥 Armario del guarda", 0.5, 9)
		prompt.Triggered:Connect(function(jugador)
			if jugador:GetAttribute("TieneAbrigo") then
				Estado.notificar(jugador, "Ya llevas un abrigo puesto.")
				return
			end
			jugador:SetAttribute("TieneAbrigo", true)
			Inventario.ponerAbrigo(jugador)
			Estado.notificar(jugador, "🧥 Te has puesto un abrigo. Así aguantarás mucho mejor el frío del Paso Nevado.", rgb(150, 230, 120))
		end)
	end
end

function Recuerdos.iniciar()
	Estado.set("PaginasEncontradas", 0)
	Estado.set("TesorosEncontrados", 0)
	Estado.set("MiradoresVistos", 0)
	iniciarPaginas()
	iniciarTesoros()
	iniciarMiradores()
	iniciarCharlas()
	iniciarArmarios()
end

return Recuerdos
