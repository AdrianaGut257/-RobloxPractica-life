local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Clima = {}

local rgb = Color3.fromRGB
local V = Vector3.new

local function emisor(padre: BasePart, props)
	local e = Instance.new("ParticleEmitter")
	for clave, valor in props do
		(e :: any)[clave] = valor
	end
	e.Enabled = false
	e.Parent = padre
	return e
end

function Clima.iniciar(estado: Instance)
	local jugador = Players.LocalPlayer

	local cielo = Instance.new("Part")
	cielo.Name = "ClimaLocal"
	cielo.Anchored = true
	cielo.CanCollide = false
	cielo.CanQuery = false
	cielo.CanTouch = false
	cielo.Transparency = 1
	cielo.Size = V(140, 1, 140)
	cielo.Parent = workspace

	local efectos = {
		[1] = emisor(cielo, {
			Color = ColorSequence.new(rgb(190, 205, 90), rgb(226, 196, 80)),
			Size = NumberSequence.new(0.3),
			Lifetime = NumberRange.new(8, 12),
			Rate = 14,
			Speed = NumberRange.new(1, 2),
			SpreadAngle = Vector2.new(30, 30),
			Acceleration = V(0.6, -1.2, 0.4),
			RotSpeed = NumberRange.new(-120, 120),
			Rotation = NumberRange.new(0, 360),
			EmissionDirection = Enum.NormalId.Bottom,
		}),
		[3] = emisor(cielo, {
			Color = ColorSequence.new(rgb(200, 205, 210)),
			LightEmission = 0.3,
			Transparency = NumberSequence.new(0.4),
			Size = NumberSequence.new(0.15),
			Lifetime = NumberRange.new(10, 14),
			Rate = 30,
			Speed = NumberRange.new(0.2, 0.6),
			SpreadAngle = Vector2.new(180, 180),
			Acceleration = V(0, -0.3, 0),
			EmissionDirection = Enum.NormalId.Bottom,
		}),
		[4] = emisor(cielo, {
			Color = ColorSequence.new(rgb(255, 255, 255)),
			Size = NumberSequence.new(0.22),
			Lifetime = NumberRange.new(6, 9),
			Rate = 160,
			Speed = NumberRange.new(4, 6),
			SpreadAngle = Vector2.new(20, 20),
			Acceleration = V(2, 0, 1),
			EmissionDirection = Enum.NormalId.Bottom,
		}),
	}

	local faro = nil
	local haces = {}
	local angulo = 0
	local function buscarFaro()
		faro = CollectionService:GetTagged("Faro")[1]
		haces = CollectionService:GetTagged("HazFaro")
	end
	buscarFaro()

	local ultimaEtapa = 0
	RunService.RenderStepped:Connect(function(dt)
		local camara = workspace.CurrentCamera
		if not camara then
			return
		end
		local pos = camara.CFrame.Position
		cielo.CFrame = CFrame.new(pos + V(0, 28, 0))

		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
		local etapa = Config.etapaEn((if raiz then raiz.Position else pos).Z)
		if etapa ~= ultimaEtapa then
			ultimaEtapa = etapa
			for n, e in efectos do
				e.Enabled = n == etapa
			end
		end
		local noche = estado:GetAttribute("Fase") == "Noche" or estado:GetAttribute("Fase") == "UltimaNoche"
		if efectos[1] then
			efectos[1].Rate = if noche then 3 else 14
		end

		if estado:GetAttribute("FaroEncendido") then
			if #haces == 0 then
				buscarFaro()
			end
			local centro = faro and faro:GetAttribute("Centro")
			if typeof(centro) == "Vector3" then
				angulo = (angulo + dt * math.rad(35)) % (math.pi * 2)
				for _, haz in haces do
					local giro = haz:GetAttribute("Giro") or 0
					haz.Transparency = 0.8
					haz.CFrame = CFrame.new(centro) * CFrame.Angles(0, angulo + giro, 0) * CFrame.Angles(math.rad(-4), 0, 0) * CFrame.new(0, 0, -72)
				end
			end
		end
	end)
end

return Clima
