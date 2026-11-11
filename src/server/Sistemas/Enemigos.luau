local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Caminar = require(script.Parent.Caminar)
local Cuerpos = require(script.Parent.Cuerpos)
local Estado = require(script.Parent.Estado)
local Fogata = require(script.Parent.Fogata)
local Lia = require(script.Parent.Lia)
local Recursos = require(script.Parent.Recursos)

local Enemigos = {}

local CFG = Config.ENEMIGOS
local rgb = Color3.fromRGB
local V = Vector3.new
local TICK = 0.2
local GRUPO = "Enemigos"
local ALCANCE_DE_DIA = 70

local carpeta: Folder
local activos = {}
local puntos: { BasePart } = {}
local puntoJefe: BasePart? = nil
local plantillas = {}

local APARIENCIA = {
	Brumoso = { cuerpo = rgb(150, 160, 176), transparencia = 0.25, ojos = rgb(235, 245, 255), niebla = rgb(180, 188, 200) },
	Corredor = { cuerpo = rgb(110, 118, 136), transparencia = 0.2, ojos = rgb(255, 90, 90), niebla = rgb(140, 146, 160), garras = true },
	Gigante = { cuerpo = rgb(88, 94, 110), transparencia = 0.15, ojos = rgb(255, 170, 80), niebla = rgb(120, 126, 140), hombros = true },
	Rey = { cuerpo = rgb(58, 62, 78), transparencia = 0.08, ojos = rgb(140, 200, 255), niebla = rgb(90, 96, 120), corona = true },
}

local function crearCuerpo(tipo: string): Model
	local datos = CFG.TIPOS[tipo]
	local ap = APARIENCIA[tipo]
	local modelo = Cuerpos.crear({
		nombre = datos.nombre,
		escala = datos.escala,
		vida = datos.vida,
		velocidad = datos.velocidad,
		colores = { cabeza = ap.cuerpo, torso = ap.cuerpo, brazos = ap.cuerpo, piernas = ap.cuerpo },
		transparencia = ap.transparencia,
		brazosAlFrente = true,
		grupo = GRUPO,
		distanciaNombre = if datos.jefe then 150 else 0,
		adornos = function(adorno, p, en)
			local M = Enum.Material
			for _, x in { -0.3, 0.3 } do
				adorno("Ojo", V(0.26, 0.16, 0.1), en(x, 1.62, -0.66), ap.ojos, nil, p.cabeza, true)
			end
			adorno("Jiron", V(1.6, 1, 0.3), en(0, -0.9, 0.55), ap.niebla, M.SmoothPlastic, p.torso).Transparency = 0.5
			adorno("Jiron", V(0.8, 1.2, 0.8), en(1.5, -1.3, 0), ap.niebla, M.SmoothPlastic, p.brazoD).Transparency = 0.5
			adorno("Jiron", V(0.8, 1.2, 0.8), en(-1.5, -1.3, 0), ap.niebla, M.SmoothPlastic, p.brazoI).Transparency = 0.5
			if ap.garras then
				for _, brazo in { { p.brazoD, 1.5 }, { p.brazoI, -1.5 } } do
					for k = -1, 1 do
						adorno("Garra", V(0.15, 0.15, 1.3), en(brazo[2] + k * 0.3, -1, -0.9), rgb(40, 40, 46), M.SmoothPlastic, brazo[1])
					end
				end
			end
			if ap.hombros then
				adorno("Hombro", V(1.6, 1.2, 1.6), en(1.4, 1.1, 0), ap.niebla, M.SmoothPlastic, p.torso).Transparency = 0.3
				adorno("Hombro", V(1.6, 1.2, 1.6), en(-1.4, 1.1, 0), ap.niebla, M.SmoothPlastic, p.torso).Transparency = 0.3
			end
			if ap.corona then
				for k = 0, 6 do
					local a = k * (math.pi * 2 / 7)
					adorno("Corona", V(0.25, 1.1, 0.25), en(math.cos(a) * 0.75, 2.45, math.sin(a) * 0.6) * CFrame.Angles(math.sin(a) * 0.3, 0, -math.cos(a) * 0.3), rgb(30, 32, 40), M.SmoothPlastic, p.cabeza)
				end
				adorno("Capa", V(2.2, 3.4, 0.2), en(0, -0.9, 0.65), rgb(40, 44, 60), M.Fabric, p.torso).Transparency = 0.2
			end
		end,
	})
	local torso = modelo:FindFirstChild("Torso")
	local niebla = Instance.new("ParticleEmitter")
	niebla.Name = "Niebla"
	niebla.Texture = "rbxasset://textures/particles/smoke_main.dds"
	niebla.Color = ColorSequence.new(ap.niebla)
	niebla.Transparency = NumberSequence.new(0.6, 1)
	niebla.Size = NumberSequence.new(1.5 * datos.escala, 3 * datos.escala)
	niebla.Lifetime = NumberRange.new(1.2, 2)
	niebla.Rate = 4
	niebla.Speed = NumberRange.new(0.5, 1.5)
	niebla.SpreadAngle = Vector2.new(180, 180)
	niebla.LightInfluence = 0.6
	niebla.Parent = torso
	return modelo
