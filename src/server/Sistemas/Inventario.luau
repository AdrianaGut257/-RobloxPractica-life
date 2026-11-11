local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)

local Inventario = {}

local RECURSOS = Config.RECURSOS_MOCHILA

Inventario.junto_al_fuego = function(_pos: Vector3): boolean
	return false
end

function Inventario.cantidad(jugador: Player, recurso: string): number
	return jugador:GetAttribute(recurso) or 0
end

function Inventario.dar(jugador: Player, recurso: string, n: number)
	jugador:SetAttribute(recurso, Inventario.cantidad(jugador, recurso) + n)
end

function Inventario.quitar(jugador: Player, recurso: string, n: number)
	jugador:SetAttribute(recurso, math.max(0, Inventario.cantidad(jugador, recurso) - n))
end

function Inventario.puedePagar(jugador: Player, coste): boolean
	for recurso, n in coste do
		if Inventario.cantidad(jugador, recurso) < n then
			return false
		end
	end
	return true
end

function Inventario.pagar(jugador: Player, coste): boolean
	if not Inventario.puedePagar(jugador, coste) then
		return false
	end
	for recurso, n in coste do
		Inventario.quitar(jugador, recurso, n)
	end
	return true
end

function Inventario.humanoide(jugador: Player): Humanoid?
	local personaje = jugador.Character
	local hum = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		return hum
	end
	return nil
end

function Inventario.raiz(jugador: Player): BasePart?
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if raiz and Inventario.humanoide(jugador) then
		return raiz :: BasePart
	end
	return nil
end

function Inventario.ponerAbrigo(jugador: Player)
	local personaje = jugador.Character
	if not personaje or personaje:FindFirstChild("Abrigo") then
		return
	end
	local torso = (personaje:FindFirstChild("UpperTorso") or personaje:FindFirstChild("Torso")) :: BasePart?
	if not torso then
		return
	end
	local abrigo = Instance.new("Part")
	abrigo.Name = "Abrigo"
	abrigo.Size = torso.Size + Vector3.new(0.3, 0.35, 0.3)
	abrigo.Color = Color3.fromRGB(150, 74, 52)
	abrigo.Material = Enum.Material.Fabric
	abrigo.CanCollide = false
	abrigo.CanQuery = false
	abrigo.CanTouch = false
	abrigo.Massless = true
	abrigo.CFrame = torso.CFrame * CFrame.new(0, -0.1, 0)
	local cuello = Instance.new("Part")
	cuello.Name = "Cuello"
	cuello.Size = Vector3.new(torso.Size.X * 0.7, 0.4, torso.Size.Z + 0.4)
	cuello.Color = Color3.fromRGB(235, 225, 205)
	cuello.Material = Enum.Material.Fabric
	cuello.CanCollide = false
	cuello.CanQuery = false
	cuello.CanTouch = false
	cuello.Massless = true
	cuello.CFrame = torso.CFrame * CFrame.new(0, torso.Size.Y / 2 + 0.05, 0)
	for _, p in { abrigo, cuello } do
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = p
		w.Parent = p
	end
	cuello.Parent = abrigo
	abrigo.Parent = personaje
end

local function alAparecer(jugador: Player, personaje: Model)
	local hum = personaje:WaitForChild("Humanoid") :: Humanoid
	jugador:SetAttribute("Hambre", math.max(jugador:GetAttribute("Hambre") or 0, Config.HAMBRE.AL_REAPARECER))
	jugador:SetAttribute("Calor", Config.FRIO.MAXIMO)
	if jugador:GetAttribute("TieneAbrigo") then
		task.delay(0.5, Inventario.ponerAbrigo, jugador)
	end
	hum.Died:Connect(function()
		local lena = Inventario.cantidad(jugador, "Lena")
		jugador:SetAttribute("Lena", 0)
		jugador:SetAttribute("Piedra", math.floor(Inventario.cantidad(jugador, "Piedra") / 2))
		jugador:SetAttribute("Fibra", math.floor(Inventario.cantidad(jugador, "Fibra") / 2))
		if lena > 0 then
			Estado.notificar(jugador, "💀 Has caído... perdiste la leña y parte de lo que llevabas.", Color3.fromRGB(255, 120, 120))
		end
	end)
