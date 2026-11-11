local Util = require(script.Parent.Util)

local Ruta = {}

local V = Vector3.new

Ruta.ANCHO = 140
Ruta.Z_INICIO = -30
Ruta.Z_FINAL = 1580

Ruta.TRAMOS = {
	{
		V(16, 0, 12),
		V(8, 0, 50),
		V(-10, 0, 92),
		V(-22, 0, 128),
		V(-20, 0, 172),
		V(-4, 0, 210),
		V(18, 0, 252),
		V(12, 0, 288),
		V(6, 0, 334),
		V(-6, 0, 368),
		V(-20, 0, 398),
		V(-24, 0, 440),
		V(-16, 0, 480),
		V(-4, 0, 530),
		V(0, 0, 570),
		V(0, 0, 597),
	},
	{
		V(0, 0, 643),
		V(18, 0, 690),
		V(30, 0, 722),
		V(28, 0, 770),
		V(6, 0, 810),
		V(-24, 0, 860),
		V(-12, 0, 905),
		V(0, 0, 935),
		V(0, 0, 992),
		V(-14, 0, 1024),
		V(-22, 0, 1046),
		V(-14, 0, 1090),
		V(6, 0, 1130),
		V(26, 0, 1180),
		V(14, 0, 1230),
		V(8, 0, 1290),
		V(-10, 0, 1330),
		V(14, 0, 1386),
		V(2, 0, 1440),
		V(-4, 0, 1484),
		V(8, 0, 1520),
	},
}

Ruta.SITIOS = {
	inicio = V(20, 0, 22),
	furgoneta = V(36, 0, 6),
	campamentos = {
		[1] = V(-36, 0, 150),
		[2] = V(-38, 0, 410),
		[3] = V(48, 0, 742),
		[4] = V(-40, 0, 1060),
		[5] = V(-16, 0, 1500),
	},
	tronco = V(6, 0, 316),
	puente = V(0, 0, 620),
	cueva = V(0, 0, 940),
	barrera = V(8, 0, 1274),
	charca = V(82, 0, 132),
	remanso = V(62, 0, 440),
	cascada = V(62, 0, 600),
	arbolViejo = V(-88, 0, 800),
	caravana = V(70, 0, 750),
	torre = V(96, 0, 1150),
	lagoHelado = V(-84, 0, 1172),
	cumbre = V(-100, 0, 1232),
	faro = V(30, 0, 1546),
	casaAbuela = V(-44, 0, 1524),
	cabana = V(-98, 0, 1420),
	barca = V(96, 0, 1490),
	cobertizo = V(62, 0, 1526),
	finCamino = V(-84, 0, 1566),
}

Ruta.CRESTAS = {
	{ zMin = 312, zMax = 330, huecoX = 6, huecoAncho = 16 },
	{ zMin = 940, zMax = 988, huecoX = 0, huecoAncho = 16 },
	{ zMin = 1266, zMax = 1282, huecoX = 8, huecoAncho = 18 },
}
Ruta.BARRANCO = { zMin = 600, zMax = 640, fondo = -46 }

Ruta.CLAROS = {
	{ V(26, 0, 8), 26 },
	{ Ruta.SITIOS.campamentos[1], 30 },
	{ Ruta.SITIOS.campamentos[2], 30 },
	{ Ruta.SITIOS.campamentos[3], 32 },
	{ Ruta.SITIOS.campamentos[4], 32 },
	{ Ruta.SITIOS.campamentos[5], 36 },
	{ Ruta.SITIOS.tronco, 18 },
	{ Ruta.SITIOS.charca, 34 },
	{ Ruta.SITIOS.remanso, 42 },
	{ Ruta.SITIOS.arbolViejo, 30 },
	{ Ruta.SITIOS.caravana, 18 },
	{ Ruta.SITIOS.torre, 20 },
	{ Ruta.SITIOS.lagoHelado, 32 },
	{ Ruta.SITIOS.cumbre, 16 },
	{ Ruta.SITIOS.faro, 30 },
	{ Ruta.SITIOS.casaAbuela, 20 },
	{ Ruta.SITIOS.cabana, 18 },
	{ Ruta.SITIOS.barca, 16 },
	{ Ruta.SITIOS.cobertizo, 12 },
	{ Ruta.SITIOS.finCamino, 16 },
	{ Ruta.SITIOS.barrera, 16 },
}

local function distanciaSegmento(p: Vector3, a: Vector3, b: Vector3): number
	local ab = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
	local ap = Vector3.new(p.X - a.X, 0, p.Z - a.Z)
	local largo2 = ab:Dot(ab)
	local t = if largo2 > 0 then math.clamp(ap:Dot(ab) / largo2, 0, 1) else 0
	return (ap - ab * t).Magnitude
end

function Ruta.distanciaSendero(p: Vector3): number
	local mejor = math.huge
	for _, tramo in Ruta.TRAMOS do
		for i = 1, #tramo - 1 do
			mejor = math.min(mejor, distanciaSegmento(p, tramo[i], tramo[i + 1]))
		end
	end
	return mejor
end

function Ruta.libre(p: Vector3, margenSendero: number?): boolean
	if math.abs(p.X) > Ruta.ANCHO - 4 or p.Z < Ruta.Z_INICIO + 4 or p.Z > Ruta.Z_FINAL - 8 then
		return false
	end
	if p.Z > -10 and p.Z < 18 then
		return false
	end
	for _, cresta in Ruta.CRESTAS do
		if p.Z > cresta.zMin - 8 and p.Z < cresta.zMax + 8 then
			return false
		end
	end
	if p.Z > Ruta.BARRANCO.zMin - 6 and p.Z < Ruta.BARRANCO.zMax + 6 then
		return false
	end
	if p.Z > 470 and p.Z < 600 and math.abs(p.X - 62) < 8 then
		return false
	end
	for _, claro in Ruta.CLAROS do
		if Util.dist2D(p, claro[1]) < claro[2] then
			return false
		end
	end
	return Ruta.distanciaSendero(p) > (margenSendero or 10)
end

function Ruta.caminable(p: Vector3): boolean
	if math.abs(p.X) > Ruta.ANCHO - 4 or p.Z < Ruta.Z_INICIO + 4 or p.Z > Ruta.Z_FINAL - 8 then
		return false
	end
	for _, cresta in Ruta.CRESTAS do
		if p.Z > cresta.zMin - 3 and p.Z < cresta.zMax + 3 then
			return false
		end
	end
	if p.Z > Ruta.BARRANCO.zMin - 5 and p.Z < Ruta.BARRANCO.zMax + 5 then
		return false
	end
	if Util.dist2D(p, Ruta.SITIOS.charca) < 24 or Util.dist2D(p, Ruta.SITIOS.remanso) < 32 then
		return false
	end
	if p.Z > 466 and p.Z < 600 and math.abs(p.X - 62) < 6 then
		return false
	end
	return true
end

function Ruta.puntosCada(paso: number): { { pos: Vector3, dir: Vector3 } }
	local lista = {}
	for _, tramo in Ruta.TRAMOS do
		for i = 1, #tramo - 1 do
			local a, b = tramo[i], tramo[i + 1]
			local largo = (b - a).Magnitude
			local dir = (b - a).Unit
			local n = math.floor(largo / paso)
			for k = 0, n - 1 do
				table.insert(lista, { pos = a + dir * (k * paso + paso / 2), dir = dir })
			end
		end
	end
	return lista
end

return Ruta
