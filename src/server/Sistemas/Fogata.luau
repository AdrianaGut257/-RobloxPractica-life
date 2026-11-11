local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)
local Inventario = require(script.Parent.Inventario)
local Ruta = require(script.Parent.Parent.Mundo.Ruta)
local Util = require(script.Parent.Parent.Mundo.Util)

local Fogata = {}

local CFG = Config.FUEGO
local rgb = Color3.fromRGB
local campamentos = {}
local centro = Vector3.zero
local radio = 0
local avisoPoco = false
local aparicion: SpawnLocation

Fogata.posicionLia = nil :: (() -> Vector3?)?

local function etapaActual(): number
	return Estado.get("Etapa") or 1
end

local function nivel()
	return CFG.NIVELES[Estado.get("NivelFuego") or 1]
end

local function arde(): boolean
	return Estado.get("CampamentoEncendido") == true and (Estado.get("Combustible") or 0) > 0
end

local function aspecto(c, encendida: boolean, proporcion: number)
	c.llamas.Enabled = encendida
	c.llamas.Size = 3 + 6 * proporcion
	c.chispas.Enabled = encendida
	c.humo.Enabled = encendida
	c.luz.Enabled = encendida
	c.luz.Range = math.clamp(radio + 10, 14, 60)
	c.luz.Brightness = 1.5 + 2 * proporcion
	c.brasas.Material = if encendida then Enum.Material.Neon else Enum.Material.SmoothPlastic
	c.brasas.Color = if encendida then rgb(255, 120, 40) else rgb(60, 40, 30)
end

local function actualizar()
	local c = campamentos[etapaActual()]
	local combustible = Estado.get("Combustible") or 0
	local proporcion = math.clamp(combustible / nivel().maximo, 0, 1)
	local encendida = arde()
	radio = if encendida then nivel().radio * (0.45 + 0.55 * proporcion) else 0
	Estado.set("RadioLuz", math.floor(radio * 10) / 10)
	if c then
		aspecto(c, encendida, proporcion)
	end
end

function Fogata.estaProtegido(pos: Vector3): boolean
	return radio > 0 and Util.dist2D(pos, centro) <= radio and math.abs(pos.Y - centro.Y) < 25
end

function Fogata.radio(): number
	return radio
end

function Fogata.centro(): Vector3
	return centro
end

function Fogata.arde(): boolean
	return arde()
end

function Fogata.puntoBorde(desde: Vector3, margen: number): Vector3
	local dir = Vector3.new(desde.X - centro.X, 0, desde.Z - centro.Z)
	if dir.Magnitude < 0.1 then
		dir = Vector3.new(0, 0, 1)
	end
	local p = centro + dir.Unit * (radio + margen)
	return Vector3.new(p.X, desde.Y, p.Z)
end

function Fogata.campamento(etapa: number)
	return campamentos[etapa]
end

function Fogata.actual()
	return campamentos[etapaActual()]
end

function Fogata.puntoSeguro(): Vector3
	if Estado.get("CampamentoEncendido") then
		local c = campamentos[etapaActual()]
		if c then
			return c.aparicion.Position + Vector3.new(0, 3, 0)
		end
	end
	if etapaActual() == 1 then
		return Ruta.SITIOS.inicio + Vector3.new(0, 3, 0)
	end
	local c = campamentos[etapaActual()]
	return (if c then c.aparicion.Position else Ruta.SITIOS.inicio) + Vector3.new(0, 3, 0)
end

local function moverAparicion()
	aparicion.CFrame = CFrame.new(Fogata.puntoSeguro() - Vector3.new(0, 2.5, 0))
end

function Fogata.mejorar(nuevoNivel: number)
	Estado.set("NivelFuego", nuevoNivel)
	local datos = CFG.NIVELES[nuevoNivel]
	Estado.set("CombustibleMax", datos.maximo)
	Estado.set("Combustible", math.min(datos.maximo, (Estado.get("Combustible") or 0) + 30))
	for _, c in campamentos do
		for _, d in c.modelo:GetChildren() do
			if (d.Name == "Nivel2" and nuevoNivel >= 2) or (d.Name == "Nivel3" and nuevoNivel >= 3) then
				(d :: BasePart).Transparency = 0
			end
		end
	end
	actualizar()
end

local function sePuedeEncender(etapa: number): boolean
	local actual = etapaActual()
	if etapa == actual then
		return not Estado.get("CampamentoEncendido")
	end
	return etapa == actual + 1 and Estado.get("Paso_" .. actual) == true
end

local function refrescarBotones()
	local actual = etapaActual()
	for etapa, c in campamentos do
		local p: ProximityPrompt = c.boton
		if etapa == actual and Estado.get("CampamentoEncendido") then
			p.Enabled = true
			p.ActionText = "Echar leña"
		elseif sePuedeEncender(etapa) then
			p.Enabled = true
			p.ActionText = "Encender hoguera (🪵 " .. CFG.LENA_ENCENDER .. ")"
		else
			p.Enabled = false
		end
	end
end

local function echarLena(jugador: Player)
	local lena = Inventario.cantidad(jugador, "Lena")
	if lena <= 0 then
		Estado.notificar(jugador, "No llevas leña. Recoge ramas del suelo o tala árboles.")
		return
	end
	local combustible = Estado.get("Combustible") or 0
	local maximo = nivel().maximo
	if combustible >= maximo - 1 then
		Estado.notificar(jugador, "🔥 El fuego ya está a tope.")
		return
	end
	local caben = math.ceil((maximo - combustible) / CFG.POR_LENA)
	local usar = math.min(lena, caben)
	local estabaApagada = combustible <= 0
	Inventario.quitar(jugador, "Lena", usar)
	Estado.set("Combustible", math.min(maximo, combustible + usar * CFG.POR_LENA))
	actualizar()
	if estabaApagada then
		Estado.notificar(nil, "🔥 " .. jugador.DisplayName .. " ha vuelto a encender el fuego.", rgb(255, 190, 100))
	else
		Estado.notificar(jugador, "🔥 Echaste " .. usar .. " de leña al fuego.", rgb(255, 190, 100))
	end
