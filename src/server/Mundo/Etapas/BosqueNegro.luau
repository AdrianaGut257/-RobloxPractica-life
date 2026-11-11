local Bosque = require(script.Parent.Parent.Bosque)
local Props = require(script.Parent.Parent.Props)
local Ruta = require(script.Parent.Parent.Ruta)
local Util = require(script.Parent.Parent.Util)

local BosqueNegro = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local S = Ruta.SITIOS

local function caravana(padre)
	local m = Util.modelo("Caravana", padre)
	local c = S.caravana
	local cf = CFrame.new(c)
	local crema = rgb(226, 216, 190)
	local cuerpo = Util.bloque(m, V(8, 6.5, 18), cf * CFrame.new(0, 4.25, 0), crema, M.SmoothPlastic)
	cuerpo.Name = "Cuerpo"
	Util.elipsoide(m, V(8, 2.4, 18), cf * CFrame.new(0, 7.5, 0), crema, M.SmoothPlastic, DECO)
	Util.bloque(m, V(8.1, 0.8, 18.1), cf * CFrame.new(0, 3.4, 0), rgb(150, 90, 60), M.SmoothPlastic, DECO)
	for _, z in { -5, 4 } do
		Util.bloque(m, V(8.15, 1.8, 3), cf * CFrame.new(0, 5.4, z), rgb(40, 50, 60), M.Glass, DECO)
	end
	local puerta = Util.bloque(m, V(0.2, 5, 2.6), cf * CFrame.new(-4.1, 3.5, 0), rgb(170, 150, 120), M.SmoothPlastic, DECO)
	puerta.Name = "Puerta"
	Props.pagina(padre, cf * CFrame.new(-4.25, 4.2, 0) * CFrame.Angles(0, 0, math.pi / 2), 6)
	for _, z in { -3, 3 } do
		Util.cilindro(m, 2.2, 0.8, cf * CFrame.new(-3.8, 1.1, z), rgb(30, 30, 32), M.SmoothPlastic, DECO)
		Util.cilindro(m, 2.2, 0.8, cf * CFrame.new(3.8, 1.1, z), rgb(30, 30, 32), M.SmoothPlastic, DECO)
	end
	Util.bloque(m, V(1.6, 0.4, 2.6), cf * CFrame.new(-5, 0.8, 0), rgb(120, 120, 124), M.Metal, DECO)
	for i = 0, 5 do
		local color = if i % 2 == 0 then rgb(200, 80, 70) else rgb(240, 236, 226)
		Util.bloque(m, V(5, 0.15, 1), cf * CFrame.new(-6.4, 7.4 - 0.1, -8.5 + i * 1) * CFrame.Angles(0, 0, math.rad(-10)), color, M.Fabric, DECO)
	end
	local armario = Util.modelo("Armario", padre)
	local mueble = Util.bloque(armario, V(2, 6, 3.4), cf * CFrame.new(-6, 3, -6.5), rgb(120, 84, 54), M.WoodPlanks)
	mueble.Name = "Cuerpo"
	for k = 0, 2 do
		Util.bloque(armario, V(0.6, 3.2, 1), cf * CFrame.new(-7.1, 3.2, -7.6 + k * 1.1), Util.elegir({ rgb(160, 60, 50), rgb(60, 90, 140), rgb(90, 120, 70) }), M.Fabric, DECO)
	end
	armario.PrimaryPart = mueble
	Util.etiquetar(armario, "Armario")
	m.PrimaryPart = cuerpo
	return m
end

local function cueva(padre)
	local f = Util.carpeta("Cueva", padre)
	local c = S.cueva
	local basalto = rgb(64, 62, 66)
	for _, x in { -9.5, 9.5 } do
		Util.bloque(f, V(3, 18, 4), V(x, 9, c.Z - 1), basalto, M.Basalt)
	end
	Util.bloque(f, V(22, 3, 4), V(0, 17.5, c.Z - 1), basalto, M.Basalt)
	for _ = 1, 8 do
		Util.elipsoide(f, V(Util.entre(2, 4), Util.entre(2, 4), 2), V(Util.entre(-10, 10), Util.entre(14, 19), c.Z - 2.5), basalto, M.Basalt, DECO)
	end
	for z = c.Z + 8, 984, 9 do
		for _, x in { -7, 7 } do
			local cristal = Util.bloque(
				f,
				V(0.8, Util.entre(1.5, 3), 0.8),
				CFrame.new(x, Util.entre(3, 11), z) * CFrame.Angles(Util.entre(-0.4, 0.4), 0, Util.entre(-0.4, 0.4)),
				rgb(120, 200, 255),
				M.Neon,
				DECO
			)
			Util.luz(cristal, rgb(120, 190, 255), 14, 1)
		end
	end

	local m = Util.modelo("Telaranas", padre)
	local centroWeb = V(0, 8, c.Z - 2)
	local bloqueo = Util.bloque(m, V(17, 17, 1.5), centroWeb, Color3.new(), M.SmoothPlastic, {
		Name = "Bloqueo",
		Transparency = 1,
	})
	local gris = rgb(205, 210, 220)
	local radios = 12
	for i = 1, radios do
		local a = i * (math.pi * 2 / radios)
		local punta = centroWeb + V(math.cos(a) * 8.4, math.sin(a) * 8.4, 0)
		local hilo = Util.barra(m, 0.14, centroWeb, punta, gris, M.Neon, DECO)
		hilo.Name = "Hilo"
		hilo.Transparency = 0.35
	end
	for _, r in { 2, 3.8, 5.6, 7.4 } do
		for i = 1, radios do
			local a1 = i * (math.pi * 2 / radios)
			local a2 = (i + 1) * (math.pi * 2 / radios)
			local p1 = centroWeb + V(math.cos(a1) * r, math.sin(a1) * r, 0)
			local p2 = centroWeb + V(math.cos(a2) * r, math.sin(a2) * r, 0)
			local hilo = Util.barra(m, 0.1, p1, p2, gris, M.Neon, DECO)
			hilo.Name = "Hilo"
			hilo.Transparency = 0.45
		end
	end
	Util.particulas(bloqueo, {
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(rgb(180, 185, 200)),
		Transparency = NumberSequence.new(0.6, 1),
		Size = NumberSequence.new(2, 5),
		Lifetime = NumberRange.new(2, 4),
		Rate = 4,
		Speed = NumberRange.new(0.5, 1.5),
		SpreadAngle = Vector2.new(180, 180),
	})
	m.PrimaryPart = bloqueo
	Util.etiquetar(m, "Telaranas")

	local nota = V(15, 0, c.Z - 16)
	for i = 1, 4 do
		local a = i * 1.4
		Util.barra(f, 0.8, nota + V(0, 1.6, 0), nota + V(math.cos(a) * 4, -0.2, math.sin(a) * 4), rgb(70, 54, 42), M.Wood, DECO)
	end
	Props.pagina(f, CFrame.new(nota + V(1.5, 0.15, -1.5)) * CFrame.Angles(0, 0.3, 0), 7)
	Props.poste(f, CFrame.new(V(-12, 0, c.Z - 14)) * CFrame.Angles(0, -math.pi / 2, 0), "Paso Nevado ↑")
