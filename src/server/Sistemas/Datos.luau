local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)

local Datos = {}

local almacen = nil
local cargados: { [Player]: boolean } = {}

local function clave(jugador: Player): string
	return "jugador_" .. jugador.UserId
end

local function stats(jugador: Player): (IntValue?, IntValue?)
	local ls = jugador:FindFirstChild("leaderstats")
	if not ls then
		return nil, nil
	end
	return ls:FindFirstChild("Viajes") :: IntValue, ls:FindFirstChild("Noches") :: IntValue
end

local function guardar(jugador: Player)
	if not almacen or not cargados[jugador] then
		return
	end
	local viajes, noches = stats(jugador)
	if not viajes or not noches then
		return
	end
	local ok, err = pcall(function()
		almacen:UpdateAsync(clave(jugador), function(viejo)
			viejo = if type(viejo) == "table" then viejo else {}
			return {
				Viajes = math.max(viejo.Viajes or 0, viajes.Value),
				Noches = math.max(viejo.Noches or 0, noches.Value),
			}
		end)
	end)
	if not ok then
		warn("[Datos] No se pudo guardar a " .. jugador.Name .. ": " .. tostring(err))
	end
end

local function alEntrar(jugador: Player)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local viajes = Instance.new("IntValue")
	viajes.Name = "Viajes"
	viajes.Parent = ls
	local noches = Instance.new("IntValue")
	noches.Name = "Noches"
	noches.Parent = ls
	ls.Parent = jugador

	if not almacen then
		return
	end
	local ok, datos = pcall(function()
		return almacen:GetAsync(clave(jugador))
	end)
	if not ok then
		warn("[Datos] No se pudieron cargar los datos de " .. jugador.Name .. ": " .. tostring(datos))
		return
	end
	if type(datos) == "table" then
		viajes.Value = datos.Viajes or 0
		noches.Value = datos.Noches or 0
	end
	cargados[jugador] = true
end

function Datos.registrarViaje(jugador: Player)
	local viajes = stats(jugador)
	if viajes then
		viajes.Value += 1
	end
	guardar(jugador)
end

function Datos.iniciar()
	local ok, resultado = pcall(function()
		return DataStoreService:GetDataStore(Config.NOMBRE_DATASTORE)
	end)
	if ok then
		almacen = resultado
	else
		warn("[Datos] El progreso no se guardará: " .. tostring(resultado))
	end

	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		task.spawn(alEntrar, jugador)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		guardar(jugador)
		cargados[jugador] = nil
	end)
	game:BindToClose(function()
		for _, jugador in Players:GetPlayers() do
			guardar(jugador)
		end
	end)

	local function actualizarRecord()
		local n = Estado.get("NochesSobrevividas") or 0
		for _, jugador in Players:GetPlayers() do
			local _, noches = stats(jugador)
			if noches and n > noches.Value then
				noches.Value = n
			end
		end
	end
	Estado.escuchar("NocheSobrevivida", actualizarRecord)
	Estado.escuchar("Final", function()
		actualizarRecord()
		for _, jugador in Players:GetPlayers() do
			Datos.registrarViaje(jugador)
		end
	end)
end

return Datos
