local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Enemigos = require(script.Parent.Enemigos)
local Estado = require(script.Parent.Estado)
local Recursos = require(script.Parent.Recursos)

local Armas = {}

local rgb = Color3.fromRGB
local V = Vector3.new
local plantillas: { [string]: Tool } = {}
local ultimoGolpe = {}

local function construir(nombre: string, tip: string, mango, piezas, agarre: CFrame): Tool
	local t = Instance.new("Tool")
	t.Name = nombre
	t.ToolTip = tip
	t.CanBeDropped = false
	t.Grip = agarre

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = mango.size
	handle.Color = mango.color
	handle.Material = mango.material
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CFrame = CFrame.new()
	handle.Parent = t

	for _, info in piezas do
		local p = Instance.new("Part")
		p.Name = info.nombre or "Pieza"
		p.Size = info.size
		p.Color = info.color
		p.Material = info.material
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		if info.bola then
			p.Shape = Enum.PartType.Ball
		end
		if info.cuna then
			local cuna = Instance.new("SpecialMesh")
			cuna.MeshType = Enum.MeshType.Wedge
			cuna.Parent = p
		end
		p.CFrame = handle.CFrame * info.cf
		p.Parent = t
		local w = Instance.new("WeldConstraint")
		w.Part0 = handle
		w.Part1 = p
		w.Parent = p
	end
	return t
end

local function crearPlantillas()
	local madera = rgb(130, 92, 58)
	local piedra = rgb(120, 118, 112)
	local fibra = rgb(110, 150, 70)

	plantillas.Palo = construir("Palo", "Un palo resistente. Golpea Brumosos y tala árboles (despacio).", {
		size = V(0.35, 4.2, 0.35),
		color = madera,
		material = Enum.Material.Wood,
	}, {
		{ nombre = "Nudo", size = V(0.5, 0.5, 0.5), cf = CFrame.new(0, 1.6, 0), color = rgb(110, 78, 50), material = Enum.Material.Wood, bola = true },
	}, CFrame.new(0, -1.4, 0))

	plantillas.Hacha = construir("Hacha", "Hacha de piedra. Tala rápido y corta troncos gruesos.", {
		size = V(0.35, 4, 0.35),
		color = madera,
		material = Enum.Material.Wood,
	}, {
		{ nombre = "Cabeza", size = V(0.4, 1.1, 1.6), cf = CFrame.new(0, 1.5, -0.6), color = piedra, material = Enum.Material.Slate },
		{ nombre = "Filo", size = V(0.2, 1.3, 0.4), cf = CFrame.new(0, 1.5, -1.45), color = rgb(160, 158, 150), material = Enum.Material.Slate },
		{ nombre = "Atadura", size = V(0.5, 0.5, 0.5), cf = CFrame.new(0, 1.5, 0), color = fibra, material = Enum.Material.Grass },
	}, CFrame.new(0, -1.3, 0))

	plantillas.Lanza = construir("Lanza", "Mucho daño y mucho alcance.", {
		size = V(0.3, 7, 0.3),
		color = madera,
		material = Enum.Material.Wood,
	}, {
		{ nombre = "Punta", size = V(0.25, 1.4, 0.7), cf = CFrame.new(0, 4.1, 0), color = piedra, material = Enum.Material.Slate },
		{ nombre = "Atadura", size = V(0.45, 0.6, 0.45), cf = CFrame.new(0, 3.3, 0), color = fibra, material = Enum.Material.Grass },
	}, CFrame.new(0, -0.6, 0))

	plantillas.Antorcha = construir("Antorcha", "Da luz, frena a los Brumosos y quema las telarañas de bruma.", {
		size = V(0.35, 3.4, 0.35),
		color = madera,
		material = Enum.Material.Wood,
	}, {
		{ nombre = "Trapo", size = V(0.6, 0.8, 0.6), cf = CFrame.new(0, 1.8, 0), color = rgb(60, 44, 34), material = Enum.Material.Fabric },
	}, CFrame.new(0, -0.9, 0))
	local trapo = plantillas.Antorcha:FindFirstChild("Trapo") :: BasePart
	local fuego = Instance.new("Fire")
	fuego.Size = 2.4
	fuego.Heat = 6
	fuego.Color = rgb(255, 150, 60)
	fuego.SecondaryColor = rgb(255, 220, 120)
	fuego.Parent = trapo
	local luz = Instance.new("PointLight")
	luz.Color = rgb(255, 180, 100)
	luz.Range = 26
	luz.Brightness = 2.2
	luz.Shadows = true
	luz.Parent = trapo
end

local function destello(enemigo: Model)
	local h = Instance.new("Highlight")
	h.FillColor = rgb(255, 255, 255)
	h.FillTransparency = 0.4
	h.OutlineTransparency = 1
	h.Parent = enemigo
	task.delay(0.15, function()
		h:Destroy()
	end)