end

local function plantilla(tipo: string): Model
	if not plantillas[tipo] then
		plantillas[tipo] = crearCuerpo(tipo)
	end
	return plantillas[tipo]
end

local function contar(soloNoche: boolean?): number
	local n = 0
	for _, e in activos do
		if not soloNoche or not e.deDia then
			n += 1
		end
	end
	return n
end

local function contarDeDia(): number
	local n = 0
	for _, e in activos do
		if e.deDia then
			n += 1
		end
	end
	return n
end

local function nubeDeNiebla(pos: Vector3, tam: number)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = V(3, 1, 3)
	p.Position = pos
	p.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/smoke_main.dds"
	e.Color = ColorSequence.new(rgb(190, 196, 206))
	e.Transparency = NumberSequence.new(0.3, 1)
	e.Size = NumberSequence.new(2 * tam, 5 * tam)
	e.Lifetime = NumberRange.new(1, 2)
	e.Speed = NumberRange.new(3, 6)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Enabled = false
	e.Parent = p
	e:Emit(24)
	task.delay(2.5, function()
		p:Destroy()
	end)
end

local function jugadoresVivos()
	local lista = {}
	for _, j in Players:GetPlayers() do
		local c = j.Character
		local h = c and c:FindFirstChildOfClass("Humanoid")
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if h and r and h.Health > 0 then
			table.insert(lista, { jugador = j, hum = h, raiz = r :: BasePart })
		end
	end
	return lista
end

local function morir(e)
	if e.muerto then
		return
	end
	e.muerto = true
	activos[e.modelo] = nil
	Estado.set("EnemigosVivos", contar())
	local pos = e.raiz.Position
	nubeDeNiebla(pos, e.datos.escala)
	if not e.sinBotin then
		if e.datos.jefe then
			for i = 1, 10 do
				local a = i * (math.pi / 5)
				local recurso = ({ "Comida", "Lena", "Piedra", "Fibra" })[i % 4 + 1]
				Recursos.soltar(recurso, Caminar.suelo(pos + V(math.cos(a) * 4, 0, math.sin(a) * 4)), 2)
			end
			Estado.anunciar("¡EL REY DE LA NIEBLA HA CAÍDO!", "Pero la noche sigue... ¡resistid hasta el amanecer!")
		elseif math.random() < 0.45 then
			local recurso = ({ "Lena", "Piedra", "Fibra", "Comida" })[math.random(1, 4)]
			Recursos.soltar(recurso, Caminar.suelo(pos + V(math.random(-2, 2), 0, math.random(-2, 2))), 1)
		end
	end
	for _, d in e.modelo:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			TweenService:Create(d, TweenInfo.new(1.2), { Transparency = 1 }):Play()
		elseif d:IsA("ParticleEmitter") then
			d.Enabled = false
		end
	end
	task.delay(1.3, function()
		e.modelo:Destroy()
	end)
end

local function deshacer(soloNoche: boolean)
	for _, e in activos do
		if not soloNoche or not e.deDia then
			e.sinBotin = true
			e.hum.Health = 0
		end
	end
end

local function atacar(e, objetivo)
	local ahora = os.clock()
	if ahora - e.ultimoAtaque < e.datos.cadencia then
		return
	end
	e.ultimoAtaque = ahora
	if objetivo.esLia then
		Lia.golpeada()
	else
		objetivo.hum:TakeDamage(e.datos.dano)
	end
end

