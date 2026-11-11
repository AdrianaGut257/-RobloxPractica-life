local Bosque = require(script.Parent.Parent.Bosque)
local Props = require(script.Parent.Parent.Props)
local Ruta = require(script.Parent.Parent.Ruta)
local Util = require(script.Parent.Parent.Util)

local Faro = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local C = Props.COLORES
local S = Ruta.SITIOS

Faro.ALTURA = 48

local function bidon(padre, cf: CFrame, numero: number)
	local m = Util.modelo("Bidon_" .. numero, padre)
	local cuerpo = Util.bloque(m, V(1.3, 1.8, 0.8), cf * CFrame.new(0, 0.9, 0), rgb(180, 40, 36), M.Metal)
	cuerpo.Name = "Cuerpo"
	Util.bloque(m, V(0.9, 0.25, 0.3), cf * CFrame.new(-0.1, 1.95, 0), rgb(150, 30, 30), M.Metal, DECO)
	Util.cilindroV(m, 0.3, 0.3, (cf * CFrame.new(0.4, 1.95, 0)).Position, rgb(230, 200, 80), M.Metal, DECO)
	Util.luz(cuerpo, rgb(255, 200, 140), 7, 1.2)
	local brillo = Instance.new("Sparkles")
	brillo.SparkleColor = rgb(255, 190, 120)
	brillo.Parent = cuerpo
	m.PrimaryPart = cuerpo
	m:SetAttribute("Numero", numero)
	Util.etiquetar(m, "Aceite")
	return m
end

local function casaAbuela(padre)
	local f = Util.modelo("CasaAbuela", padre)
	local c = S.casaAbuela
	local blanco = rgb(244, 240, 230)
	local teja = rgb(170, 70, 50)
	local ancho, fondo, alto = 16, 12, 8
	Util.bloque(f, V(1, alto, fondo), c + V(-ancho / 2, alto / 2, 0), blanco, M.SmoothPlastic)
	Util.bloque(f, V(ancho, alto, 1), c + V(0, alto / 2, fondo / 2), blanco, M.SmoothPlastic)
	Util.bloque(f, V(ancho, alto, 1), c + V(0, alto / 2, -fondo / 2), blanco, M.SmoothPlastic)
	Util.bloque(f, V(1, alto, 4), c + V(ancho / 2, alto / 2, -4), blanco, M.SmoothPlastic)
	Util.bloque(f, V(1, alto, 4), c + V(ancho / 2, alto / 2, 4), blanco, M.SmoothPlastic)
	Util.bloque(f, V(1, 2, 4), c + V(ancho / 2, alto - 1, 0), blanco, M.SmoothPlastic)
	for _, x in { -4, 3 } do
		for _, z in { fondo / 2 + 0.05, -fondo / 2 - 0.05 } do
			local v = Util.bloque(f, V(2.4, 2.4, 0.2), c + V(x, 4.6, z), rgb(255, 220, 150), M.Glass, DECO)
			v.Transparency = 0.2
		end
	end
	Util.bloque(f, V(ancho, 0.4, fondo), c + V(0, 0.2, 0), rgb(150, 110, 76), M.WoodPlanks)
	Util.bloque(f, V(ancho, 0.4, fondo), c + V(0, alto + 0.2, 0), rgb(150, 110, 76), M.WoodPlanks)
	Util.fronton(f, c + V(0, alto + 0.4, fondo / 2), ancho, 5, 0.8, blanco, M.SmoothPlastic)
	Util.fronton(f, c + V(0, alto + 0.4, -fondo / 2), ancho, 5, 0.8, blanco, M.SmoothPlastic)
	Util.rampa(f, fondo + 2, c + V(-ancho / 2 - 1, alto, 0), c + V(0, alto + 5.6, 0), teja, M.WoodPlanks)
	Util.rampa(f, fondo + 2, c + V(ancho / 2 + 1, alto, 0), c + V(0, alto + 5.6, 0), teja, M.WoodPlanks)
	Util.bloque(f, V(1, 5, 1), c + V(-3, alto + 5, 3), rgb(150, 70, 50), M.Brick)
	Util.bloque(f, V(4, 0.3, 2.6), c + V(-2, 2.8, -1), C.madera, M.WoodPlanks)
	for _, dx in { -1.7, 1.7 } do
		for _, dz in { -1.1, 1.1 } do
			Util.bloque(f, V(0.3, 2.6, 0.3), c + V(-2 + dx, 1.4, -1 + dz), C.maderaOscura, M.Wood, DECO)
		end
	end
	Props.pagina(f, CFrame.new(c + V(-2, 3, -1)) * CFrame.Angles(0, 0.2, 0), 10)
	Util.bloque(f, V(1.6, 1.6, 1.6), c + V(-2, 0.8, 1.2), C.madera, M.WoodPlanks, DECO)
	Util.bloque(f, V(3.4, 1.2, 6), c + V(-5.6, 0.8, 3), rgb(220, 210, 190), M.Fabric)
	Util.bloque(f, V(3.4, 0.6, 1.6), c + V(-5.6, 1.6, 5.4), rgb(240, 240, 240), M.Fabric, DECO)
	Util.cilindroV(f, 5, 0.06, c + V(1, 0.43, 1), rgb(150, 60, 70), M.Fabric, DECO)
	Props.flores(f, c + V(ancho / 2 + 4, 0, -6), 4, 16, { rgb(255, 120, 150), rgb(255, 230, 90), rgb(250, 250, 244) })
	Props.flores(f, c + V(ancho / 2 + 4, 0, 6), 4, 16, { rgb(255, 120, 150), rgb(160, 120, 230), rgb(250, 250, 244) })
	return f
