local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Armas = require(script.Parent.Armas)
local Ciclo = require(script.Parent.Ciclo)
local Estado = require(script.Parent.Estado)
local Fogata = require(script.Parent.Fogata)
local Inventario = require(script.Parent.Inventario)
local Recursos = require(script.Parent.Recursos)
local Ruta = require(script.Parent.Parent.Mundo.Ruta)
local Util = require(script.Parent.Parent.Mundo.Util)

local Obstaculos = {}

local rgb = Color3.fromRGB
local V = Vector3.new
local avisos: { [Player]: number } = {}

local function avisar(jugador: Player, texto: string)
	local ahora = os.clock()
	if avisos[jugador] and ahora - avisos[jugador] < 3 then
		return
	end
	avisos[jugador] = ahora
	Estado.notificar(jugador, texto)
end

local function quitarBloqueo(modelo: Instance)
	local bloqueo = modelo:FindFirstChild("Bloqueo")
	if bloqueo then
		bloqueo:Destroy()
	end
end

local SIGUIENTE = {
	[1] = "Seguid el sendero hacia El Río",
	[2] = "Cruzad el puente hacia el Bosque Negro",
	[3] = "Atravesad la cueva hacia el Paso Nevado",
	[4] = "Bajad hacia la costa: el faro está cerca",
}

local function despejar(etapa: number, jugador: Player?)
	if Estado.get("Paso_" .. etapa) then
		return
	end
	Estado.set("Paso_" .. etapa, true)
	Estado.anunciar("¡EL CAMINO ESTÁ LIBRE!", SIGUIENTE[etapa] .. ". Encended allí la hoguera del próximo campamento.")
	if jugador then
		Estado.notificar(nil, "🎉 " .. jugador.DisplayName .. " ha despejado el camino.", rgb(150, 230, 120))
	end
	Estado.emitir("PasoDespejado", etapa)
end

local function iniciarTronco()
	local modelo = CollectionService:GetTagged("Tronco")[1]
	if not modelo then
		return
	end
	local vida = Config.PASOS.TRONCO_VIDA
	Estado.escuchar("GolpeTronco", function(jugador: Player, stats)
		if Estado.get("Paso_1") or vida <= 0 then
			return
		end
		if not stats.troncos then
			avisar(jugador, "Este tronco es demasiado gordo para eso. Fabrica un hacha de piedra en la mesa del campamento.")
			return
		end
		vida -= stats.tala
		local tronco = modelo.PrimaryPart
		if vida > 0 then
			Estado.notificar(jugador, string.format("🪓 ¡Toc! Al tronco le queda %d", math.ceil(vida)))
			if tronco then
				local astillas = Instance.new("ParticleEmitter")
				astillas.Color = ColorSequence.new(rgb(200, 160, 110))
				astillas.Size = NumberSequence.new(0.3, 0.1)
				astillas.Lifetime = NumberRange.new(0.5, 1)
				astillas.Speed = NumberRange.new(8, 14)
				astillas.SpreadAngle = Vector2.new(60, 60)
				astillas.Acceleration = V(0, -30, 0)
				astillas.Enabled = false
				astillas.Parent = tronco
				astillas:Emit(14)
				task.delay(1.5, function()
					astillas:Destroy()
				end)
			end
			return
		end
		local centro = if tronco then tronco.Position else Ruta.SITIOS.tronco
		quitarBloqueo(modelo)
		Util.desvanecer(modelo, 0.6)
		for _, lado in { -1, 1 } do
			local mitad = Util.cilindro(
				workspace,
				5,
				10,
				CFrame.new(centro.X + lado * 9, 2.5, centro.Z - 2) * CFrame.Angles(0, math.rad(90 + lado * 12), 0),
				rgb(96, 70, 48),
				Enum.Material.Wood
			)
			mitad.Name = "MitadTronco"
			mitad.Transparency = 1
			TweenService:Create(mitad, TweenInfo.new(0.6), { Transparency = 0 }):Play()
		end
		for i = 1, 3 do
			Recursos.soltar("Lena", V(centro.X - 3 + i * 1.5, 0.6, centro.Z - 6), 1)
		end
		despejar(1, jugador)
	end)