local function actualizar(e, objetivos)
	local pos = e.raiz.Position
	local ahora = os.clock()
	local datos = e.datos

	e.hum.WalkSpeed = datos.velocidad * (if ahora < e.lentoHasta then Config.ANTORCHA.LENTITUD else 1)

	if Fogata.estaProtegido(pos) then
		e.hum:TakeDamage(Config.FUEGO.DANO_LUZ * TICK * (if datos.jefe then 0.3 else 1))
		if not datos.jefe then
			e.agente:ir(Fogata.puntoBorde(pos, 8))
			return
		end
	end

	local mejor, mejorDist = nil, math.huge
	for _, o in objetivos do
		local d = (o.raiz.Position - pos).Magnitude
		local alcanzable = datos.jefe or not Fogata.estaProtegido(o.raiz.Position)
		if e.deDia and d > ALCANCE_DE_DIA then
			alcanzable = false
		end
		if d < mejorDist and alcanzable then
			mejor, mejorDist = o, d
		end
	end

	if mejor then
		if mejorDist <= 3.5 * datos.escala + 1.5 then
			atacar(e, mejor)
		end
		e.agente:ir(mejor.raiz.Position)
		return
	end
	if not e.deDia and #objetivos > 0 and Fogata.arde() then
		e.agente:ir(Fogata.puntoBorde(pos, 6))
		return
	end
	if (ahora - (e.ultimoPaseo or 0) > 8 or not e.paseo) and #e.puntosPaseo > 0 then
		e.ultimoPaseo = ahora
		e.paseo = e.puntosPaseo[math.random(1, #e.puntosPaseo)].Position
	end
	if e.paseo then
		e.agente:ir(e.paseo)
	end
end

local function puntosDeEtapas(etapas: { [number]: boolean }): { BasePart }
	local lista = {}
	for _, p in puntos do
		if etapas[p:GetAttribute("Etapa") or 1] then
			table.insert(lista, p)
		end
	end
	return lista
end

function Enemigos.aparecer(tipo: string, pos: Vector3, deDia: boolean?)
	local datos = CFG.TIPOS[tipo]
	local m = plantilla(tipo):Clone()
	local hum = m:FindFirstChildOfClass("Humanoid") :: Humanoid
	local raiz = m:FindFirstChild("HumanoidRootPart") :: BasePart
	local noche = math.max(1, Estado.get("Dia") or 1)
	local vida = if datos.jefe then datos.vida else math.floor(datos.vida * (1 + CFG.VIDA_POR_NOCHE * (noche - 1)))
	hum.MaxHealth = vida
	hum.Health = vida
	m:PivotTo(CFrame.new(pos + V(0, 3 * datos.escala, 0)) * CFrame.Angles(0, math.random() * 6.28, 0))
	m.Parent = carpeta
	pcall(function()
		raiz:SetNetworkOwner(nil)
	end)
	CollectionService:AddTag(m, "Enemigo")
	if datos.jefe then
		local resalte = Instance.new("Highlight")
		resalte.FillTransparency = 1
		resalte.OutlineColor = rgb(140, 200, 255)
		resalte.Parent = m
	end
	local etapa = Config.etapaEn(pos.Z)
	local e = {
		modelo = m,
		hum = hum,
		raiz = raiz,
		tipo = tipo,
		datos = datos,
		deDia = deDia == true,
		ultimoAtaque = 0,
		lentoHasta = 0,
		puntosPaseo = puntosDeEtapas({ [etapa] = true }),
		agente = Caminar.nuevo(hum, raiz, { radio = 1.6 * datos.escala, alto = 5 * datos.escala }),
	}
	activos[m] = e
	Estado.set("EnemigosVivos", contar())
	Cuerpos.animar(hum, 12)
	hum.Died:Connect(function()
		morir(e)
	end)
	nubeDeNiebla(pos, datos.escala)
	return e
end

function Enemigos.ralentizar(modelo: Model, segundos: number)
	local e = activos[modelo]
	if e then
		e.lentoHasta = os.clock() + segundos
	end
end

local function elegirTipo(etapa: number): string
	local candidatos = {}
	local total = 0
	for nombre, datos in CFG.TIPOS do
		if not datos.jefe and etapa >= datos.desdeEtapa then
			table.insert(candidatos, { nombre, datos.peso })
			total += datos.peso
		end
	end
	local r = math.random() * total
	for _, c in candidatos do
		r -= c[2]
		if r <= 0 then
			return c[1]
		end
	end
	return candidatos[1][1]
end

local function puntoAparicion(soloEtapa: number?): Vector3?
	local vivos = jugadoresVivos()
	local etapas = {}
	if soloEtapa then
		etapas[soloEtapa] = true
	else
		etapas[Estado.get("Etapa") or 1] = true
		for _, v in vivos do
			etapas[Config.etapaEn(v.raiz.Position.Z)] = true
		end
	end
	local candidatos = {}
	for _, p in puntosDeEtapas(etapas) do
		local cerca = false
		for _, v in vivos do
			if (v.raiz.Position - p.Position).Magnitude < 35 then
				cerca = true
				break
			end
		end
		if not cerca and not Fogata.estaProtegido(p.Position) then
			table.insert(candidatos, p)
		end
	end
	if #candidatos == 0 then
		return nil
	end
	return candidatos[math.random(1, #candidatos)].Position
end

local function oleada(total: number, duracion: number, fase: string)
	if #puntos == 0 then
		warn("[Enemigos] No hay puntos de aparición (etiqueta 'PuntoEnemigo')")
		return
	end
	local intervalo = duracion * 0.6 / math.max(total, 1)
	for _ = 1, total do
		while contar(true) >= CFG.MAXIMO_VIVOS do
			task.wait(1)
			if Estado.get("Fase") ~= fase then
				return
			end
		end
		if Estado.get("Fase") ~= fase then
			return
		end
		local pos = puntoAparicion()
		if pos then
			Enemigos.aparecer(elegirTipo(Estado.get("Etapa") or 1), pos)
		end
		task.wait(intervalo)
	end
end

local function aparecerJefe()
	if Estado.get("Fase") ~= "UltimaNoche" then
		return
	end
	local pos = if puntoJefe then puntoJefe.Position else puntoAparicion(5)
	if pos then
		Enemigos.aparecer("Rey", pos)
		Estado.anunciar("EL REY DE LA NIEBLA", "Ha salido del mar... y la luz del fuego apenas le hace daño.")
	end
end

local function rondasDeDia()
	while true do
		task.wait(6)
		local etapa = Estado.get("Etapa") or 1
		local datosEtapa = Config.ETAPAS[3]
		if Estado.get("Fase") ~= "Dia" or etapa ~= 3 then
			continue
		end
		if contarDeDia() < (datosEtapa.enemigosDeDia or 0) then
			local pos = puntoAparicion(3)
			if pos then
				Enemigos.aparecer("Brumoso", pos, true)
			end
		end
	end
end

function Enemigos.iniciar()
	pcall(function()
		PhysicsService:RegisterCollisionGroup(GRUPO)
	end)
	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(GRUPO, GRUPO, false)
	end)

	carpeta = Instance.new("Folder")
	carpeta.Name = "Brumosos"
	carpeta.Parent = workspace
	Caminar.ignorar(carpeta)
	Caminar.ignorar(Recursos.carpeta)

	for _, p in CollectionService:GetTagged("PuntoEnemigo") do
		table.insert(puntos, p :: BasePart)
	end
	puntoJefe = CollectionService:GetTagged("PuntoJefe")[1]
	Estado.set("EnemigosVivos", 0)

	Estado.escuchar("NocheEmpieza", function(noche: number)
		oleada(CFG.BASE + CFG.POR_NOCHE * (noche - 1), Config.DURACION_NOCHE, "Noche")
	end)
	Estado.escuchar("UltimaNocheEmpieza", function()
		task.delay(Config.DURACION_ULTIMA_NOCHE * 0.25, aparecerJefe)
		oleada(CFG.ULTIMA_NOCHE, Config.DURACION_ULTIMA_NOCHE, "UltimaNoche")
	end)
	Estado.escuchar("NocheSobrevivida", function()
		deshacer(true)
	end)
	Estado.escuchar("Final", function()
		deshacer(false)
	end)
	Estado.escuchar("CampamentoEncendido", function(etapa: number)
		if etapa > 3 then
			for _, e in activos do
				if e.deDia then
					e.sinBotin = true
					e.hum.Health = 0
				end
			end
		end
	end)
	task.spawn(rondasDeDia)

	local avisado = false
	task.spawn(function()
		while true do
			task.wait(TICK)
			local objetivos = jugadoresVivos()
			local lia = Lia.objetivo()
			if lia then
				table.insert(objetivos, { esLia = true, raiz = lia })
			end
			for modelo, e in activos do
				if e.muerto or not modelo.Parent then
					activos[modelo] = nil
					continue
				end
				local ok, err = pcall(actualizar, e, objetivos)
				if not ok and not avisado then
					avisado = true
					warn("[Enemigos] Error en el comportamiento: " .. tostring(err))
				end
			end
		end
	end)
end

return Enemigos
