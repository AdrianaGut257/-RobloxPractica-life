local Bosque = require(script.Parent.Parent.Bosque)
local Props = require(script.Parent.Parent.Props)
local Ruta = require(script.Parent.Parent.Ruta)
local Util = require(script.Parent.Parent.Util)

local PasoNevado = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local C = Props.COLORES
local S = Ruta.SITIOS

local function refugio(padre)
	local f = Util.modelo("Refugio", padre)
	local c = S.campamentos[4] + V(-24, 0, 6)
	local piedra = rgb(130, 128, 122)
	Util.bloque(f, V(1, 7, 12), c + V(-6, 3.5, 0), piedra, M.Cobblestone)
	Util.bloque(f, V(12, 7, 1), c + V(0, 3.5, 6), piedra, M.Cobblestone)
	Util.bloque(f, V(12, 7, 1), c + V(0, 3.5, -6), piedra, M.Cobblestone)
	Util.bloque(f, V(1, 7, 4), c + V(6, 3.5, -4), piedra, M.Cobblestone)
	Util.bloque(f, V(1, 7, 4), c + V(6, 3.5, 4), piedra, M.Cobblestone)
	Util.bloque(f, V(1, 1, 4), c + V(6, 6.5, 0), piedra, M.Cobblestone)
	Util.bloque(f, V(14, 1, 14), c + V(0, 7.5, 0), rgb(90, 70, 52), M.WoodPlanks)
	Util.bloque(f, V(14.4, 0.8, 14.4), c + V(0, 8.4, 0), C.nieve, M.Snow, DECO)
	Util.bloque(f, V(3, 0.3, 2), c + V(-3, 2.6, -2), C.madera, M.WoodPlanks)
	for _, dx in { -1.3, 1.3 } do
		Util.bloque(f, V(0.3, 2.5, 0.3), c + V(-3 + dx, 1.25, -2), C.maderaOscura, M.Wood, DECO)
	end
	Props.pagina(f, CFrame.new(c + V(-3, 2.8, -2)) * CFrame.Angles(0, 0.3, 0), 8)
	Util.bloque(f, V(1.4, 1.2, 5), c + V(-4.6, 0.6, 2.5), C.madera, M.WoodPlanks)
	Util.bloque(f, V(2, 2.4, 2), c + V(3, 1.2, -4), rgb(40, 40, 42), M.Metal)
	Util.cilindroV(f, 0.6, 5, c + V(3, 4.9, -4), rgb(40, 40, 42), M.Metal, DECO)
	return f
end

