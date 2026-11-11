local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)
local Inventario = require(script.Parent.Inventario)
local Util = require(script.Parent.Parent.Mundo.Util)

local Recursos = {}

local CFG = Config.RECURSOS
local rgb = Color3.fromRGB
local carpeta: Folder

local function aviso(jugador: Player, recurso: string, n: number)
	Estado.notificar(jugador, string.format("+%d %s %s", n, Config.ICONOS_RECURSOS[recurso], Config.NOMBRES_RECURSOS[recurso]))
end

local function mostrarPiezas(piezas: { BasePart }, visibles: number)
	for i, p in piezas do
		p.Transparency = if i <= visibles then 0 else 1
	end
end

local function piezasLlamadas(modelo: Instance, nombre: string): { BasePart }
	local lista = {}
	for _, d in modelo:GetChildren() do
		if d.Name == nombre and d:IsA("BasePart") then
			table.insert(lista, d)
		end
	end
	return lista
end

function Recursos.soltar(recurso: string, pos: Vector3, cantidad: number?)
	local n = cantidad or 1
	local parte
	if recurso == "Lena" then
		parte = Util.cilindro(carpeta, 0.9, 3, CFrame.new(pos) * CFrame.Angles(0, math.random() * 3, 0), rgb(120, 82, 50), Enum.Material.Wood)
	elseif recurso == "Comida" then
		parte = Util.bola(carpeta, 1, pos, rgb(200, 40, 50), Enum.Material.SmoothPlastic)
	elseif recurso == "Piedra" then
		parte = Util.elipsoide(carpeta, Vector3.new(1.4, 0.9, 1.2), pos, rgb(140, 138, 132), Enum.Material.Slate)
	elseif recurso == "Fibra" then
		parte = Util.bloque(carpeta, Vector3.new(0.8, 0.6, 2), CFrame.new(pos) * CFrame.Angles(0, math.random() * 3, 0), rgb(90, 150, 70), Enum.Material.Grass)
	else
		parte = Util.cilindro(carpeta, 1.4, 0.6, CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2), rgb(196, 170, 120), Enum.Material.Fabric)
	end
	parte.Name = "Suelto_" .. recurso
	parte.CanCollide = false
	local prompt = Util.prompt(parte, "Recoger", Config.ICONOS_RECURSOS[recurso] .. " " .. Config.NOMBRES_RECURSOS[recurso], 0, 9)
	prompt.Triggered:Connect(function(jugador)
		if not parte.Parent then
			return
		end
		parte:Destroy()
		Inventario.dar(jugador, recurso, n)
		aviso(jugador, recurso, n)
	end)
	task.delay(CFG.DURACION_SUELTO, function()
		if parte.Parent then
			parte:Destroy()
		end
	end)
	return parte
end