end

local function encender(jugador: Player, etapa: number)
	if not sePuedeEncender(etapa) then
		return
	end
	if Fogata.posicionLia then
		local pos = Fogata.posicionLia()
		local c = campamentos[etapa]
		if pos and Util.dist2D(pos, c.fuego.Position) > CFG.DISTANCIA_LIA then
			Estado.notificar(jugador, "¿Y Lía? No podéis acampar sin ella. Espera a que llegue.", rgb(255, 200, 120))
			return
		end
	end
	if Inventario.cantidad(jugador, "Lena") < CFG.LENA_ENCENDER then
		Estado.notificar(jugador, "Necesitas 🪵 " .. CFG.LENA_ENCENDER .. " de leña para encender la hoguera.")
		return
	end
	Inventario.quitar(jugador, "Lena", CFG.LENA_ENCENDER)

	local anterior = etapaActual()
	if etapa ~= anterior and campamentos[anterior] then
		aspecto(campamentos[anterior], false, 0)
	end
	Estado.set("Etapa", etapa)
	Estado.set("CampamentoEncendido", true)
	Estado.set("Combustible", math.min(nivel().maximo, CFG.COMBUSTIBLE_INICIAL))
	centro = campamentos[etapa].fuego.Position
	Estado.set("CentroLuz", centro)
	avisoPoco = false
	actualizar()
	moverAparicion()
	refrescarBotones()
	Estado.notificar(nil, "⛺ " .. jugador.DisplayName .. " ha encendido la hoguera. ¡Campamento montado!", rgb(255, 200, 120))
	Estado.emitir("CampamentoEncendido", etapa, jugador)
end

function Fogata.iniciar()
	for _, modelo in CollectionService:GetTagged("Campamento") do
		local etapa = modelo:GetAttribute("Etapa")
		local fuego = modelo:FindFirstChild("Fuego") :: BasePart
		if not etapa or not fuego then
			continue
		end
		local c = {
			etapa = etapa,
			modelo = modelo,
			fuego = fuego,
			llamas = fuego:FindFirstChildOfClass("Fire"),
			luz = fuego:FindFirstChildOfClass("PointLight"),
			chispas = fuego:FindFirstChild("Chispas"),
			humo = fuego:FindFirstChild("Humo"),
			brasas = modelo:FindFirstChild("Brasas"),
			asiento = modelo:FindFirstChild("Asiento"),
			mesa = modelo:FindFirstChild("Mesa"),
			aparicion = modelo:FindFirstChild("Aparicion"),
		}
		local boton = Util.prompt(fuego, "Encender hoguera", "🔥 Hoguera", 0, 12)
		boton.KeyboardKeyCode = Enum.KeyCode.E
		boton.Triggered:Connect(function(jugador)
			if etapa == etapaActual() and Estado.get("CampamentoEncendido") then
				echarLena(jugador)
			else
				encender(jugador, etapa)
			end
		end)
		c.boton = boton
		campamentos[etapa] = c
		aspecto(c, false, 0)
	end
	if not campamentos[1] then
		warn("[Fogata] No hay campamentos en el mapa (etiqueta 'Campamento')")
		return
	end

	aparicion = Instance.new("SpawnLocation")
	aparicion.Name = "Aparicion"
	aparicion.Anchored = true
	aparicion.CanCollide = false
	aparicion.CanQuery = false
	aparicion.Transparency = 1
	aparicion.Size = Vector3.new(6, 1, 6)
	aparicion.Neutral = true
	aparicion.Duration = 0
	aparicion.Parent = workspace

	Inventario.junto_al_fuego = Fogata.estaProtegido

	Estado.set("Etapa", 1)
	Estado.set("CampamentoEncendido", false)
	Estado.set("NivelFuego", 1)
	Estado.set("CombustibleMax", CFG.NIVELES[1].maximo)
	Estado.set("Combustible", 0)
	centro = campamentos[1].fuego.Position
	Estado.set("CentroLuz", centro)
	moverAparicion()
	actualizar()
	refrescarBotones()

	Estado.obj.AttributeChanged:Connect(function(nombre)
		if string.sub(nombre, 1, 5) == "Paso_" then
			refrescarBotones()
		end
	end)

	task.spawn(function()
		local PASO = 0.5
		while true do
			task.wait(PASO)
			local fase = Estado.get("Fase")
			if fase == "Final" or not Estado.get("CampamentoEncendido") then
				continue
			end
			local gasto = if Estado.esNoche() then CFG.GASTO_NOCHE else CFG.GASTO_DIA
			local antes = Estado.get("Combustible") or 0
			local ahora = math.max(0, antes - gasto * PASO)
			Estado.set("Combustible", ahora)
			local maximo = nivel().maximo
			if ahora < maximo * 0.25 and not avisoPoco and ahora > 0 then
				avisoPoco = true
				Estado.notificar(nil, "⚠️ ¡El fuego se está apagando! Traed leña.", rgb(255, 170, 80))
				Estado.emitir("FuegoBajo")
			elseif ahora > maximo * 0.35 then
				avisoPoco = false
			end
			if antes > 0 and ahora <= 0 then
				Estado.notificar(nil, "🌑 ¡El fuego se ha apagado! Ya nada os protege.", rgb(255, 90, 90))
				Estado.emitir("FuegoApagado")
			end
			actualizar()
		end
	end)
end

return Fogata