end

local function iniciarPuente()
	local modelo = CollectionService:GetTagged("Puente")[1]
	if not modelo then
		return
	end
	local coste = Config.PASOS.PUENTE
	local rotas = {}
	for _, d in modelo:GetChildren() do
		if d.Name == "Tabla" and d:GetAttribute("Rota") then
			table.insert(rotas, d)
		end
	end
	local total = #rotas
	table.sort(rotas, function(a, b)
		local oa, ob = a:GetAttribute("Orden"), b:GetAttribute("Orden")
		local n = 24
		return math.min(oa, n - 1 - oa) < math.min(ob, n - 1 - ob)
	end)
	Estado.set("PuenteCuerda", 0)
	Estado.set("PuenteLena", 0)

	local function pintar()
		local lena = Estado.get("PuenteLena") or 0
		local visibles = math.floor(total * lena / coste.Lena)
		for i, tabla in rotas do
			if i <= visibles and tabla.Transparency > 0.5 then
				tabla.CanCollide = true
				TweenService:Create(tabla, TweenInfo.new(0.4), { Transparency = 0 }):Play()
			end
		end
		if (Estado.get("PuenteCuerda") or 0) >= coste.Cuerda then
			for _, d in modelo:GetChildren() do
				if d.Name == "Cuerda" then
					d.Transparency = 0
				elseif d.Name == "CuerdaRota" then
					d:Destroy()
				end
			end
		end
	end

	local poste = modelo.PrimaryPart :: BasePart
	local prompt = Util.prompt(poste, "Reparar puente", "🌉 Puente colgante", 0.6, 10)
	prompt.Triggered:Connect(function(jugador)
		if Estado.get("Paso_2") then
			return
		end
		local faltaCuerda = coste.Cuerda - (Estado.get("PuenteCuerda") or 0)
		local faltaLena = coste.Lena - (Estado.get("PuenteLena") or 0)
		local cuerda = math.min(Inventario.cantidad(jugador, "Cuerda"), faltaCuerda)
		local lena = math.min(Inventario.cantidad(jugador, "Lena"), faltaLena)
		if cuerda <= 0 and lena <= 0 then
			Estado.notificar(
				jugador,
				string.format(
					"Para reparar el puente faltan 🪢 %d cuerdas y 🪵 %d de leña. Las cuerdas se fabrican con fibra en la mesa del campamento.",
					faltaCuerda,
					faltaLena
				)
			)
			return
		end
		Inventario.quitar(jugador, "Cuerda", cuerda)
		Inventario.quitar(jugador, "Lena", lena)
		Estado.sumar("PuenteCuerda", cuerda)
		Estado.sumar("PuenteLena", lena)
		pintar()
		faltaCuerda -= cuerda
		faltaLena -= lena
		if faltaCuerda <= 0 and faltaLena <= 0 then
			for _, tabla in rotas do
				tabla.CanCollide = true
				tabla.Transparency = 0
			end
			for _, d in modelo:GetChildren() do
				if d.Name == "Barandilla" then
					(d :: BasePart).CanCollide = true
				end
			end
			prompt.Enabled = false
			despejar(2, jugador)
		else
			Estado.notificar(jugador, string.format("🌉 ¡Bien! Todavía faltan 🪢 %d cuerdas y 🪵 %d de leña.", faltaCuerda, faltaLena))
		end
	end)
end