end

local function faro(padre)
	local m = Util.modelo("Faro", padre)
	local c = S.faro
	local alto = Faro.ALTURA
	local radio = 6
	Util.cilindroV(m, 18, 1, c + V(0, 0.5, 0), rgb(150, 146, 140), M.Concrete)
	local franjas = 6
	for i = 0, franjas - 1 do
		local h = alto / franjas
		local color = if i % 2 == 0 then rgb(245, 245, 240) else rgb(200, 50, 45)
		Util.cilindroV(m, radio * 2, h, c + V(0, i * h + h / 2, 0), color, M.SmoothPlastic)
	end
	Util.bloque(m, V(3, 5, 0.5), c + V(0, 3, -radio + 0.1), rgb(70, 90, 110), M.Wood, DECO)

	local escalones = alto
	local angulo0 = math.rad(200)
	for i = 0, escalones - 1 do
		local a = angulo0 + i * math.rad(15)
		local r = radio + 2
		local pos = c + V(math.cos(a) * r, i + 0.5, math.sin(a) * r)
		local cf = CFrame.new(pos) * CFrame.Angles(0, -a, 0)
		Util.bloque(m, V(4, 1, 2.8), cf, rgb(120, 120, 126), M.DiamondPlate)
		local barandilla = Util.bloque(m, V(0.4, 5, 3), cf * CFrame.new(2.2, 2.5, 0), Color3.new(), M.SmoothPlastic, {
			Transparency = 1,
			CanQuery = false,
			Name = "Barandilla",
		})
		barandilla.CanTouch = false
		if i % 2 == 0 then
			Util.bloque(m, V(0.2, 3.2, 0.2), cf * CFrame.new(1.9, 2.1, 0), rgb(60, 60, 64), M.Metal, DECO)
		end
	end

	for k = 0, 16 do
		local a = angulo0 + k * math.rad(15)
		local cf = CFrame.new(c + V(math.cos(a) * 8.3, alto - 0.5, math.sin(a) * 8.3)) * CFrame.Angles(0, -a, 0)
		Util.bloque(m, V(4.6, 1, 2.9), cf, rgb(120, 120, 126), M.DiamondPlate)
		Util.bloque(m, V(0.3, 3.2, 2.9), cf * CFrame.new(2.1, 2.1, 0), rgb(60, 60, 64), M.Metal)
	end
	Util.cilindroV(m, radio * 2, 1, c + V(0, alto - 0.5, 0), rgb(120, 120, 126), M.DiamondPlate)
	Util.cilindroV(m, 9, 7, c + V(0, alto + 3.5, 0), rgb(200, 230, 240), M.Glass, { Transparency = 0.6 })
	Util.cilindroV(m, 10, 0.6, c + V(0, alto + 7.3, 0), rgb(60, 60, 64), M.Metal)
	Util.elipsoide(m, V(9, 5, 9), c + V(0, alto + 8, 0), rgb(200, 50, 45), M.SmoothPlastic, DECO)
	Util.bola(m, 1.2, c + V(0, alto + 10.6, 0), rgb(60, 60, 64), M.Metal, DECO)

	local lampara = Util.bola(m, 3.2, c + V(0, alto + 3, 0), rgb(255, 236, 180), M.Glass, {
		Name = "Lampara",
		CanCollide = false,
	})
	local luz = Util.luz(lampara, rgb(255, 230, 170), 60, 4, false)
	luz.Enabled = false
	for _, giro in { 0, math.pi } do
		local haz = Util.bloque(m, V(4, 4, 140), CFrame.new(c + V(0, alto + 3, 0)) * CFrame.Angles(0, giro, 0) * CFrame.new(0, 0, -72), rgb(255, 240, 190), M.Neon, {
			Deco = true,
			Transparency = 1,
			Name = "Haz",
		})
		haz:SetAttribute("Giro", giro)
		haz.CastShadow = false
		Util.etiquetar(haz, "HazFaro")
	end
	m:SetAttribute("Centro", c + V(0, alto + 3, 0))
	m.PrimaryPart = lampara
	Util.etiquetar(m, "Faro")
	return m
