local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)

local Ciclo = {}

local rgb = Color3.fromRGB
local saltar = false
local ultimaPendiente = false

local atmosfera: Atmosphere
local correccion: ColorCorrectionEffect

local TONOS = {
	[1] = {
		dia = { Color = rgb(214, 206, 178), Decay = rgb(120, 132, 120), Density = 0.28, Haze = 1.2, tinte = rgb(255, 247, 230), sat = 0.14, ambiente = rgb(140, 132, 116) },
		noche = { Color = rgb(56, 62, 92), Decay = rgb(24, 28, 46), Density = 0.42, Haze = 2.2, tinte = rgb(205, 215, 255), sat = -0.1, ambiente = rgb(46, 50, 80) },
	},
	[2] = {
		dia = { Color = rgb(198, 214, 216), Decay = rgb(110, 128, 140), Density = 0.3, Haze = 1.4, tinte = rgb(244, 252, 255), sat = 0.1, ambiente = rgb(130, 136, 136) },
		noche = { Color = rgb(48, 60, 90), Decay = rgb(20, 28, 46), Density = 0.44, Haze = 2.4, tinte = rgb(200, 215, 255), sat = -0.12, ambiente = rgb(42, 50, 80) },
	},
	[3] = {
		dia = { Color = rgb(126, 138, 130), Decay = rgb(70, 82, 76), Density = 0.52, Haze = 2.8, tinte = rgb(220, 236, 222), sat = -0.18, ambiente = rgb(96, 104, 98) },
		noche = { Color = rgb(30, 38, 36), Decay = rgb(12, 18, 16), Density = 0.6, Haze = 3, tinte = rgb(190, 210, 200), sat = -0.25, ambiente = rgb(32, 40, 44) },
	},
	[4] = {
		dia = { Color = rgb(228, 234, 246), Decay = rgb(150, 166, 196), Density = 0.4, Haze = 2, tinte = rgb(238, 246, 255), sat = -0.06, ambiente = rgb(150, 156, 170) },
		noche = { Color = rgb(70, 82, 116), Decay = rgb(30, 38, 64), Density = 0.5, Haze = 2.6, tinte = rgb(200, 215, 255), sat = -0.12, ambiente = rgb(56, 64, 96) },
	},
	[5] = {
		dia = { Color = rgb(230, 210, 180), Decay = rgb(140, 140, 150), Density = 0.24, Haze = 1, tinte = rgb(255, 244, 226), sat = 0.16, ambiente = rgb(146, 136, 120) },
		noche = { Color = rgb(46, 54, 92), Decay = rgb(20, 24, 48), Density = 0.42, Haze = 2.2, tinte = rgb(205, 212, 255), sat = -0.1, ambiente = rgb(44, 50, 84) },
	},
}

local function prepararIluminacion()
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	Lighting.ClockTime = 7
	Lighting.GeographicLatitude = 41

	atmosfera = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosfera.Offset = 0.15
	atmosfera.Glare = 0.2
	atmosfera.Parent = Lighting

	local cielo = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
	cielo.StarCount = 3000
	cielo.CelestialBodiesShown = true
	cielo.Parent = Lighting

	local brillo = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
	brillo.Intensity = 0.6
	brillo.Size = 24
	brillo.Threshold = 1.6
	brillo.Parent = Lighting

	local rayos = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect")
	rayos.Intensity = 0.07
	rayos.Spread = 0.8
	rayos.Parent = Lighting

	correccion = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
	correccion.Parent = Lighting
end