local function iniciarTelaranas()
	local modelo = CollectionService:GetTagged("Telaranas")[1]
	if not modelo then
		return
	end
	local bloqueo = modelo.PrimaryPart :: BasePart
	local prompt = Util.prompt(bloqueo, "Quemar telarañas", "🕸️ Telarañas de bruma", 1.5, 12)
	prompt.Triggered:Connect(function(jugador)
		if Estado.get("Paso_3") then
			return
		end
		if not Armas.llevaAntorcha(jugador) then
			Estado.notificar(jugador, "Las telarañas están heladas y pegajosas. Hay que quemarlas: saca una antorcha (fabrícala en la mesa del campamento).")
			return
		end
		prompt.Enabled = false
		local fuego = Instance.new("Fire")
		fuego.Size = 16
		fuego.Heat = 12
		fuego.Color = rgb(255, 140, 50)
		fuego.Parent = bloqueo
		for _, d in modelo:GetChildren() do
			if d.Name == "Hilo" and d:IsA("BasePart") then
				TweenService:Create(d, TweenInfo.new(2), { Transparency = 1, Color = rgb(255, 120, 40) }):Play()
			end
		end
		task.delay(2.2, function()
			modelo:Destroy()
			despejar(3, jugador)
		end)
	end)
end

local function iniciarBarrera()
	local llave = CollectionService:GetTagged("LlaveGuarda")[1]
	if llave and llave.PrimaryPart then
		local prompt = Util.prompt(llave.PrimaryPart, "Coger", "🗝️ Llave del guarda", 0, 9)
		prompt.Triggered:Connect(function(jugador)
			if Estado.get("LlaveGuarda") then
				return
			end
			Estado.set("LlaveGuarda", true)
			llave:Destroy()
			Estado.notificar(nil, "🗝️ " .. jugador.DisplayName .. " ha encontrado la llave del guarda. ¡Ya se puede abrir la barrera del paso!", rgb(255, 220, 130))
		end)
	end

	local modelo = CollectionService:GetTagged("Barrera")[1]
	local hoja = modelo and modelo:FindFirstChild("Hoja") :: Model?
	if not modelo or not hoja or not hoja.PrimaryPart then
		return
	end
	local prompt = Util.prompt(hoja.PrimaryPart, "Abrir la barrera", "🚧 Barrera del Paso Nevado", 0.8, 10)
	prompt.Triggered:Connect(function(jugador)
		if Estado.get("Paso_4") then
			return
		end
		if not Estado.get("LlaveGuarda") then
			Estado.notificar(jugador, "Está cerrada con candado. La llave está en lo alto de la torre de vigilancia.")
			return
		end
		prompt.Enabled = false
		quitarBloqueo(modelo)
		Util.pivotar(hoja, hoja:GetPivot() * CFrame.Angles(0, math.rad(95), 0), 2.5)
		despejar(4, jugador)
	end)
end

local function encenderFaro(jugador: Player, faro: Model)
	Estado.set("FaroEncendido", true)
	local lampara = faro.PrimaryPart :: BasePart
	lampara.Material = Enum.Material.Neon
	local luz = lampara:FindFirstChildOfClass("PointLight")
	if luz then
		luz.Enabled = true
	end
	Estado.notificar(nil, "🗼 " .. jugador.DisplayName .. " ha encendido el faro de la abuela.", rgb(255, 230, 150))
	Estado.emitir("FaroEncendido")
	Ciclo.empezarUltimaNoche()
end