local function torre(padre)
	local m = Util.modelo("Torre", padre)
	local c = S.torre
	local madera = rgb(110, 82, 56)
	local alto = 28
	for _, dx in { -4, 4 } do
		for _, dz in { -4, 4 } do
			Util.cilindroV(m, 1.2, alto, c + V(dx, alto / 2, dz), madera, M.Wood)
		end
	end
	for _, nivel in { 7, 16, 24 } do
		Util.barra(m, 0.5, c + V(-4, nivel - 6, -4), c + V(4, nivel, -4), madera, M.Wood, DECO)
		Util.barra(m, 0.5, c + V(-4, nivel - 6, 4), c + V(4, nivel, 4), madera, M.Wood, DECO)
		Util.barra(m, 0.5, c + V(-4, nivel - 6, -4), c + V(-4, nivel, 4), madera, M.Wood, DECO)
		Util.barra(m, 0.5, c + V(4, nivel - 6, -4), c + V(4, nivel, 4), madera, M.Wood, DECO)
	end
	Util.bloque(m, V(11, 1, 11), c + V(0, alto, 0), C.madera, M.WoodPlanks)
	Util.bloque(m, V(11, 3, 0.4), c + V(0, alto + 2, 5.3), madera, M.WoodPlanks)
	Util.bloque(m, V(0.4, 3, 11), c + V(5.3, alto + 2, 0), madera, M.WoodPlanks)
	Util.bloque(m, V(0.4, 3, 11), c + V(-5.3, alto + 2, 0), madera, M.WoodPlanks)
	Util.bloque(m, V(4, 3, 0.4), c + V(-3.5, alto + 2, -5.3), madera, M.WoodPlanks)
	Util.bloque(m, V(4, 3, 0.4), c + V(3.5, alto + 2, -5.3), madera, M.WoodPlanks)
	for _, dx in { -5, 5 } do
		for _, dz in { -5, 5 } do
			Util.bloque(m, V(0.5, 7, 0.5), c + V(dx, alto + 4, dz), madera, M.Wood, DECO)
		end
	end
	Util.bloque(m, V(12.5, 0.6, 12.5), c + V(0, alto + 7.8, 0), rgb(90, 70, 52), M.WoodPlanks)
	Util.bloque(m, V(12.8, 0.7, 12.8), c + V(0, alto + 8.4, 0), C.nieve, M.Snow, DECO)
	Util.parte({
		Clase = "TrussPart",
		Parent = m,
		Name = "Escalera",
		Size = V(2, alto, 2),
		CFrame = CFrame.new(c + V(0, alto / 2, -6.5)),
		Color = rgb(90, 92, 96),
		Material = M.Metal,
	})
	local llave = Util.modelo("LlaveGuarda", padre)
	local pos = c + V(1.5, alto + 1.2, 1.5)
	local cana = Util.bloque(llave, V(0.25, 0.25, 1.5), CFrame.new(pos) * CFrame.Angles(0, 0.6, 0), C.oro, M.Metal, {
		CanCollide = false,
		CanTouch = false,
		Name = "Cuerpo",
	})
	Util.cilindro(llave, 0.8, 0.2, cana.CFrame * CFrame.new(0, 0, 0.95) * CFrame.Angles(0, 0, math.pi / 2), C.oro, M.Metal, DECO)
	Util.bloque(llave, V(0.2, 0.25, 0.45), cana.CFrame * CFrame.new(0.25, 0, -0.55), C.oro, M.Metal, DECO)
	Util.luz(cana, rgb(255, 215, 130), 8, 2)
	local brillo = Instance.new("Sparkles")
	brillo.SparkleColor = rgb(255, 225, 150)
	brillo.Parent = cana
	llave.PrimaryPart = cana
	Util.etiquetar(llave, "LlaveGuarda")
	Util.bloque(m, V(2, 1.4, 1.6), c + V(-2.5, alto + 1.2, 2), C.madera, M.WoodPlanks)
	Props.pagina(padre, CFrame.new(c + V(-2.5, alto + 1.95, 2)) * CFrame.Angles(0, -0.4, 0), 9)
	return m
end

local function barrera(padre)
	local m = Util.modelo("Barrera", padre)
	local c = S.barrera
	local piedra = rgb(120, 118, 112)
	for _, dx in { -8, 8 } do
		Util.bloque(m, V(2, 8, 2), c + V(dx, 4, 0), piedra, M.Cobblestone)
		Util.bloque(m, V(2.4, 0.6, 2.4), c + V(dx, 8.3, 0), C.nieve, M.Snow, DECO)
	end
	local hoja = Util.modelo("Hoja", m)
	local metal = rgb(70, 74, 80)
	local x0, x1 = c.X - 7, c.X + 7
	Util.bloque(hoja, V(14, 0.5, 0.4), V(c.X, 6, c.Z), metal, M.Metal)
	Util.bloque(hoja, V(14, 0.5, 0.4), V(c.X, 0.8, c.Z), metal, M.Metal)
	for x = x0, x1, 1.2 do
		Util.bloque(hoja, V(0.25, 5.4, 0.25), V(x, 3.4, c.Z), metal, M.Metal, DECO)
	end
	local tablon = Util.bloque(hoja, V(7, 2, 0.3), V(c.X, 3.6, c.Z - 0.4), rgb(200, 60, 50), M.SmoothPlastic, DECO)
	Util.letrero(tablon, Enum.NormalId.Front, "PASO NEVADO · CERRADO", rgb(255, 255, 255), Enum.Font.GothamBold)
	local candado = Util.bloque(hoja, V(0.8, 1, 0.6), V(c.X + 6, 3.4, c.Z - 0.6), C.oro, M.Metal)
	candado.Name = "Candado"
	hoja.PrimaryPart = candado
	hoja.WorldPivot = CFrame.new(x0, 3, c.Z)
	local bloqueo = Util.bloque(m, V(16, 60, 2), c + V(0, 30, 0), Color3.new(), M.SmoothPlastic, {
		Name = "Bloqueo",
		Transparency = 1,
	})
	bloqueo:SetAttribute("Bloqueo", true)
	m.PrimaryPart = candado
	Util.etiquetar(m, "Barrera")
	return m
