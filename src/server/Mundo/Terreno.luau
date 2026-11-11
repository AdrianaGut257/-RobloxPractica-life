local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Ruta = require(script.Parent.Ruta)
local Util = require(script.Parent.Util)

local Terreno = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb

local SUELOS = {
	{ desde = -140, hasta = 320, suelo = M.Grass, sendero = M.Ground, montes = { M.Grass, M.Rock } },
	{ desde = 320, hasta = 642, suelo = M.Grass, sendero = M.Ground, montes = { M.Grass, M.Rock } },
	{ desde = 642, hasta = 988, suelo = M.LeafyGrass, sendero = M.Mud, montes = { M.Rock, M.LeafyGrass } },
	{ desde = 988, hasta = 1278, suelo = M.Snow, sendero = M.Ground, montes = { M.Snow, M.Rock } },
	{ desde = 1278, hasta = Ruta.Z_FINAL, suelo = M.Grass, sendero = M.Ground, montes = { M.Rock, M.Grass } },
}

local function sueloEn(z: number)
	for _, s in SUELOS do
		if z < s.hasta then
			return s
		end
	end
	return SUELOS[#SUELOS]
end

local TROZO = 256
local function caja(x1: number, x2: number, y1: number, y2: number, z1: number, z2: number, material: Enum.Material)
	local xa, xb = math.min(x1, x2), math.max(x1, x2)
	local za, zb = math.min(z1, z2), math.max(z1, z2)
	local ya, yb = math.min(y1, y2), math.max(y1, y2)
	local x = xa
	while x < xb do
		local xFin = math.min(xb, x + TROZO)
		local z = za
		while z < zb do
			local zFin = math.min(zb, z + TROZO)
			Util.terreno(V((x + xFin) / 2, (ya + yb) / 2, (z + zFin) / 2), V(xFin - x, yb - ya, zFin - z), material)
			z = zFin
		end
		x = xFin
	end
end

local function sendero()
	for _, tramo in Ruta.TRAMOS do
		for i = 1, #tramo - 1 do
			local a, b = tramo[i], tramo[i + 1]
			local largo = (b - a).Magnitude
			local trozos = math.max(1, math.ceil(largo / 12))
			for k = 0, trozos - 1 do
				local p1 = a:Lerp(b, k / trozos)
				local p2 = a:Lerp(b, (k + 1) / trozos)
				local medio = (p1 + p2) / 2
				local cf = CFrame.lookAt(V(medio.X, -1.5, medio.Z), V(p2.X, -1.5, p2.Z))
				workspace.Terrain:FillBlock(cf, V(8, 3, (p2 - p1).Magnitude + 3), sueloEn(medio.Z).sendero)
			end
		end
	end
end

local function lago(centro: Vector3, radio: number, profundidad: number)
	Util.terrenoCilindro(V(centro.X, -profundidad / 2, centro.Z), profundidad + 2, radio, M.Air)
	Util.terrenoCilindro(V(centro.X, -profundidad - 1, centro.Z), 2, radio, M.Mud)
	Util.terrenoCilindro(V(centro.X, -profundidad / 2 - 1, centro.Z), profundidad, radio, M.Water)
	Util.terrenoCilindro(V(centro.X, -1.5, centro.Z), 3, radio + 3, M.Mud)
	Util.terrenoCilindro(V(centro.X, -profundidad / 2, centro.Z), profundidad + 2, radio, M.Air)
	Util.terrenoCilindro(V(centro.X, -profundidad / 2 - 1, centro.Z), profundidad, radio, M.Water)
end

local function cresta(c, alto: number, materialCima: Enum.Material)
	local izq = c.huecoX - c.huecoAncho / 2
	local der = c.huecoX + c.huecoAncho / 2
	caja(-320, izq, -2, alto, c.zMin, c.zMax, M.Rock)
	caja(der, 320, -2, alto, c.zMin, c.zMax, M.Rock)
	local zMedio = (c.zMin + c.zMax) / 2
	for x = -300, 300, 22 do
		local r = Util.entre(12, 20)
		if x + r < izq - 4 or x - r > der + 4 then
			Util.terrenoBola(V(x + Util.entre(-6, 6), alto + Util.entre(-4, 8), zMedio), r, Util.elegir({ M.Rock, M.Rock, materialCima }))
		end
	end
end

local function montanas()
	for z = -140, Ruta.Z_FINAL - 10, 26 do
		local s = sueloEn(z)
		for _, lado in { -1, 1 } do
			local r = Util.entre(30, 48)
			Util.terrenoBola(V(lado * (152 + r), Util.entre(-6, 10), z + Util.entre(-8, 8)), r, s.montes[1])
			local r2 = Util.entre(60, 90)
			Util.terrenoBola(V(lado * (190 + r2), Util.entre(10, 40), z + Util.entre(-10, 10)), r2, Util.elegir(s.montes))
		end
	end
	for x = -300, 300, 30 do
		local r = Util.entre(40, 70)
		Util.terrenoBola(V(x, Util.entre(0, 20), -110 - r * 0.6), r, M.Grass)
	end
end

function Terreno.construir()
	local t = workspace.Terrain
	t:Clear()

	pcall(function()
		t.Decoration = true
	end)
	t.WaterColor = rgb(52, 118, 128)
	t.WaterTransparency = 0.5
	t.WaterReflectance = 0.7
	t.WaterWaveSize = 0.12
	t.WaterWaveSpeed = 9
	t:SetMaterialColor(M.Grass, rgb(104, 152, 72))
	t:SetMaterialColor(M.LeafyGrass, rgb(46, 70, 44))
	t:SetMaterialColor(M.Ground, rgb(132, 104, 74))
	t:SetMaterialColor(M.Mud, rgb(76, 60, 46))
	t:SetMaterialColor(M.Rock, rgb(112, 110, 106))
	t:SetMaterialColor(M.Snow, rgb(236, 242, 250))
	t:SetMaterialColor(M.Glacier, rgb(170, 210, 235))
	t:SetMaterialColor(M.Asphalt, rgb(62, 62, 66))
	t:SetMaterialColor(M.Sand, rgb(214, 196, 150))

	for _, s in SUELOS do
		caja(-420, 420, -16, 0, s.desde, s.hasta, s.suelo)
	end

	caja(-420, 420, -3, 0, -6, 10, M.Asphalt)
	caja(-420, 420, -3, 0, 10, 13, M.Ground)
	caja(-420, 420, -3, 0, -9, -6, M.Ground)

	sendero()

	lago(Ruta.SITIOS.charca, 20, 8)
	lago(Ruta.SITIOS.remanso, 28, 10)
	caja(58, 66, -4, 0, 466, 602, M.Air)
	caja(58, 66, -5, -4, 466, 602, M.Mud)
	caja(58, 66, -4, -1.2, 466, 602, M.Water)
	Util.terrenoCilindro(V(Ruta.SITIOS.lagoHelado.X, -1.5, Ruta.SITIOS.lagoHelado.Z), 3, 24, M.Glacier)

	local b = Ruta.BARRANCO
	caja(-420, 420, b.fondo, 1, b.zMin, b.zMax, M.Air)
	caja(-420, 420, b.fondo - 6, b.fondo, b.zMin - 4, b.zMax + 4, M.Rock)
	caja(-420, 420, b.fondo, b.fondo + 9, b.zMin, b.zMax, M.Water)
	caja(-420, 420, b.fondo, -1.5, b.zMin - 4, b.zMin, M.Rock)
	caja(-420, 420, b.fondo, -1.5, b.zMax, b.zMax + 4, M.Rock)
	for x = -300, 300, 14 do
		Util.terrenoBola(V(x + Util.entre(-4, 4), b.fondo + Util.entre(6, 30), b.zMin - 1), Util.entre(3, 6), M.Rock)
		Util.terrenoBola(V(x + Util.entre(-4, 4), b.fondo + Util.entre(6, 30), b.zMax + 1), Util.entre(3, 6), M.Rock)
	end
	caja(-420, 420, b.fondo + 9, 1, b.zMin + 2, b.zMax - 2, M.Air)

	local crestas = Ruta.CRESTAS
	cresta(crestas[1], 46, M.Grass)
	cresta(crestas[3], 52, M.Snow)
	local c2 = crestas[2]
	caja(-320, 320, -2, 64, c2.zMin, c2.zMax, M.Rock)
	for x = -300, 300, 24 do
		Util.terrenoBola(V(x + Util.entre(-6, 6), 64 + Util.entre(-6, 10), (c2.zMin + c2.zMax) / 2), Util.entre(16, 26), Util.elegir({ M.Rock, M.Snow }))
	end
	caja(-8, 8, -0.5, 16, c2.zMin - 6, c2.zMax + 6, M.Air)
	caja(-8, 8, -4, -0.5, c2.zMin - 6, c2.zMax + 6, M.Rock)

	montanas()

	caja(-500, 500, -70, 40, Ruta.Z_FINAL, 2300, M.Air)
	caja(-500, 500, -76, -70, Ruta.Z_FINAL, 2300, M.Sand)
	caja(-500, 500, -70, -14, Ruta.Z_FINAL + 2, 2300, M.Water)
	caja(-420, 420, -70, -1.5, Ruta.Z_FINAL - 4, Ruta.Z_FINAL + 2, M.Rock)
	for _ = 1, 14 do
		local p = V(Util.entre(-260, 260), Util.entre(-30, -12), Util.entre(Ruta.Z_FINAL + 40, Ruta.Z_FINAL + 420))
		Util.terrenoBola(p, Util.entre(8, 20), M.Rock)
	end
	for _, lado in { -1, 1 } do
		for k = 0, 4 do
			Util.terrenoBola(V(lado * (170 + k * 16), Util.entre(-10, 10), Ruta.Z_FINAL + 10 + k * 26), Util.entre(30, 44), M.Rock)
		end
	end
end

Terreno.sueloEn = sueloEn
Terreno.etapaEn = Config.etapaEn

return Terreno