end

local ultimoBocado = {}

local function comer(jugador: Player)
	local ahora = os.clock()
	if ultimoBocado[jugador] and ahora - ultimoBocado[jugador] < 0.5 then
		return
	end
	ultimoBocado[jugador] = ahora
	local hum = Inventario.humanoide(jugador)
	if not hum then
		return
	end
	if Inventario.cantidad(jugador, "Comida") <= 0 then
		Estado.notificar(jugador, "No tienes comida. Busca moras, setas o mochilas perdidas... o pesca en el río.")
		return
	end
	local hambre = jugador:GetAttribute("Hambre") or 0
	if hambre >= Config.HAMBRE.MAXIMA - 1 and hum.Health >= hum.MaxHealth then
		Estado.notificar(jugador, "No tienes hambre ahora mismo.")
		return
	end
	Inventario.quitar(jugador, "Comida", 1)
	jugador:SetAttribute("Hambre", math.min(Config.HAMBRE.MAXIMA, hambre + Config.HAMBRE.POR_COMIDA))
	hum.Health = math.min(hum.MaxHealth, hum.Health + Config.HAMBRE.CURA_COMIDA)
	Estado.notificar(jugador, "🍎 ¡Ñam!", Color3.fromRGB(150, 230, 120))
end

function Inventario.haceFrio(pos: Vector3): boolean
	local etapa = Config.ETAPAS[Config.etapaEn(pos.Z)]
	return etapa ~= nil and etapa.frio == true
end

function Inventario.iniciar()
	local function alEntrar(jugador: Player)
		for _, recurso in RECURSOS do
			jugador:SetAttribute(recurso, 0)
		end
		jugador:SetAttribute("Hambre", Config.HAMBRE.MAXIMA)
		jugador:SetAttribute("Calor", Config.FRIO.MAXIMO)
		for _, atributo in { "TieneHacha", "TieneLanza", "TieneAntorcha", "TieneAbrigo" } do
			jugador:SetAttribute(atributo, false)
		end
		jugador.CharacterAdded:Connect(function(personaje)
			alAparecer(jugador, personaje)
		end)
		if jugador.Character then
			alAparecer(jugador, jugador.Character)
		end
	end
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		task.spawn(alEntrar, jugador)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		ultimoBocado[jugador] = nil
	end)

	Estado.remotos.Comer.OnServerEvent:Connect(comer)

	task.spawn(function()
		local F = Config.FRIO
		while true do
			task.wait(1)
			if Estado.get("Fase") == "Final" then
				continue
			end
			for _, jugador in Players:GetPlayers() do
				local hum = Inventario.humanoide(jugador)
				local raiz = Inventario.raiz(jugador)
				if not hum or not raiz then
					continue
				end
				local hambre = math.max(0, (jugador:GetAttribute("Hambre") or 0) - Config.HAMBRE.GASTO)
				jugador:SetAttribute("Hambre", hambre)
				if hambre <= 0 then
					hum:TakeDamage(Config.HAMBRE.DANO_SIN_COMIDA)
				end

				local calor = jugador:GetAttribute("Calor") or F.MAXIMO
				local frio = Inventario.haceFrio(raiz.Position)
				if Inventario.junto_al_fuego(raiz.Position) or not frio then
					calor = math.min(F.MAXIMO, calor + F.RECUPERA)
				else
					local gasto = if Estado.esNoche() then F.GASTO_NOCHE else F.GASTO
					if jugador:GetAttribute("TieneAbrigo") then
						gasto *= F.CON_ABRIGO
					end
					calor = math.max(0, calor - gasto)
					if calor <= 0 then
						hum:TakeDamage(F.DANO)
					end
				end
				jugador:SetAttribute("Calor", calor)
				jugador:SetAttribute("EnFrio", frio)
			end
		end
	end)
end

return Inventario