end

local function lagoHelado(padre)
	local c = S.lagoHelado
	for i = 1, 16 do
		local a = i * (math.pi * 2 / 16)
		Util.elipsoide(padre, V(Util.entre(4, 7), Util.entre(1.5, 2.5), Util.entre(4, 7)), c + V(math.cos(a) * 26, 0.3, math.sin(a) * 26), C.nieve, M.Snow, DECO)
	end
end

function PasoNevado.construir(raiz: Instance)
	local f = Util.carpeta("4_PasoNevado", raiz)
	refugio(f)
	torre(f)
	barrera(f)
	lagoHelado(f)

	Props.campamento(f, S.campamentos[4], 4, "Campamento 4 · El Paso Nevado", rgb(200, 60, 60), -0.2)
	Props.poste(f, CFrame.new(S.campamentos[4] + V(24, 0, 8)) * CFrame.Angles(0, 0, 0), "Torre de vigilancia →")

	local cumbre = S.cumbre
	for i = 1, 6 do
		local a = i * 1.05
		Props.roca(f, cumbre + V(math.cos(a) * 6, 0.6, math.sin(a) * 6), Util.entre(3, 5), rgb(120, 120, 124))
	end
	Props.mirador(f, CFrame.lookAt(cumbre, cumbre - V(0, 0, 10)), 4, V(-70, 95, 1320), V(0, 0, 560))

	Props.provisiones(f, CFrame.new(V(110, 0, 1012)) * CFrame.Angles(0, 0.7, 0), "Caja")
	Props.provisiones(f, CFrame.new(V(-112, 0, 1120)) * CFrame.Angles(0, 2.1, 0), "Mochila")
	Props.provisiones(f, CFrame.new(V(-22, 0, 1204)) * CFrame.Angles(0, 0.3, 0), "Nevera")
	Props.provisiones(f, CFrame.new(V(72, 0, 1250)) * CFrame.Angles(0, 1.2, 0), "Caja")
	Props.provisiones(f, CFrame.new(S.campamentos[4] + V(4, 0, -12)) * CFrame.Angles(0, 0.4, 0), "Mochila")

	Props.tesoro(f, V(-112, 0, 1012), 10)
	Props.tesoro(f, V(112, 0, 1066), 11)
	Props.tesoro(f, V(60, 0, 1236), 12)

	Bosque.poblar(f, 4, {
		zMin = 994,
		zMax = 1260,
		separacion = 22,
		arbol = function(padre, pos)
			Props.pino(padre, pos, { nieve = true, color = rgb(40, 80, 60) }, true)
		end,
		borde = function(padre, pos)
			Props.pino(padre, pos, { nieve = true, escala = 1.4, color = rgb(40, 80, 60) }, false)
		end,
		helechos = 12,
		moras = 4,
		setas = 0,
		piedras = 12,
		rocas = 18,
		colorRoca = rgb(120, 120, 126),
		ramas = 18,
		enemigos = 16,
		cercaSendero = 9,
	})
	for _ = 1, 24 do
		local p = V(Util.entre(-130, 130), 0, Util.entre(996, 1258))
		if Ruta.libre(p, 5) then
			Util.elipsoide(f, V(Util.entre(4, 9), Util.entre(1.2, 2.6), Util.entre(4, 9)), p + V(0, 0.2, 0), C.nieve, M.Snow, DECO)
		end
	end
end

return PasoNevado
