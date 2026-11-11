local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Caminar = require(script.Parent.Caminar)
local Cuerpos = require(script.Parent.Cuerpos)
local Estado = require(script.Parent.Estado)
local Fogata = require(script.Parent.Fogata)
local Inventario = require(script.Parent.Inventario)
local Recursos = require(script.Parent.Recursos)
local Ruta = require(script.Parent.Parent.Mundo.Ruta)
local Util = require(script.Parent.Parent.Mundo.Util)

local Lia = {}

local CFG = Config.LIA
local FRASES = Historia.LIA
local rgb = Color3.fromRGB
local V = Vector3.new
local TICK = 0.25

local modelo: Model
local hum: Humanoid
local raiz: BasePart
local agente
local pistas = {}
local lagrimas: ParticleEmitter
local burbuja: BillboardGui
local burbujaTexto: TextLabel
local botonHablar: ProximityPrompt
local botonComida: ProximityPrompt

local animo = CFG.ANIMO_INICIAL
local modo = "Siguiendo"
local siguiendo: Player? = nil
local sentada = false
local ocupadaHasta = 0
local idBurbuja = 0
local ultimaFrase = 0
local ultimaCharlaCamino = os.clock()
local ultimoHallazgo = os.clock()
local ultimoAvisoEnemigo = 0
local ultimoGolpe = 0
local ultimoAvisoFrio = 0
local lejosDesde: number? = nil
local alcanzando = false
local corriendo = false
local pararEn = CFG.DISTANCIA_SEGUIR
local curioseo: Vector3? = nil
local curioseoHasta = 0
local proximoCurioseo = os.clock() + 6
local hablado: { [Player]: number } = {}