local function iniciarFaro()
	for _, bidon in CollectionService:GetTagged("Aceite") do
		local cuerpo = bidon.PrimaryPart
		if not cuerpo then
			continue
		end
		local prompt = Util.prompt(cuerpo, "Coger", "🛢️ Bidón de aceite", 0.4, 9)
		prompt.Triggered:Connect(function(jugador)
			if not bidon.Parent then
				return
			end
			bidon:Destroy()
			local n = Estado.sumar("AceiteEncontrado", 1)
			Estado.notificar(nil, string.format("🛢️ %s ha encontrado un bidón de aceite (%d/%d)", jugador.DisplayName, n, Config.FARO.ACEITE), rgb(255, 200, 140))
		end)
	end

	local faro = CollectionService:GetTagged("Faro")[1]
	if not faro or not faro.PrimaryPart then
		return
	end
	Estado.set("AceiteEncontrado", 0)
	Estado.set("FaroLena", 0)
	Estado.set("FaroEncendido", false)
	local prompt = Util.prompt(faro.PrimaryPart, "Encender el faro", "🗼 Lámpara del faro", 1, 14)
	prompt.Triggered:Connect(function(jugador)
		if Estado.get("FaroEncendido") then
			return
		end
		if (Estado.get("Etapa") or 1) < #Config.ETAPAS or not Estado.get("CampamentoEncendido") then
			Estado.notificar(jugador, "Antes encended la hoguera del campamento de la casa de la abuela: esta noche será vuestro refugio.")
			return
		end
		local aceite = Estado.get("AceiteEncontrado") or 0
		if aceite < Config.FARO.ACEITE then
			Estado.notificar(jugador, string.format("La lámpara está seca. Faltan bidones de aceite (%d/%d).", aceite, Config.FARO.ACEITE))
			return
		end
		local falta = Config.FARO.LENA - (Estado.get("FaroLena") or 0)
		local lena = math.min(Inventario.cantidad(jugador, "Lena"), falta)
		if lena <= 0 and falta > 0 then
			Estado.notificar(jugador, string.format("Hace falta leña para la lámpara: 🪵 %d más.", falta))
			return
		end
		Inventario.quitar(jugador, "Lena", lena)
		Estado.sumar("FaroLena", lena)
		falta -= lena
		if falta > 0 then
			Estado.notificar(jugador, string.format("🗼 Todavía faltan 🪵 %d de leña para encender la lámpara.", falta))
			return
		end
		prompt.Enabled = false
		encenderFaro(jugador, faro)
	end)

	Estado.escuchar("Final", function()
		local barco = CollectionService:GetTagged("BarcoFinal")[1]
		local destino = barco and barco:GetAttribute("Destino")
		if barco and typeof(destino) == "CFrame" then
			Util.pivotar(barco, destino, 28)
		end
		task.delay(14, function()
			Estado.remotos.Victoria:FireAllClients()
		end)
	end)
end

local function rescates()
	while true do
		task.wait(0.5)
		for _, jugador in Players:GetPlayers() do
			local raiz = Inventario.raiz(jugador)
			if raiz then
				local p = raiz.Position
				local fuera = math.abs(p.X) > Ruta.ANCHO + 30 or p.Z < Ruta.Z_INICIO - 30 or p.Z > Ruta.Z_FINAL + 4
				if p.Y < -14 or fuera then
					raiz.AssemblyLinearVelocity = Vector3.zero
					local personaje = jugador.Character :: Model
					personaje:PivotTo(CFrame.new(Fogata.puntoSeguro()))
					Estado.notificar(jugador, "🌊 La corriente te arrastra... y acabas de vuelta en el campamento, empapado y temblando.", rgb(150, 200, 255))
				end
			end
		end
	end
end

local function nuevaPartida(jugador: Player)
	if Estado.get("Fase") ~= "Final" or Estado.get("Reiniciando") then
		return
	end
	Estado.set("Reiniciando", true)
	Estado.notificar(nil, "🔁 " .. jugador.DisplayName .. " quiere empezar un viaje nuevo. Preparaos...", rgb(255, 230, 150))
	task.wait(4)
	local ok, err = pcall(function()
		local opciones = Instance.new("TeleportOptions")
		opciones.ShouldReserveServer = true
		TeleportService:TeleportAsync(game.PlaceId, Players:GetPlayers(), opciones)
	end)
	if not ok then
		Estado.set("Reiniciando", false)
		Estado.notificar(nil, "No se pudo empezar otro viaje (en Studio no funciona; en el juego publicado sí).", rgb(255, 140, 120))
		warn("[Obstaculos] Nueva partida: " .. tostring(err))
	end
end

function Obstaculos.iniciar()
	iniciarTronco()
	iniciarPuente()
	iniciarTelaranas()
	iniciarBarrera()
	iniciarFaro()
	task.spawn(rescates)
	Estado.remotos.NuevaPartida.OnServerEvent:Connect(nuevaPartida)
	Players.PlayerRemoving:Connect(function(j)
		avisos[j] = nil
	end)
end

return Obstaculos