end

local function golpear(jugador: Player, tool: Tool, stats)
	local personaje = jugador.Character
	if not personaje or tool.Parent ~= personaje then
		return
	end
	local raiz = personaje:FindFirstChild("HumanoidRootPart") :: BasePart
	local hum = personaje:FindFirstChildOfClass("Humanoid")
	if not raiz or not hum or hum.Health <= 0 then
		return
	end
	local ahora = os.clock()
	if ultimoGolpe[tool] and ahora - ultimoGolpe[tool] < stats.cadencia then
		return
	end
	ultimoGolpe[tool] = ahora

	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool

	local frente = raiz.CFrame.LookVector
	local acerto = false
	for _, enemigo in CollectionService:GetTagged("Enemigo") do
		local eRaiz = enemigo:FindFirstChild("HumanoidRootPart") :: BasePart
		local eHum = enemigo:FindFirstChildOfClass("Humanoid")
		if eRaiz and eHum and eHum.Health > 0 then
			local dir = eRaiz.Position - raiz.Position
			local distancia = dir.Magnitude
			local alcance = stats.alcance + eRaiz.Size.X / 2
			if distancia <= alcance and (distancia < 2.5 or frente:Dot(dir.Unit) > 0.2) then
				eHum:TakeDamage(stats.dano)
				destello(enemigo)
				acerto = true
			end
		end
	end
	if acerto then
		return
	end
	for _, tronco in CollectionService:GetTagged("Tronco") do
		local parte = tronco.PrimaryPart
		if parte and (parte.Position - raiz.Position).Magnitude < 14 then
			Estado.emitir("GolpeTronco", jugador, stats)
			return
		end
	end
	if stats.tala <= 0 then
		return
	end
	for _, arbol in CollectionService:GetTagged("Talable") do
		local tronco = arbol.PrimaryPart
		if tronco and not arbol:GetAttribute("Talado") then
			local d = V(tronco.Position.X - raiz.Position.X, 0, tronco.Position.Z - raiz.Position.Z)
			if d.Magnitude <= stats.alcance + tronco.Size.Y / 2 then
				Recursos.talar(arbol, stats.tala, jugador)
				break
			end
		end
	end
end

function Armas.dar(jugador: Player, nombre: string)
	local mochila = jugador:FindFirstChildOfClass("Backpack")
	if not mochila or not plantillas[nombre] then
		return
	end
	if mochila:FindFirstChild(nombre) or (jugador.Character and jugador.Character:FindFirstChild(nombre)) then
		return
	end
	local t = plantillas[nombre]:Clone()
	local stats = Config.ARMAS[nombre]
	if stats then
		t.Activated:Connect(function()
			golpear(jugador, t, stats)
		end)
	end
	t.Destroying:Connect(function()
		ultimoGolpe[t] = nil
	end)
	t.Parent = mochila
end

function Armas.llevaAntorcha(jugador: Player): boolean
	local personaje = jugador.Character
	return personaje ~= nil and personaje:FindFirstChild("Antorcha") ~= nil
end

function Armas.iniciar()
	crearPlantillas()

	local function alAparecer(jugador: Player)
		local mochila = jugador:WaitForChild("Backpack", 10)
		if not mochila then
			return
		end
		Armas.dar(jugador, "Palo")
		for atributo, nombre in { TieneHacha = "Hacha", TieneLanza = "Lanza", TieneAntorcha = "Antorcha" } do
			if jugador:GetAttribute(atributo) then
				Armas.dar(jugador, nombre)
			end
		end
	end
	local function alEntrar(jugador: Player)
		jugador.CharacterAdded:Connect(function()
			alAparecer(jugador)
		end)
		if jugador.Character then
			task.spawn(alAparecer, jugador)
		end
	end
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end

	task.spawn(function()
		local PASO = 0.3
		while true do
			task.wait(PASO)
			for _, jugador in Players:GetPlayers() do
				local personaje = jugador.Character
				local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
				if raiz and Armas.llevaAntorcha(jugador) then
					for _, enemigo in CollectionService:GetTagged("Enemigo") do
						local eRaiz = enemigo:FindFirstChild("HumanoidRootPart") :: BasePart?
						if eRaiz then
							local d = (eRaiz.Position - raiz.Position).Magnitude
							if d <= Config.ANTORCHA.RADIO then
								Enemigos.ralentizar(enemigo, 0.5)
							end
							local eHum = enemigo:FindFirstChildOfClass("Humanoid")
							if d <= 8 and eHum then
								eHum:TakeDamage(3 * PASO)
							end
						end
					end
				end
			end
		end
	end)
end

return Armas