end

local function cobertizo(padre)
	local f = Util.modelo("Cobertizo", padre)
	local c = S.cobertizo
	local madera = rgb(120, 90, 62)
	Util.bloque(f, V(8, 6, 0.6), c + V(0, 3, 4), madera, M.WoodPlanks)
	Util.bloque(f, V(0.6, 6, 8), c + V(4, 3, 0), madera, M.WoodPlanks)
	Util.bloque(f, V(8, 6, 0.6), c + V(0, 3, -4), madera, M.WoodPlanks)
	Util.bloque(f, V(9, 0.5, 9.4), CFrame.new(c + V(0, 6.4, 0)) * CFrame.Angles(0, 0, math.rad(8)), rgb(80, 80, 86), M.CorrodedMetal)
	Util.bloque(f, V(1.6, 3, 0.3), c + V(3.4, 2, -2), rgb(90, 66, 46), M.Wood, DECO)
	Util.cilindro(f, 2.4, 0.6, CFrame.new(c + V(2.6, 1.2, 2.8)) * CFrame.Angles(0, math.pi / 2, 0), rgb(30, 30, 32), M.SmoothPlastic, DECO)
	bidon(padre, CFrame.new(c + V(1.5, 0, 0)) * CFrame.Angles(0, 0.3, 0), 3)
end

local function cabana(padre)
	local f = Util.modelo("CabanaPescador", padre)
	local c = S.cabana
	local madera = rgb(110, 84, 60)
	Util.bloque(f, V(0.8, 7, 10), c + V(-6, 3.5, 0), madera, M.WoodPlanks)
	Util.bloque(f, V(12, 7, 0.8), c + V(0, 3.5, 5), madera, M.WoodPlanks)
	Util.bloque(f, V(12, 7, 0.8), c + V(0, 3.5, -5), madera, M.WoodPlanks)
	Util.bloque(f, V(0.8, 7, 3), c + V(6, 3.5, -3.5), madera, M.WoodPlanks)
	Util.bloque(f, V(0.8, 7, 3), c + V(6, 3.5, 3.5), madera, M.WoodPlanks)
	Util.bloque(f, V(0.8, 2, 4), c + V(6, 6, 0), madera, M.WoodPlanks)
	Util.rampa(f, 11, c + V(-7, 7, 0), c + V(0, 10, 0), rgb(70, 70, 76), M.CorrodedMetal)
	Util.rampa(f, 11, c + V(7, 7, 0), c + V(0, 10, 0), rgb(70, 70, 76), M.CorrodedMetal)
	Util.bloque(f, V(0.2, 4, 6), c + V(6.6, 3.5, -0.5), rgb(170, 160, 120), M.Fabric, { Deco = true, Transparency = 0.4 })
	for i = 1, 4 do
		Util.bola(f, 0.9, c + V(6.8, 1 + i * 0.9, 3.8), if i % 2 == 0 then rgb(230, 60, 50) else rgb(245, 245, 240), M.SmoothPlastic, DECO)
	end
	Util.bloque(f, V(2, 1.6, 2), c + V(-3, 0.8, -3), rgb(140, 110, 70), M.Fabric, DECO)
	bidon(padre, CFrame.new(c + V(-3, 0, 2)) * CFrame.Angles(0, 1.2, 0), 1)