local function iniciarRamas()
	local porEtapa = {}
	for _, p in CollectionService:GetTagged("PuntoRama") do
		local etapa = p:GetAttribute("Etapa") or 1
		porEtapa[etapa] = porEtapa[etapa] or { puntos = {}, ocupados = {}, cuantas = 0 }
		table.insert(porEtapa[etapa].puntos, p)
	end

	local function crearRama(grupo)
		local libres = {}
		for _, p in grupo.puntos do
			if not grupo.ocupados[p] then
				table.insert(libres, p)
			end
		end
		if #libres == 0 then
			return
		end
		local punto = libres[math.random(1, #libres)]
		grupo.ocupados[punto] = true
		grupo.cuantas += 1
		local pos = punto.Position
		local rama = Util.cilindro(
			carpeta,
			0.55,
			math.random(28, 40) / 10,
			CFrame.new(pos.X, pos.Y - 0.1, pos.Z) * CFrame.Angles(0, math.random() * 6, 0),
			rgb(110, 76, 48),
			Enum.Material.Wood
		)
		rama.Name = "Rama"
		rama.CanCollide = false
		Util.cilindro(carpeta, 0.3, 1.4, rama.CFrame * CFrame.new(0.5, 0, 0.5) * CFrame.Angles(0, 0.8, 0), rgb(110, 76, 48), Enum.Material.Wood, {
			Deco = true,
			Parent = rama,
		})
		local prompt = Util.prompt(rama, "Recoger", "🪵 Rama", 0.2, 9)
		prompt.Triggered:Connect(function(jugador)
			if not rama.Parent then
				return
			end
			rama:Destroy()
			grupo.ocupados[punto] = nil
			grupo.cuantas -= 1
			Inventario.dar(jugador, "Lena", 1)
			aviso(jugador, "Lena", 1)
		end)
	end

	for _, grupo in porEtapa do
		for _ = 1, CFG.RAMAS_POR_ETAPA do
			crearRama(grupo)
		end
	end
	task.spawn(function()
		while true do
			task.wait(CFG.REAPARICION_RAMAS)
			for _, grupo in porEtapa do
				if grupo.cuantas < CFG.RAMAS_POR_ETAPA then
					crearRama(grupo)
				end
			end
		end
	end)
end

local function iniciarFibra()
	for _, helecho in CollectionService:GetTagged("Fibra") do
		local centro = helecho.PrimaryPart
		if not centro then
			continue
		end
		local hojas = piezasLlamadas(helecho, "Hoja")
		local prompt = Util.prompt(centro, "Arrancar fibra", "🌿 Helecho", 0.5, 9)
		prompt.Triggered:Connect(function(jugador)
			if not prompt.Enabled then
				return
			end
			prompt.Enabled = false
			local n = math.random(1, 2)
			Inventario.dar(jugador, "Fibra", n)
			aviso(jugador, "Fibra", n)
			mostrarPiezas(hojas, 1)
			task.delay(CFG.FIBRA_RECRECE, function()
				mostrarPiezas(hojas, #hojas)
				prompt.Enabled = true
			end)
		end)
	end
end

local function iniciarMoras()
	for _, zarza in CollectionService:GetTagged("Moras") do
		local centro = zarza.PrimaryPart
		if not centro then
			continue
		end
		local frutos = piezasLlamadas(zarza, "Fruto")
		local prompt = Util.prompt(centro, "Coger moras", "🫐 Zarza", 0.3, 9)
		local quedan = CFG.MORAS_POR_ARBUSTO
		local function mostrar()
			mostrarPiezas(frutos, math.ceil(#frutos * quedan / CFG.MORAS_POR_ARBUSTO))
			prompt.Enabled = quedan > 0
			prompt.ObjectText = string.format("🫐 Zarza (%d)", quedan)
		end
		mostrar()
		prompt.Triggered:Connect(function(jugador)
			if quedan <= 0 then
				return
			end
			quedan -= 1
			Inventario.dar(jugador, "Comida", 1)
			aviso(jugador, "Comida", 1)
			mostrar()
		end)
		task.spawn(function()
			while zarza.Parent do
				task.wait(CFG.MORA_RECRECE)
				if quedan < CFG.MORAS_POR_ARBUSTO then
					quedan += 1
					mostrar()
				end
			end
		end)
	end
end

local function iniciarSetas()
	for _, setas in CollectionService:GetTagged("Setas") do
		local centro = setas.PrimaryPart
		if not centro then
			continue
		end
		local piezas = piezasLlamadas(setas, "Seta")
		local prompt = Util.prompt(centro, "Coger setas", "🍄 Setas", 0.3, 8)
		prompt.Triggered:Connect(function(jugador)
			if not prompt.Enabled then
				return
			end
			prompt.Enabled = false
			Inventario.dar(jugador, "Comida", 1)
			aviso(jugador, "Comida", 1)
			mostrarPiezas(piezas, 0)
			task.delay(CFG.SETA_RECRECE, function()
				mostrarPiezas(piezas, #piezas)
				prompt.Enabled = true
			end)
		end)
	end
end

local function iniciarPiedras()
	for _, monton in CollectionService:GetTagged("Piedras") do
		local centro = monton.PrimaryPart
		if not centro then
			continue
		end
		local piedras = piezasLlamadas(monton, "Piedra")
		local prompt = Util.prompt(centro, "Coger piedras", "🪨 Piedras", 0.4, 9)
		local quedan = CFG.PIEDRAS_POR_MONTON
		local function mostrar()
			mostrarPiezas(piedras, math.ceil(#piedras * quedan / CFG.PIEDRAS_POR_MONTON))
			prompt.Enabled = quedan > 0
			prompt.ObjectText = string.format("🪨 Piedras (%d)", quedan)
		end
		mostrar()
		prompt.Triggered:Connect(function(jugador)
			if quedan <= 0 then
				return
			end
			quedan -= 1
			local n = if math.random() < 0.25 then 2 else 1
			Inventario.dar(jugador, "Piedra", n)
			aviso(jugador, "Piedra", n)
			mostrar()
		end)
		task.spawn(function()
			while monton.Parent do
				task.wait(CFG.PIEDRA_RECARGA)
				if quedan < CFG.PIEDRAS_POR_MONTON then
					quedan += 1
					mostrar()
				end
			end
		end)
	end
end

local NOMBRES_PROVISIONES = {
	Mochila = "🎒 Mochila perdida",
	Nevera = "🧊 Nevera de excursionista",
	Caja = "📦 Caja de provisiones",
}

local function botin(jugador: Player)
	local partes = {}
	local function dar(recurso: string, prob: number, minimo: number, maximo: number)
		if math.random() < prob then
			local n = math.random(minimo, maximo)
			Inventario.dar(jugador, recurso, n)
			table.insert(partes, string.format("+%d %s", n, Config.ICONOS_RECURSOS[recurso]))
		end
	end
	dar("Comida", 0.6, 1, 2)
	dar("Fibra", 0.5, 1, 3)
	dar("Lena", 0.4, 1, 2)
	dar("Piedra", 0.35, 1, 2)
	if (Estado.get("Etapa") or 1) >= 2 then
		dar("Cuerda", 0.12, 1, 1)
	end
	if #partes == 0 then
		Inventario.dar(jugador, "Comida", 1)
		table.insert(partes, "+1 " .. Config.ICONOS_RECURSOS.Comida)
	end
	return table.concat(partes, "  ")
end

local function iniciarProvisiones()
	for _, caja in CollectionService:GetTagged("Provisiones") do
		local cuerpo = caja.PrimaryPart
		if not cuerpo then
			continue
		end
		local nombre = NOMBRES_PROVISIONES[caja:GetAttribute("Tipo")] or "📦 Provisiones"
		local prompt = Util.prompt(cuerpo, "Registrar", nombre, 0.8, 9)
		prompt.Triggered:Connect(function(jugador)
			if not prompt.Enabled then
				return
			end
			prompt.Enabled = false
			Estado.notificar(jugador, nombre .. ":  " .. botin(jugador))
			task.delay(CFG.PROVISIONES_RECARGA, function()
				prompt.Enabled = true
			end)
		end)
	end
end

local function iniciarPesca()
	for _, sitio in CollectionService:GetTagged("Pesca") do
		local muelle = sitio.PrimaryPart
		if not muelle then
			continue
		end
		local prompt = Util.prompt(muelle, "Pescar", "🎣 Embarcadero", CFG.PESCA_DURACION, 10)
		prompt.Triggered:Connect(function(jugador)
			if math.random() < CFG.PESCA_PROBABILIDAD then
				Inventario.dar(jugador, "Comida", CFG.PESCA_COMIDA)
				Estado.notificar(jugador, string.format("🐟 ¡Has pescado una trucha!  +%d 🍎", CFG.PESCA_COMIDA), rgb(150, 220, 255))
			else
				Estado.notificar(jugador, "🎣 Nada... Los peces están muy listos hoy. Prueba otra vez.")
			end
		end)
	end
end

local talando = {}

function Recursos.talar(arbol: Model, golpe: number, jugador: Player)
	if golpe <= 0 or talando[arbol] or arbol:GetAttribute("Talado") then
		return
	end
	local vida = (arbol:GetAttribute("Vida") or CFG.ARBOL_VIDA) - golpe
	arbol:SetAttribute("Vida", vida)
	local tronco = arbol.PrimaryPart
	if not tronco then
		return
	end
	if vida > 0 then
		local original = arbol:GetPivot()
		arbol:PivotTo(original * CFrame.Angles(0, 0, math.rad(1.5)))
		task.delay(0.08, function()
			arbol:PivotTo(original)
		end)
		Estado.notificar(jugador, string.format("🪓 Talando... (%d)", math.ceil(vida)))
		return
	end
	talando[arbol] = true
	arbol:SetAttribute("Talado", true)
	local base = Vector3.new(tronco.Position.X, 0.6, tronco.Position.Z)
	for i = 1, CFG.LENA_POR_ARBOL do
		local a = i * (math.pi * 2 / CFG.LENA_POR_ARBOL)
		Recursos.soltar("Lena", base + Vector3.new(math.cos(a) * 3, 0, math.sin(a) * 3), 1)
	end
	Estado.notificar(jugador, "🌳 ¡Árbol talado! Recoge la leña del suelo.")
	local estadoPiezas = {}
	for _, d in arbol:GetDescendants() do
		if d:IsA("BasePart") then
			estadoPiezas[d] = { d.Transparency, d.CanCollide }
			TweenService:Create(d, TweenInfo.new(0.8), { Transparency = 1 }):Play()
			d.CanCollide = false
		end
	end
	task.delay(CFG.ARBOL_RECRECE, function()
		for d, datos in estadoPiezas do
			if d.Parent then
				d.Transparency = datos[1]
				d.CanCollide = datos[2]
			end
		end
		arbol:SetAttribute("Vida", CFG.ARBOL_VIDA)
		arbol:SetAttribute("Talado", false)
		talando[arbol] = nil
	end)
end

function Recursos.iniciar()
	carpeta = Instance.new("Folder")
	carpeta.Name = "Recogibles"
	carpeta.Parent = workspace
	Recursos.carpeta = carpeta

	iniciarRamas()
	iniciarFibra()
	iniciarMoras()
	iniciarSetas()
	iniciarPiedras()
	iniciarProvisiones()
	iniciarPesca()
end

return Recursos
