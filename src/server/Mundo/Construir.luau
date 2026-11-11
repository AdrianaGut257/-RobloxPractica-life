local Props = require(script.Parent.Props)
local Ruta = require(script.Parent.Ruta)
local Terreno = require(script.Parent.Terreno)
local Util = require(script.Parent.Util)

local Etapas = script.Parent.Etapas
local ETAPAS = {
	require(Etapas.Abedules),
	require(Etapas.Rio),
	require(Etapas.BosqueNegro),
	require(Etapas.PasoNevado),
	require(Etapas.Faro),
}

local Construir = {}

Construir.NOMBRE = "RumboAlFaro"

local V = Vector3.new

local function limites(raiz: Instance)
	local f = Util.carpeta("Limites", raiz)
	local x = Ruta.ANCHO + 2
	Util.muroInvisible(f, V(-x, 0, Ruta.Z_INICIO), V(-x, 0, Ruta.Z_FINAL), 200)
	Util.muroInvisible(f, V(x, 0, Ruta.Z_INICIO), V(x, 0, Ruta.Z_FINAL), 200)
	Util.muroInvisible(f, V(-x, 0, Ruta.Z_INICIO + 2), V(x, 0, Ruta.Z_INICIO + 2), 200)

	local function bloque(x1: number, x2: number, y1: number, z1: number, z2: number)
		Util.parte({
			Parent = f,
			Name = "MuroInvisible",
			Size = V(math.abs(x2 - x1), 200 - y1, math.abs(z2 - z1)),
			Position = V((x1 + x2) / 2, (y1 + 200) / 2, (z1 + z2) / 2),
			Transparency = 1,
			CanQuery = false,
			CanTouch = false,
		})
	end
	for i, cresta in Ruta.CRESTAS do
		local izq = cresta.huecoX - cresta.huecoAncho / 2
		local der = cresta.huecoX + cresta.huecoAncho / 2
		if i == 2 then
			izq, der = -8, 8
			bloque(izq, der, 16, cresta.zMin, cresta.zMax)
		end
		bloque(-x, izq, -4, cresta.zMin, cresta.zMax)
		bloque(der, x, -4, cresta.zMin, cresta.zMax)
	end
end

function Construir.construir(): Instance
	local existente = workspace:FindFirstChild(Construir.NOMBRE)
	if existente then
		print("[Mapa] Usando el mapa que ya existe en Workspace")
		if not existente:GetAttribute("TerrenoPropio") then
			Terreno.construir()
		end
		return existente
	end

	local inicio = os.clock()
	local raiz = Instance.new("Folder")
	raiz.Name = Construir.NOMBRE
	Props.marcadores = Util.carpeta("Marcadores", raiz)

	Terreno.construir()
	limites(raiz)
	for i, etapa in ETAPAS do
		local ok, err = pcall(etapa.construir, raiz)
		if not ok then
			warn("[Mapa] Error construyendo la etapa " .. i .. ": " .. tostring(err))
		end
		task.wait()
	end

	raiz.Parent = workspace
	print(string.format("[Mapa] Viaje construido en %.1f s", os.clock() - inicio))
	return raiz
end

return Construir