end

local function arbolViejo(padre)
	local f = Util.carpeta("ArbolViejo", padre)
	local c = S.arbolViejo
	Props.arbolViejo(f, c)
	Props.luciernagas(f, c + V(0, 6, 0), V(50, 10, 50), true)
	local banco = c + V(20, 0, -16)
	Props.mirador(f, CFrame.lookAt(banco, c), 3, banco + V(8, 8, -10), c + V(0, 16, 0))
end

local function bruma(padre)
	for z = 680, 920, 60 do
		for _, x in { -80, 0, 80 } do
			local p = Util.bloque(padre, V(60, 1, 50), V(x + Util.entre(-15, 15), 1.5, z), Color3.new(), M.SmoothPlastic, {
				Deco = true,
				Transparency = 1,
				Name = "Bruma",
			})
			Util.particulas(p, {
				Texture = "rbxasset://textures/particles/smoke_main.dds",
				Color = ColorSequence.new(rgb(170, 180, 175)),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.3, 0.75),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Size = NumberSequence.new(8, 16),
				Lifetime = NumberRange.new(8, 12),
				Rate = 1.2,
				Speed = NumberRange.new(0.5, 1.5),
				SpreadAngle = Vector2.new(180, 10),
				LightInfluence = 0.8,
			})
		end
	end
end

function BosqueNegro.construir(raiz: Instance)
	local f = Util.carpeta("3_BosqueNegro", raiz)
	caravana(f)
	cueva(f)
	arbolViejo(f)
	bruma(f)

	Props.campamento(f, S.campamentos[3], 3, "Campamento 3 · El Bosque Negro", rgb(140, 80, 150), 0.9)

	Props.provisiones(f, CFrame.new(V(-42, 0, 700)) * CFrame.Angles(0, 0.4, 0), "Mochila")
	Props.provisiones(f, CFrame.new(V(102, 0, 822)) * CFrame.Angles(0, 1.6, 0), "Caja")
	Props.provisiones(f, CFrame.new(V(-110, 0, 902)) * CFrame.Angles(0, 2.6, 0), "Nevera")
	Props.provisiones(f, CFrame.new(V(56, 0, 880)) * CFrame.Angles(0, 0.2, 0), "Caja")

	Props.tesoro(f, V(92, 0, 862), 7)
	Props.tesoro(f, V(-102, 0, 700), 8)
	Props.tesoro(f, V(62, 0, 922), 9)

	Bosque.poblar(f, 3, {
		zMin = 648,
		zMax = 930,
		separacion = 15,
		margen = 9,
		arbol = function(padre, pos)
			if Util.azar:NextNumber() < 0.8 then
				Props.pino(padre, pos, { oscuro = true, escala = 1.15 }, true)
			else
				Props.arbolSeco(padre, pos, true)
			end
		end,
		borde = function(padre, pos)
			Props.pino(padre, pos, { oscuro = true, escala = 1.4 }, false)
		end,
		helechos = 24,
		moras = 6,
		setas = 14,
		piedras = 10,
		rocas = 20,
		colorRoca = rgb(90, 92, 90),
		ramas = 26,
		enemigos = 18,
		cercaSendero = 9,
	})
	for _ = 1, 30 do
		local p = V(Util.entre(-130, 130), 0, Util.entre(650, 930))
		if Ruta.libre(p, 3) then
			Util.cilindroV(f, 0.2, 0.6, p + V(0, 0.3, 0), rgb(220, 235, 230), M.SmoothPlastic, DECO)
			Util.elipsoide(f, V(0.8, 0.35, 0.8), p + V(0, 0.65, 0), rgb(110, 230, 255), M.Neon, DECO)
		end
	end
	Props.luciernagas(f, S.campamentos[3] + V(0, 5, 0), V(60, 8, 60))
end

return BosqueNegro