end

local function barca(padre)
	local f = Util.modelo("BarcaVieja", padre)
	local c = S.barca
	Util.elipsoide(f, V(5, 2.6, 13), CFrame.new(c + V(0, 0.9, 0)) * CFrame.Angles(0, 0.4, math.pi), rgb(60, 100, 140), M.WoodPlanks)
	Util.bloque(f, V(0.4, 0.4, 12), CFrame.new(c + V(0, 2.2, 0)) * CFrame.Angles(0, 0.4, 0), rgb(220, 220, 210), M.WoodPlanks, DECO)
	for _, d in { -1, 1 } do
		Util.barra(f, 0.3, c + V(d * 4, 0.3, -3), c + V(d * 5, 0.3, 4), C.madera, M.Wood, DECO)
	end
	bidon(padre, CFrame.new(c + V(-4, 0, 5)) * CFrame.Angles(0, 2, 0), 2)
end

local function vallaAcantilado(padre)
	local f = Util.carpeta("Valla", padre)
	local z = Ruta.Z_FINAL - 5
	for x = -140, 140, 5 do
		Util.bloque(f, V(0.6, 3.4, 0.6), V(x, 1.7, z), C.maderaOscura, M.Wood, DECO)
	end
	Util.bloque(f, V(280, 0.4, 0.3), V(0, 2.8, z), C.madera, M.Wood, DECO)
	Util.bloque(f, V(280, 0.4, 0.3), V(0, 1.5, z), C.madera, M.Wood, DECO)
	Util.muroInvisible(f, V(-142, 0, z + 0.5), V(142, 0, z + 0.5), 60)
end

local function barcoRosa(padre)
	local m = Util.modelo("BarcoRosa", padre)
	local cf = CFrame.new(60, -14, 2100) * CFrame.Angles(0, math.rad(200), 0)
	local azul = rgb(40, 80, 130)
	local casco = Util.bloque(m, V(9, 4, 26), cf * CFrame.new(0, 1, 0), azul, M.WoodPlanks)
	casco.Name = "Casco"
	Util.cuna(m, V(9, 4, 6), cf * CFrame.new(0, 1, -16) * CFrame.Angles(0, 0, math.pi), azul, M.WoodPlanks)
	Util.bloque(m, V(9.2, 0.6, 32), cf * CFrame.new(0, 3.2, -2), rgb(245, 245, 240), M.WoodPlanks, DECO)
	local cabina = Util.bloque(m, V(6, 5, 7), cf * CFrame.new(0, 5.6, 4), rgb(245, 245, 240), M.SmoothPlastic)
	Util.bloque(m, V(6.2, 1.6, 7.2), cf * CFrame.new(0, 7, 4), rgb(60, 70, 80), M.Glass, DECO)
	Util.bloque(m, V(0.5, 12, 0.5), cf * CFrame.new(0, 9, -4), rgb(90, 70, 50), M.Wood, DECO)
	local farol = Util.bola(m, 0.8, (cf * CFrame.new(0, 15.2, -4)).Position, rgb(255, 230, 160), M.Neon, DECO)
	Util.luz(farol, rgb(255, 220, 150), 30, 2)
	local nombre = Util.bloque(m, V(0.1, 1.4, 6), cf * CFrame.new(4.55, 1.8, -6), azul, M.SmoothPlastic, DECO)
	Util.letrero(nombre, Enum.NormalId.Right, "ROSA", rgb(255, 255, 255), Enum.Font.GothamBold)
	m.PrimaryPart = cabina
	m.WorldPivot = cf
	m:SetAttribute("Destino", CFrame.new(46, -14, Ruta.Z_FINAL + 50) * CFrame.Angles(0, math.rad(200), 0))
	Util.etiquetar(m, "BarcoFinal")
	return m