local function cambiarAmbiente(instantaneo: boolean?)
	local fase = Estado.get("Fase") or "Dia"
	local etapa = math.clamp(Estado.get("Etapa") or 1, 1, #TONOS)
	local esNoche = fase == "Noche" or fase == "UltimaNoche"
	local t = TONOS[etapa][if esNoche then "noche" else "dia"]
	local info = TweenInfo.new(if instantaneo then 0.1 else 8, Enum.EasingStyle.Sine)

	TweenService:Create(Lighting, info, {
		Brightness = if esNoche then 1 else 2.6,
		OutdoorAmbient = t.ambiente,
		Ambient = t.ambiente:Lerp(Color3.new(), 0.5),
		ExposureCompensation = if esNoche then 0.25 else 0,
	}):Play()
	TweenService:Create(atmosfera, info, {
		Color = t.Color,
		Decay = t.Decay,
		Density = if fase == "UltimaNoche" then t.Density + 0.08 else t.Density,
		Haze = t.Haze,
	}):Play()
	TweenService:Create(correccion, info, {
		TintColor = if fase == "UltimaNoche" then t.tinte:Lerp(rgb(255, 190, 200), 0.25) else t.tinte,
		Saturation = t.sat,
		Contrast = if esNoche then 0.1 else 0.05,
	}):Play()

	for _, e in CollectionService:GetTagged("Luciernagas") do
		(e :: any).Enabled = esNoche
	end
	for _, e in CollectionService:GetTagged("Mariposas") do
		(e :: any).Enabled = not esNoche
	end
end

local function actualizarReloj(fase: string, p: number)
	if fase == "Dia" then
		Lighting.ClockTime = 7 + p * 11
	else
		Lighting.ClockTime = (18.5 + p * 12) % 24
	end
end

local function correrFase(fase: string, duracion: number)
	Estado.set("Fase", fase)
	Estado.set("DuracionFase", duracion)
	saltar = false
	local avisado = false
	local inicio = os.clock()
	while true do
		local t = os.clock() - inicio
		local restante = math.max(0, duracion - t)
		actualizarReloj(fase, math.clamp(t / duracion, 0, 1))
		Estado.set("TiempoRestante", math.ceil(restante))
		if fase == "Dia" and not avisado and restante <= Config.AVISO_ANOCHECER then
			avisado = true
			Estado.notificar(nil, "🌇 Está anocheciendo... ¡volved al campamento y avivad el fuego!", rgb(255, 200, 120))
		end
		if t >= duracion or saltar then
			break
		end
		task.wait(0.1)
	end
end

function Ciclo.empezarUltimaNoche()
	if ultimaPendiente then
		return
	end
	ultimaPendiente = true
	saltar = true
end

local function bucle()
	while true do
		if ultimaPendiente then
			Estado.set("UltimaNoche", true)
			Estado.set("Fase", "UltimaNoche")
			cambiarAmbiente()
			Estado.anunciar("LA ÚLTIMA NOCHE", "La Bruma entera sale del mar. ¡Resistid junto al fuego hasta el amanecer!")
			Estado.emitir("UltimaNocheEmpieza")
			correrFase("UltimaNoche", Config.DURACION_ULTIMA_NOCHE)

			Estado.set("NochesSobrevividas", (Estado.get("NochesSobrevividas") or 0) + 1)
			Estado.set("Fase", "Final")
			Estado.set("TiempoRestante", 0)
			cambiarAmbiente()
			TweenService:Create(Lighting, TweenInfo.new(10), { ClockTime = 7 }):Play()
			Estado.anunciar("¡AMANECE!", "La luz del faro ha hecho retroceder a la Bruma. Mirad el mar...")
			Estado.emitir("Final")
			return
		end

		local dia = Estado.get("Dia") or 1
		Estado.set("Fase", "Dia")
		cambiarAmbiente()
		if dia > 1 then
			local etapa = Config.ETAPAS[Estado.get("Etapa") or 1]
			Estado.anunciar("DÍA " .. dia, "Habéis sobrevivido a la noche " .. (dia - 1) .. "  ·  " .. etapa.nombre)
		end
		Estado.emitir("DiaEmpieza", dia)
		correrFase("Dia", Config.DURACION_DIA)
		if ultimaPendiente then
			continue
		end

		Estado.set("NocheActual", dia)
		Estado.set("Fase", "Noche")
		cambiarAmbiente()
		Estado.anunciar("NOCHE " .. dia, "Los Brumosos salen de la niebla. ¡Quedaos junto al fuego con Lía!")
		Estado.emitir("NocheEmpieza", dia)
		correrFase("Noche", Config.DURACION_NOCHE)
		if ultimaPendiente then
			continue
		end

		Estado.set("NochesSobrevividas", dia)
		Estado.set("Dia", dia + 1)
		Estado.emitir("NocheSobrevivida", dia)
	end
end

function Ciclo.iniciar()
	prepararIluminacion()
	Estado.set("Dia", 1)
	Estado.set("NocheActual", 0)
	Estado.set("NochesSobrevividas", 0)
	Estado.set("UltimaNoche", false)
	Estado.set("Fase", "Dia")
	cambiarAmbiente(true)
	Estado.obj:GetAttributeChangedSignal("Etapa"):Connect(function()
		cambiarAmbiente()
	end)
	task.spawn(bucle)
end

return Ciclo
