local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Armas = require(script.Parent.Armas)
local Estado = require(script.Parent.Estado)
local Fogata = require(script.Parent.Fogata)
local Inventario = require(script.Parent.Inventario)
local Util = require(script.Parent.Parent.Mundo.Util)

local Taller = {}

local DISTANCIA_MAXIMA = 22
local rgb = Color3.fromRGB

local function buscarReceta(id: string)
	for _, receta in Config.RECETAS do
		if receta.id == id then
			return receta
		end
	end
	return nil
end

local function mesaActual(): BasePart?
	local c = Fogata.actual()
	return c and c.mesa and c.mesa.PrimaryPart
end

local function aplicar(jugador: Player, receta): boolean
	local id = receta.id
	if id == "Botiquin" then
		local hum = Inventario.humanoide(jugador)
		if not hum then
			return false
		end
		hum.Health = hum.MaxHealth
	elseif id == "Hacha" or id == "Lanza" or id == "Antorcha" then
		jugador:SetAttribute("Tiene" .. id, true)
		Armas.dar(jugador, id)
	elseif id == "Cuerda" then
		Inventario.dar(jugador, "Cuerda", 1)
	elseif id == "Abrigo" then
		jugador:SetAttribute("TieneAbrigo", true)
		Inventario.ponerAbrigo(jugador)
	elseif id == "Fuego2" or id == "Fuego3" then
		local nivel = if id == "Fuego2" then 2 else 3
		Fogata.mejorar(nivel)
		Estado.notificar(nil, "🔥 " .. jugador.DisplayName .. " ha mejorado el fuego a nivel " .. nivel, rgb(255, 190, 100))
	else
		return false
	end
	return true
end

local function fabricar(jugador: Player, id)
	if type(id) ~= "string" then
		return
	end
	local receta = buscarReceta(id)
	if not receta then
		return
	end
	local raiz = Inventario.raiz(jugador)
	local mesa = mesaActual()
	if not raiz or not mesa or (raiz.Position - mesa.Position).Magnitude > DISTANCIA_MAXIMA then
		Estado.notificar(jugador, "Acércate a la mesa del campamento.")
		return
	end
	local ok, motivo = Config.recetaDesbloqueada(receta, Estado.obj)
	if not ok then
		Estado.notificar(jugador, "🔒 " .. (motivo or "Todavía no puedes fabricar esto."))
		return
	end
	if receta.unica and jugador:GetAttribute(receta.unica) then
		Estado.notificar(jugador, "Ya tienes " .. receta.nombre .. ".")
		return
	end
	if receta.id == "Botiquin" then
		local hum = Inventario.humanoide(jugador)
		if not hum or hum.Health >= hum.MaxHealth then
			Estado.notificar(jugador, "Tu vida ya está llena.")
			return
		end
	end
	if not Inventario.puedePagar(jugador, receta.coste) then
		Estado.notificar(jugador, "Te faltan materiales para " .. receta.nombre .. ".", rgb(255, 140, 120))
		return
	end
	Inventario.pagar(jugador, receta.coste)
	if aplicar(jugador, receta) then
		Estado.notificar(jugador, receta.icono .. " ¡Has fabricado " .. receta.nombre .. "!", rgb(150, 230, 120))
	end
end

function Taller.iniciar()
	for etapa = 1, #Config.ETAPAS do
		local c = Fogata.campamento(etapa)
		local tablero = c and c.mesa and c.mesa.PrimaryPart
		if tablero then
			local prompt = Util.prompt(tablero, "Fabricar", "🔨 Mesa del campamento", 0, 10)
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.Triggered:Connect(function(jugador)
				local actual = Estado.get("Etapa") or 1
				if etapa < actual then
					Estado.notificar(jugador, "Este campamento ya lo dejasteis atrás: usad la mesa del campamento actual.")
					return
				elseif etapa > actual then
					Estado.notificar(jugador, "Encended primero la hoguera de este campamento.")
					return
				end
				Estado.remotos.AbrirTaller:FireClient(jugador)
			end)
		end
	end
	Estado.remotos.Fabricar.OnServerEvent:Connect(fabricar)
end

return Taller