end

function Faro.construir(raiz: Instance)
	local f = Util.carpeta("5_Faro", raiz)
	casaAbuela(f)
	faro(f)
	cobertizo(f)
	cabana(f)
	barca(f)
	vallaAcantilado(f)
	barcoRosa(f)

	Props.campamento(f, S.campamentos[5], 5, "Campamento 5 · El Faro", rgb(80, 150, 90), 0.5)
	Props.poste(f, CFrame.new(V(-6, 0, 1300)) * CFrame.Angles(0, -math.pi / 2, 0), "🗼 Faro de Punta Clara ↑")

	local banco = S.finCamino
	Props.mirador(f, CFrame.lookAt(banco, banco + V(0, 0, 10)), 5, banco + V(0, 6, -8), banco + V(40, -6, 180))

	Props.marcador(V(112, 1, 1556), "PuntoJefe", 5)

	Props.provisiones(f, CFrame.new(V(-70, 0, 1320)) * CFrame.Angles(0, 0.5, 0), "Mochila")
	Props.provisiones(f, CFrame.new(V(90, 0, 1340)) * CFrame.Angles(0, 1.8, 0), "Caja")
	Props.provisiones(f, CFrame.new(S.campamentos[5] + V(-8, 0, -12)) * CFrame.Angles(0, 0.2, 0), "Nevera")

	Props.tesoro(f, V(-122, 0, 1362), 13)
	Props.tesoro(f, V(112, 0, 1420), 14)
	Props.tesoro(f, V(-30, 0, 1568), 15)

	Props.flores(f, V(-60, 0, 1380), 24, 60, { rgb(255, 230, 90), rgb(250, 250, 244), rgb(255, 140, 170), rgb(150, 120, 230) })
	Props.flores(f, V(70, 0, 1460), 20, 40, { rgb(250, 250, 244), rgb(150, 190, 255) })
	Props.mariposas(f, V(-60, 3, 1380), V(40, 4, 40))

	Bosque.poblar(f, 5, {
		zMin = 1288,
		zMax = 1560,
		separacion = 30,
		arbol = function(padre, pos)
			if Util.azar:NextNumber() < 0.5 then
				Props.roble(padre, pos, true, rgb(90, 140, 70))
			else
				Props.pino(padre, pos, nil, true)
			end
		end,
		borde = function(padre, pos)
			Props.pino(padre, pos, { escala = 1.2 }, false)
		end,
		helechos = 14,
		moras = 12,
		setas = 4,
		piedras = 10,
		rocas = 20,
		ramas = 22,
		enemigos = 18,
		cercaSendero = 9,
	})
	for x = -120, 120, 60 do
		local p = Util.bloque(f, V(50, 1, 6), V(x, -13, Ruta.Z_FINAL + 4), Color3.new(), M.SmoothPlastic, {
			Deco = true,
			Transparency = 1,
		})
		Util.particulas(p, {
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Color = ColorSequence.new(rgb(240, 248, 250)),
			Transparency = NumberSequence.new(0.4, 1),
			Size = NumberSequence.new(2, 6),
			Lifetime = NumberRange.new(1.5, 3),
			Rate = 6,
			Speed = NumberRange.new(2, 5),
			EmissionDirection = Enum.NormalId.Top,
			SpreadAngle = Vector2.new(30, 30),
		})
	end
end

return Faro