local function elegir(lista)
	return lista[math.random(1, #lista)]
end

function Lia.decir(texto: string, duracion: number?)
	if not burbuja then
		return
	end
	idBurbuja += 1
	local este = idBurbuja
	burbujaTexto.Text = texto
	burbuja.Enabled = true
	ultimaFrase = os.clock()
	task.delay(duracion or math.clamp(#texto / 14, 3, 7), function()
		if idBurbuja == este then
			burbuja.Enabled = false
		end
	end)
end

function Lia.posicion(): Vector3?
	return if raiz then raiz.Position else nil
end

function Lia.modelo(): Model?
	return modelo
end

function Lia.estaProtegida(): boolean
	return raiz ~= nil and Fogata.estaProtegido(raiz.Position)
end

local function ponerEstado(nuevo: string)
	if Estado.get("EstadoLia") ~= nuevo then
		Estado.set("EstadoLia", nuevo)
	end
end

function Lia.cambiarAnimo(n: number)
	animo = math.clamp(animo + n, 0, CFG.ANIMO_MAXIMO)
	Estado.set("AnimoLia", math.floor(animo + 0.5))
end

local function sentar(cf: CFrame)
	sentada = true
	agente:parar()
	raiz.Anchored = true
	modelo:PivotTo(cf)
	if pistas.sentar and not pistas.sentar.IsPlaying then
		pistas.sentar:Play(0.3)
	end
end

local function levantar()
	if not sentada then
		return
	end
	sentada = false
	if pistas.sentar then
		pistas.sentar:Stop(0.3)
	end
	modelo:PivotTo(raiz.CFrame * CFrame.new(0, 1.2, -1.5))
	raiz.Anchored = false
	pcall(function()
		raiz:SetNetworkOwner(nil)
	end)
end

local function teletransportar(pos: Vector3)
	levantar()
	modelo:PivotTo(CFrame.new(Caminar.suelo(pos) + V(0, 2.4, 0)))
	agente:parar()
	lejosDesde = nil
	alcanzando = false
	corriendo = false
	curioseo = nil
end

local function sitioEnFuego(): CFrame?
	local c = Fogata.actual()
	if not c or not c.asiento then
		return nil
	end
	local asiento = c.asiento :: BasePart
	local arriba = asiento.Position + V(0, asiento.Size.Y / 2, 0) + asiento.CFrame.RightVector * 1.2
	local pos = arriba + V(0, 0.95, 0)
	local fuego = c.fuego.Position
	return CFrame.lookAt(pos, V(fuego.X, pos.Y, fuego.Z))
end

function Lia.sentarEnFuego(segundos: number)
	local cf = sitioEnFuego()
	if not cf then
		return
	end
	ocupadaHasta = os.clock() + segundos
	modo = "Sentada"
	ponerEstado("Sentada")
	sentar(cf)
end

function Lia.sentarJunto(cfBanco: CFrame, segundos: number)
	if not raiz or (raiz.Position - cfBanco.Position).Magnitude > 60 then
		return
	end
	ocupadaHasta = os.clock() + segundos
	modo = "Sentada"
	ponerEstado("Sentada")
	sentar(cfBanco * CFrame.new(1.6, 0.25 + 0.95, 0))
end

function Lia.tesoro(numero: number)
	local datos = Historia.TESOROS[numero]
	if datos then
		Lia.decir(datos.lia, 6)
	end
	Lia.cambiarAnimo(CFG.SUBE_TESORO)
end

function Lia.golpeada()
	local ahora = os.clock()
	if ahora - ultimoGolpe < 1.2 then
		return
	end
	ultimoGolpe = ahora
	Lia.cambiarAnimo(-CFG.GOLPE)
	Lia.decir(elegir(FRASES.golpe), 2.5)
	local resalte = Instance.new("Highlight")
	resalte.FillColor = rgb(160, 200, 255)
	resalte.FillTransparency = 0.4
	resalte.OutlineTransparency = 1
	resalte.Parent = modelo
	task.delay(0.25, function()
		resalte:Destroy()
	end)
end

function Lia.objetivo(): BasePart?
	if not raiz or Lia.estaProtegida() or Estado.get("Fase") == "Final" then
		return nil
	end
	return raiz
end

local function hablar(jugador: Player)
	if modo == "Asustada" then
		Lia.cambiarAnimo(CFG.SUBE_CONSOLAR)
		modo = "Siguiendo"
		siguiendo = jugador
		Lia.decir(elegir(FRASES.consolada), 4)
		Estado.notificar(jugador, "💛 Has consolado a Lía.", rgb(255, 220, 130))
		return
	end
	local ahora = os.clock()
	if not hablado[jugador] or ahora - hablado[jugador] > CFG.ESPERA_HABLAR then
		hablado[jugador] = ahora
		Lia.cambiarAnimo(CFG.SUBE_HABLAR)
	end
	local etapa = Config.etapaEn(raiz.Position.Z)
	if math.random() < 0.5 and FRASES.camino[etapa] then
		Lia.decir(elegir(FRASES.camino[etapa]))
	else
		Lia.decir(elegir(FRASES.hablar))
	end
end

local function darComida(jugador: Player)
	if Inventario.cantidad(jugador, "Comida") <= 0 then
		Estado.notificar(jugador, "No llevas comida para Lía.")
		return
	end
	if animo >= CFG.ANIMO_MAXIMO - 2 then
		Lia.decir(elegir(FRASES.lleno))
		return
	end
	Inventario.quitar(jugador, "Comida", 1)
	Lia.cambiarAnimo(CFG.SUBE_COMIDA)
	if modo == "Asustada" and animo >= CFG.ASUSTADA then
		modo = "Siguiendo"
		siguiendo = jugador
	end
	Lia.decir(elegir(FRASES.comer))
end

local function crearModelo(): Model
	local piel = rgb(236, 196, 164)
	local amarillo = rgb(246, 196, 44)
	local vaquero = rgb(70, 100, 160)
	local castano = rgb(102, 66, 40)
	return Cuerpos.crear({
		nombre = "Lía",
		escala = 0.78,
		vida = 100,
		velocidad = CFG.VELOCIDAD,
		colores = { cabeza = piel, torso = amarillo, brazos = amarillo, piernas = vaquero },
		cara = "rbxasset://textures/face.png",
		distanciaNombre = 45,
		grupo = "Lia",
		adornos = function(adorno, p, en)
			local M = Enum.Material
			adorno("Pelo", V(2.1, 0.45, 1.2), en(0, 2.12, 0.05), castano, M.Fabric, p.cabeza)
			adorno("Pelo", V(2.1, 1.1, 0.35), en(0, 1.6, 0.56), castano, M.Fabric, p.cabeza)
			for _, x in { -1.15, 1.15 } do
				adorno("Coleta", V(0.55, 1, 0.55), en(x, 1.4, 0.3), castano, M.Fabric, p.cabeza)
				adorno("Goma", V(0.6, 0.2, 0.6), en(x, 1.9, 0.3), rgb(230, 70, 110), M.SmoothPlastic, p.cabeza)
			end
			adorno("Capucha", V(1.5, 0.7, 0.5), en(0, 0.85, 0.66), amarillo, M.SmoothPlastic, p.torso)
			for _, y in { 0.5, 0, -0.5 } do
				adorno("Boton", V(0.2, 0.2, 0.1), en(0, y, -0.53), rgb(60, 60, 64), M.SmoothPlastic, p.torso)
			end
			adorno("Mano", V(1.02, 0.35, 1.02), en(1.5, -0.85, 0), piel, M.SmoothPlastic, p.brazoD)
			adorno("Mano", V(1.02, 0.35, 1.02), en(-1.5, -0.85, 0), piel, M.SmoothPlastic, p.brazoI)
			adorno("Mochila", V(1.4, 1.5, 0.6), en(0, -0.05, 0.8), rgb(130, 80, 170), M.Fabric, p.torso)
			adorno("Llavero", V(0.3, 0.3, 0.1), en(0.5, -0.6, 1.12), rgb(255, 210, 90), M.SmoothPlastic, p.torso)
			adorno("Bota", V(1.06, 0.7, 1.16), en(0.5, -2.66, -0.05), rgb(200, 40, 40), M.SmoothPlastic, p.piernaD)
			adorno("Bota", V(1.06, 0.7, 1.16), en(-0.5, -2.66, -0.05), rgb(200, 40, 40), M.SmoothPlastic, p.piernaI)
		end,
	})
end

local function crearBurbuja(cabeza: BasePart)
	burbuja = Instance.new("BillboardGui")
	burbuja.Name = "Bocadillo"
	burbuja.Size = UDim2.fromOffset(250, 70)
	burbuja.StudsOffset = V(0, 2.8, 0)
	burbuja.MaxDistance = 70
	burbuja.LightInfluence = 0
	burbuja.Enabled = false
	burbuja.Parent = cabeza
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = rgb(255, 252, 240)
	fondo.BackgroundTransparency = 0.05
	fondo.Parent = burbuja
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, 12)
	esquinas.Parent = fondo
	local borde = Instance.new("UIStroke")
	borde.Color = rgb(246, 196, 44)
	borde.Thickness = 2
	borde.Parent = fondo
	burbujaTexto = Instance.new("TextLabel")
	burbujaTexto.Size = UDim2.new(1, -16, 1, -10)
	burbujaTexto.Position = UDim2.fromOffset(8, 5)
	burbujaTexto.BackgroundTransparency = 1
	burbujaTexto.Font = Enum.Font.GothamMedium
	burbujaTexto.TextColor3 = rgb(50, 40, 30)
	burbujaTexto.TextScaled = true
	burbujaTexto.TextWrapped = true
	burbujaTexto.Text = ""
	burbujaTexto.Parent = fondo
	local limite = Instance.new("UITextSizeConstraint")
	limite.MaxTextSize = 17
	limite.Parent = burbujaTexto
end

local function jugadorMasCercano(): (Player?, BasePart?, number)
	local mejor, mejorRaiz, mejorDist = nil, nil, math.huge
	for _, j in Players:GetPlayers() do
		local r = Inventario.raiz(j)
		if r then
			local d = (r.Position - raiz.Position).Magnitude
			if j == siguiendo then
				d -= 20
			end
			if d < mejorDist then
				mejor, mejorRaiz, mejorDist = j, r, d
			end
		end
	end
	if mejorRaiz then
		mejorDist = (mejorRaiz.Position - raiz.Position).Magnitude
	end
	return mejor, mejorRaiz, mejorDist
end

local function seguirA(objetivo: BasePart, distancia: number, cerca: number, lejos: number)
	if distancia > lejos then
		alcanzando = true
	end
	if alcanzando then
		if distancia <= cerca then
			alcanzando = false
			corriendo = false
			agente:parar()
		else
			levantar()
			curioseo = nil
			corriendo = distancia > CFG.DISTANCIA_CORRER or (corriendo and distancia > cerca + 4)
			hum.WalkSpeed = if corriendo then CFG.VELOCIDAD_CORRER else CFG.VELOCIDAD
			agente:ir(objetivo.Position)
		end
	end
	if distancia > CFG.DISTANCIA_PERDIDA then
		lejosDesde = lejosDesde or os.clock()
		if os.clock() - (lejosDesde :: number) > 5 or distancia > 170 then
			local atras = objetivo.Position - objetivo.CFrame.LookVector * 5
			teletransportar(if Ruta.caminable(atras) then atras else objetivo.Position)
			Lia.decir(elegir(FRASES.perdida), 3)
		end
	else
		lejosDesde = nil
	end
end

local function enemigoCerca(): boolean
	for _, enemigo in CollectionService:GetTagged("Enemigo") do
		local r = enemigo:FindFirstChild("HumanoidRootPart") :: BasePart?
		if r and (r.Position - raiz.Position).Magnitude < 22 then
			return true
		end
	end
	return false
end

local function sitioSeguro(punto: Vector3, objetivo: BasePart): Vector3?
	if not Ruta.caminable(punto) then
		return nil
	end
	if Util.dist2D(punto, objetivo.Position) > CFG.DISTANCIA_ALEJARSE - 3 then
		return nil
	end
	if Fogata.arde() and Util.dist2D(punto, Fogata.centro()) < 6 then
		return nil
	end
	local suelo = workspace:Raycast(punto + V(0, 6, 0), V(0, -40, 0), Caminar.params)
	if not suelo or suelo.Material == Enum.Material.Water then
		return nil
	end
	local pies = raiz.Position.Y - 2.4
	if math.abs(suelo.Position.Y - pies) > 3 then
		return nil
	end
	local destino = suelo.Position + V(0, 0.6, 0)
	if not Caminar.hayVision(raiz.Position, destino + V(0, 2, 0)) then
		return nil
	end
	return destino
end

local function pasearCerca(objetivo: BasePart, distancia: number)
	local ahora = os.clock()
	if enemigoCerca() then
		curioseo = nil
		proximoCurioseo = ahora + 8
		seguirA(objetivo, distancia, 5, 8)
		return
	end
	if not alcanzando and distancia > CFG.DISTANCIA_ALEJARSE then
		pararEn = CFG.DISTANCIA_SEGUIR + math.random(-2, 5)
	end
	local estabaAlcanzando = alcanzando
	seguirA(objetivo, distancia, pararEn, CFG.DISTANCIA_ALEJARSE)
	if alcanzando then
		return
	end
	if estabaAlcanzando then
		proximoCurioseo = ahora + math.random(CFG.CURIOSEAR_CADA[1], CFG.CURIOSEAR_CADA[2])
		return
	end

	if distancia < 6 then
		if curioseo then
			curioseo = nil
			agente:parar()
		end
		proximoCurioseo = math.max(proximoCurioseo, ahora + 4)
		return
	end

	if curioseo then
		local llegada = (raiz.Position - curioseo).Magnitude < 2.5
		if llegada or ahora > curioseoHasta or not Ruta.caminable(raiz.Position) then
			curioseo = nil
			agente:parar()
			proximoCurioseo = ahora + math.random(CFG.CURIOSEAR_CADA[1], CFG.CURIOSEAR_CADA[2])
		else
			levantar()
			hum.WalkSpeed = CFG.VELOCIDAD * 0.55
			agente:ir(curioseo :: Vector3)
		end
	elseif ahora > proximoCurioseo then
		for _ = 1, 4 do
			local angulo = math.random() * math.pi * 2
			local radio = math.random(5, 11)
			local punto = raiz.Position + V(math.cos(angulo) * radio, 0, math.sin(angulo) * radio)
			local destino = sitioSeguro(punto, objetivo)
			if destino then
				curioseo = destino
				curioseoHasta = ahora + 5
				return
			end
		end
		proximoCurioseo = ahora + 2
	end
end

local function actualizar()
	local ahora = os.clock()
	local fase = Estado.get("Fase")
	local noche = Estado.esNoche()

	if raiz.Position.Y < -12 then
		local _, r = jugadorMasCercano()
		teletransportar(if r and r.Position.Y > -5 then r.Position else Fogata.puntoSeguro())
		return
	end

	if modo == "Sentada" then
		if ahora < ocupadaHasta then
			return
		end
		modo = "Siguiendo"
		levantar()
	end

	local jugador, objetivo, distancia = jugadorMasCercano()
	siguiendo = jugador

	if fase == "Final" then
		local cf = sitioEnFuego()
		if cf and not sentada then
			if (raiz.Position - cf.Position).Magnitude > 4 then
				hum.WalkSpeed = CFG.VELOCIDAD
				agente:ir(cf.Position)
			else
				sentar(cf)
			end
		end
		ponerEstado("Fuego")
		return
	end

	if modo ~= "Asustada" and animo < CFG.ASUSTADA and not noche then
		modo = "Asustada"
		agente:parar()
		Lia.decir(elegir(FRASES.asustada), 5)
	elseif modo == "Asustada" and animo >= CFG.ASUSTADA + 15 then
		modo = "Siguiendo"
	end
	lagrimas.Enabled = modo == "Asustada" or animo < CFG.ASUSTADA

	if modo == "Asustada" and not noche then
		ponerEstado("Asustada")
		curioseo = nil
		agente:parar()
		if ahora - ultimaFrase > 18 then
			Lia.decir(elegir(FRASES.asustada), 4)
		end
		return
	end

	if not objetivo then
		ponerEstado("Esperando")
		agente:parar()
		return
	end

	if noche then
		local cf = sitioEnFuego()
		local cercaDelFuego = Fogata.arde() and Util.dist2D(objetivo.Position, Fogata.centro()) < Fogata.radio() + 18
		if cf and cercaDelFuego then
			ponerEstado("Fuego")
			if not sentada then
				if (raiz.Position - cf.Position).Magnitude > 3.5 then
					hum.WalkSpeed = CFG.VELOCIDAD_CORRER
					agente:ir(cf.Position)
				else
					sentar(cf)
				end
			end
			return
		end
		ponerEstado("Cerca")
		curioseo = nil
		seguirA(objetivo, distancia, 4, 6)
		return
	end

	ponerEstado("Siguiendo")
	pasearCerca(objetivo, distancia)

	if ahora - ultimaCharlaCamino > math.random(55, 85) and ahora - ultimaFrase > 20 then
		ultimaCharlaCamino = ahora
		local etapa = Config.etapaEn(raiz.Position.Z)
		Lia.decir(elegir(FRASES.camino[etapa] or FRASES.hablar))
	end

	if animo >= CFG.CONTENTA and ahora - ultimoHallazgo > CFG.BUSCAR_CADA then
		ultimoHallazgo = ahora
		local recurso = elegir({ "Comida", "Fibra", "Piedra", "Lena", "Comida" })
		Recursos.soltar(recurso, Caminar.suelo(raiz.Position + raiz.CFrame.LookVector * 2), 1 + (if math.random() < 0.3 then 1 else 0))
		Lia.decir(elegir(FRASES.encontrar), 3)
	end
end

local function animoPorSegundo()
	if Estado.get("Fase") == "Final" then
		return
	end
	local cambio = 0
	local protegida = Lia.estaProtegida()
	if Estado.esNoche() then
		cambio += if protegida then 0.2 else -CFG.BAJA_OSCURIDAD
	else
		cambio -= CFG.BAJA_DIA
	end
	if enemigoCerca() and not protegida then
		cambio -= CFG.BAJA_ENEMIGO
		if os.clock() - ultimoAvisoEnemigo > 20 then
			ultimoAvisoEnemigo = os.clock()
			Lia.decir(elegir(FRASES.enemigo), 2.5)
		end
	end
	if Inventario.haceFrio(raiz.Position) and not protegida then
		cambio -= CFG.BAJA_FRIO
		if os.clock() - ultimoAvisoFrio > 45 and os.clock() - ultimaFrase > 10 then
			ultimoAvisoFrio = os.clock()
			Lia.decir(elegir(FRASES.frio), 3)
		end
	end
	if modo == "Sentada" then
		cambio = math.max(cambio, 0)
	end
	Lia.cambiarAnimo(cambio)
end

function Lia.iniciar()
	pcall(function()
		PhysicsService:RegisterCollisionGroup("Lia")
		PhysicsService:RegisterCollisionGroup("Jugadores")
		PhysicsService:CollisionGroupSetCollidable("Lia", "Jugadores", false)
	end)
	local function grupoJugador(personaje: Model)
		for _, d in personaje:GetDescendants() do
			if d:IsA("BasePart") then
				d.CollisionGroup = "Jugadores"
			end
		end
		personaje.DescendantAdded:Connect(function(d)
			if d:IsA("BasePart") then
				d.CollisionGroup = "Jugadores"
			end
		end)
	end
	local function alEntrar(jugador: Player)
		jugador.CharacterAdded:Connect(grupoJugador)
		if jugador.Character then
			grupoJugador(jugador.Character)
		end
	end
	Players.PlayerAdded:Connect(alEntrar)
	for _, j in Players:GetPlayers() do
		alEntrar(j)
	end
	Players.PlayerRemoving:Connect(function(j)
		hablado[j] = nil
	end)

	modelo = crearModelo()
	hum = modelo:FindFirstChildOfClass("Humanoid") :: Humanoid
	raiz = modelo:FindFirstChild("HumanoidRootPart") :: BasePart
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	hum.BreakJointsOnDeath = false
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	modelo:PivotTo(CFrame.new(Ruta.SITIOS.inicio + V(5, 2.8, -2)) * CFrame.Angles(0, math.rad(200), 0))
	modelo.Parent = workspace
	pcall(function()
		raiz:SetNetworkOwner(nil)
	end)
	CollectionService:AddTag(modelo, "Lia")
	Caminar.ignorar(modelo)

	agente = Caminar.nuevo(hum, raiz, { radio = 1.5, alto = 4 })
	pistas = Cuerpos.animar(hum, CFG.VELOCIDAD)
	crearBurbuja(modelo:FindFirstChild("Head") :: BasePart)

	lagrimas = Instance.new("ParticleEmitter")
	lagrimas.Color = ColorSequence.new(rgb(150, 200, 255))
	lagrimas.Size = NumberSequence.new(0.15)
	lagrimas.Lifetime = NumberRange.new(0.5, 0.8)
	lagrimas.Rate = 6
	lagrimas.Speed = NumberRange.new(1, 2)
	lagrimas.SpreadAngle = Vector2.new(30, 30)
	lagrimas.Acceleration = V(0, -18, 0)
	lagrimas.Enabled = false
	lagrimas.Parent = modelo:FindFirstChild("Head")

	botonHablar = Instance.new("ProximityPrompt")
	botonHablar.ActionText = "Hablar"
	botonHablar.ObjectText = "👧 Lía"
	botonHablar.KeyboardKeyCode = Enum.KeyCode.E
	botonHablar.MaxActivationDistance = 10
	botonHablar.RequiresLineOfSight = false
	botonHablar.Parent = raiz
	botonHablar.Triggered:Connect(hablar)

	botonComida = Instance.new("ProximityPrompt")
	botonComida.ActionText = "Darle comida (🍎 1)"
	botonComida.ObjectText = "👧 Lía"
	botonComida.KeyboardKeyCode = Enum.KeyCode.R
	botonComida.HoldDuration = 0.3
	botonComida.MaxActivationDistance = 10
	botonComida.RequiresLineOfSight = false
	botonComida.UIOffset = Vector2.new(0, 70)
	botonComida.Parent = raiz
	botonComida.Triggered:Connect(darComida)

	Fogata.posicionLia = Lia.posicion
	Estado.set("AnimoLia", animo)
	Estado.set("EstadoLia", "Siguiendo")

	task.delay(4, function()
		Lia.decir(FRASES.inicio[1], 4)
		task.wait(5)
		Lia.decir(FRASES.inicio[2], 5)
	end)
	Estado.escuchar("CampamentoEncendido", function(etapa: number)
		Lia.cambiarAnimo(CFG.SUBE_CAMPAMENTO)
		Lia.decir(FRASES.campamento[etapa] or elegir(FRASES.hablar), 6)
	end)
	Estado.escuchar("PasoDespejado", function(etapa: number)
		Lia.cambiarAnimo(CFG.SUBE_PASO)
		if FRASES.paso[etapa] then
			Lia.decir(FRASES.paso[etapa], 5)
		end
	end)
	Estado.escuchar("NocheEmpieza", function()
		Lia.decir(elegir(FRASES.noche), 4)
	end)
	Estado.escuchar("DiaEmpieza", function(dia: number)
		if dia > 1 then
			Lia.decir(elegir(FRASES.amanecer), 4)
		end
	end)
	Estado.escuchar("FuegoBajo", function()
		Lia.decir(elegir(FRASES.fuegoBajo), 3)
	end)
	Estado.escuchar("FuegoApagado", function()
		Lia.decir(elegir(FRASES.fuegoApagado), 3)
	end)
	Estado.escuchar("FaroEncendido", function()
		Lia.cambiarAnimo(30)
		Lia.decir(FRASES.faro, 6)
	end)
	Estado.escuchar("Final", function()
		Lia.cambiarAnimo(100)
		task.delay(8, function()
			Lia.decir(FRASES.final, 8)
		end)
	end)

	task.spawn(function()
		local avisado = false
		while true do
			task.wait(TICK)
			local ok, err = pcall(actualizar)
			if not ok and not avisado then
				avisado = true
				warn("[Lía] Error: " .. tostring(err))
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			pcall(animoPorSegundo)
			botonHablar.ActionText = if modo == "Asustada" then "Consolar" else "Hablar"
		end
	end)
end

return Lia
