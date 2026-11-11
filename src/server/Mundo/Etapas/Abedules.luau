local Bosque = require(script.Parent.Parent.Bosque)
local Props = require(script.Parent.Parent.Props)
local Ruta = require(script.Parent.Parent.Ruta)
local Util = require(script.Parent.Parent.Util)

local Abedules = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local S = Ruta.SITIOS

local function carretera(padre)
	local f = Util.carpeta("Carretera", padre)
	for x = -300, 300, 10 do
		Util.bloque(f, V(4, 0.05, 0.4), V(x, 0.03, 2), rgb(235, 230, 210), M.SmoothPlastic, DECO)
	end
	local tramos = { { -300, 8 }, { 24, 28 }, { 46, 300 } }
	for _, t in tramos do
		local largo = t[2] - t[1]
		Util.bloque(f, V(largo, 0.8, 0.3), V((t[1] + t[2]) / 2, 2, 12.5), rgb(170, 172, 176), M.Metal)
		for x = t[1], t[2], 6 do
			Util.bloque(f, V(0.4, 2, 0.4), V(x, 1, 12.7), rgb(120, 120, 124), M.Metal, DECO)
		end
	end
	Util.bloque(f, V(8, 0.8, 0.3), CFrame.new(32, 1.4, 15) * CFrame.Angles(0.3, 0.6, 0.2), rgb(170, 172, 176), M.Metal, DECO)
	local senal = Util.bloque(f, V(5, 2, 0.2), CFrame.new(-30, 0.6, 14) * CFrame.Angles(math.rad(80), 0.3, 0), rgb(40, 110, 60), M.Metal, DECO)
	Util.letrero(senal, Enum.NormalId.Front, "← Valdeniebla 8 km", rgb(255, 255, 255), Enum.Font.GothamBold)
	Util.bloque(f, V(0.3, 5, 0.3), CFrame.new(-30, 0.3, 16.5) * CFrame.Angles(math.rad(85), 0.3, 0), rgb(150, 150, 150), M.Metal, DECO)
end

local function furgoneta(padre)
	local m = Util.modelo("Furgoneta", padre)
	local dir = V(0.5, 0, 0.86).Unit
	local cf = CFrame.lookAt(S.furgoneta, S.furgoneta + dir) * CFrame.Angles(0, 0, math.rad(-3))
	local function en(x, y, z)
		return cf * CFrame.new(x, y, z)
	end
	local azul = rgb(72, 150, 160)
	local crema = rgb(240, 232, 210)
	local cuerpo = Util.bloque(m, V(6, 3.6, 15), en(0, 2.6, 0), azul, M.SmoothPlastic)
	cuerpo.Name = "Cuerpo"
	Util.bloque(m, V(6, 2.6, 13.4), en(0, 5.7, 0.8), crema, M.SmoothPlastic)
	Util.bloque(m, V(5.4, 2.2, 0.2), en(0, 5.5, -6) * CFrame.Angles(math.rad(-14), 0, 0), rgb(150, 190, 210), M.Glass, { Transparency = 0.4 })
	for _, x in { -3.02, 3.02 } do
		Util.bloque(m, V(0.1, 1.8, 9), en(x, 5.7, 1.6), rgb(60, 70, 80), M.Glass, DECO)
	end
	Util.bloque(m, V(6.2, 1, 0.8), en(0, 1.4, -7.6) * CFrame.Angles(0, 0.15, 0.1), rgb(80, 80, 86), M.Metal, DECO)
	Util.bloque(m, V(5.6, 1.8, 1), en(0.2, 3, -7.3) * CFrame.Angles(0.2, 0.1, 0), azul, M.SmoothPlastic, DECO)
	Util.bola(m, 0.8, en(-2.2, 2.4, -7.7).Position, rgb(255, 245, 200), M.Neon, DECO)
	for _, x in { -3.1, 3.1 } do
		for _, z in { -4.8, 4.8 } do
			Util.cilindro(m, 2.4, 0.9, en(x, 1.2, z), rgb(30, 30, 32), M.SmoothPlastic, DECO)
		end
	end
	Util.bloque(m, V(0.3, 3.4, 3.2), en(4.6, 3.4, -3) * CFrame.Angles(0, math.rad(-65), 0), azul, M.SmoothPlastic, DECO)
	Props.pagina(padre, en(6, 0.15, -2.5) * CFrame.Angles(0, 0.5, 0), 1)
	local motor = Util.bloque(m, V(2, 1, 2), en(0, 4.2, -6.8), Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	Util.particulas(motor, {
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(rgb(120, 120, 120)),
		Transparency = NumberSequence.new(0.5, 1),
		Size = NumberSequence.new(1.5, 6),
		Lifetime = NumberRange.new(3, 5),
		Rate = 4,
		Speed = NumberRange.new(2, 4),
		SpreadAngle = Vector2.new(20, 20),
	})
	local luces = {}
	for _, x in { -2.7, 2.7 } do
		table.insert(luces, Util.bloque(m, V(0.8, 0.5, 0.2), en(x, 3, 7.55), rgb(255, 150, 40), M.SmoothPlastic, DECO))
	end
	task.spawn(function()
		local encendido = false
		while m.Parent do
			encendido = not encendido
			for _, l in luces do
				l.Material = if encendido then M.Neon else M.SmoothPlastic
			end
			task.wait(0.7)
		end
	end)
	m.PrimaryPart = cuerpo
	Props.abedul(padre, S.furgoneta + dir * 9.6, false)
	Util.etiquetar(m, "Furgoneta")
	return m
end

local function pato(padre, pos: Vector3, giro: number)
	local cf = CFrame.new(pos) * CFrame.Angles(0, giro, 0)
	Util.elipsoide(padre, V(1.4, 0.9, 2), cf, rgb(150, 120, 90), M.SmoothPlastic, DECO)
	Util.bola(padre, 0.75, (cf * CFrame.new(0, 0.7, -0.9)).Position, rgb(40, 110, 60), M.SmoothPlastic, DECO)
	Util.bloque(padre, V(0.3, 0.15, 0.5), cf * CFrame.new(0, 0.62, -1.4), rgb(240, 160, 40), M.SmoothPlastic, DECO)
end

local function charca(padre)
	local f = Util.carpeta("Charca", padre)
	local c = S.charca
	for i = 1, 40 do
		local a = i * (math.pi * 2 / 40) + Util.entre(-0.05, 0.05)
		local r = Util.entre(18.5, 22)
		local h = Util.entre(2, 4)
		local p = c + V(math.cos(a) * r, 0, math.sin(a) * r)
		if a < 4.2 or a > 5.2 then
			Util.cilindroV(f, 0.18, h, p + V(0, h / 2 - 1, 0), rgb(110, 140, 70), M.SmoothPlastic, DECO)
			if i % 3 == 0 then
				Util.cilindroV(f, 0.35, 0.9, p + V(0, h - 0.8, 0), rgb(110, 76, 48), M.SmoothPlastic, DECO)
			end
		end
	end
	for _ = 1, 10 do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(3, 16)
		Util.cilindroV(f, Util.entre(1.4, 2.2), 0.1, c + V(math.cos(a) * r, -1.05, math.sin(a) * r), rgb(70, 150, 70), M.SmoothPlastic, DECO)
	end
	pato(f, c + V(-4, -0.8, 3), 0.4)
	pato(f, c + V(-2, -0.8, 5), 0.9)
	pato(f, c + V(6, -0.8, -4), 2.6)
	pato(f, c + V(8, -0.8, -2), 3.1)
	Props.luciernagas(f, c + V(0, 4, 0), V(44, 6, 44))
	Props.mariposas(f, c + V(0, 3, -28), V(30, 4, 14))
	local banco = V(c.X, 0, c.Z - 27)
	Props.mirador(f, CFrame.lookAt(banco, V(c.X, 0, c.Z)), 1, V(c.X + 1, 5.5, c.Z - 33), V(c.X, 1, c.Z + 8))
	Props.flores(f, banco + V(0, 0, -4), 8, 30, { rgb(255, 230, 90), rgb(250, 250, 244), rgb(180, 130, 230) })
end

local function troncoCaido(padre)
	local m = Util.modelo("TroncoCaido", padre)
	local p = S.tronco
	local cf = CFrame.new(p + V(0, 2.4, 0)) * CFrame.Angles(0, math.rad(4), math.rad(2))
	local tronco = Util.cilindro(m, 5, 34, cf, rgb(96, 70, 48), M.Wood)
	tronco.Name = "Tronco"
	for i = 1, 6 do
		local x = -12 + i * 4
		local desde = (cf * CFrame.new(x, 1.8, 0)).Position
		Util.barra(m, 0.7, desde, desde + V(Util.entre(-1, 1), Util.entre(2, 4), Util.entre(-2, 2)), rgb(90, 66, 46), M.Wood, DECO)
		Util.elipsoide(m, V(3, 0.6, 2.4), cf * CFrame.new(x + 1.5, 2.4, 0), rgb(76, 126, 60), M.LeafyGrass, DECO)
	end
	local bloqueo = Util.bloque(m, V(18, 60, 6), p + V(0, 30, 0), Color3.new(), M.SmoothPlastic, {
		Name = "Bloqueo",
		Transparency = 1,
	})
	bloqueo:SetAttribute("Bloqueo", true)
	m.PrimaryPart = tronco
	Util.etiquetar(m, "Tronco")
	local lata = V(p.X + 11, 0, p.Z - 14)
	Util.cilindroV(padre, 1.6, 0.7, lata + V(0, 0.35, 0), rgb(50, 90, 170), M.Metal)
	Util.cilindroV(padre, 1.7, 0.12, lata + V(0, 0.72, 0), rgb(220, 190, 80), M.Metal, DECO)
	Props.pagina(padre, CFrame.new(lata + V(0, 0.82, 0)) * CFrame.Angles(0, 0.4, 0), 3)
	Props.poste(padre, CFrame.new(V(p.X - 10, 0, p.Z - 12)) * CFrame.Angles(0, -math.pi / 2, 0), "El Río ↑")
	return m
end

function Abedules.construir(raiz: Instance)
	local f = Util.carpeta("1_Abedules", raiz)
	carretera(f)
	furgoneta(f)
	charca(f)
	troncoCaido(f)

	Props.poste(f, CFrame.new(V(6, 0, 22)) * CFrame.Angles(0, -math.pi / 2, 0), "🗼 Faro de Punta Clara ↑")

	Props.campamento(f, S.campamentos[1], 1, "Campamento 1 · Los Abedules", rgb(220, 120, 60), 0.3)
	local abedulNota = S.campamentos[1] + V(-20, 0, -6)
	Props.abedul(f, abedulNota, false)
	Props.pagina(f, CFrame.new(abedulNota + V(0.75, 4.5, 0)) * CFrame.Angles(0, 0, math.pi / 2), 2)
	Props.provisiones(f, CFrame.new(S.campamentos[1] + V(8, 0, 12)) * CFrame.Angles(0, 0.6, 0), "Nevera")

	Props.provisiones(f, CFrame.new(V(-8, 0, 44)) * CFrame.Angles(0, 1, 0), "Mochila")
	Props.provisiones(f, CFrame.new(V(72, 0, 246)) * CFrame.Angles(0, 0.3, 0), "Caja")
	Props.provisiones(f, CFrame.new(V(-100, 0, 96)) * CFrame.Angles(0, 2, 0), "Mochila")
	Props.provisiones(f, CFrame.new(V(110, 0, 40)) * CFrame.Angles(0, 0.8, 0), "Caja")

	Props.tesoro(f, V(-62, 0, 58), 1)
	Props.tesoro(f, V(58, 0, 196), 2)
	Props.tesoro(f, V(-106, 0, 262), 3)

	Props.flores(f, V(60, 0, 62), 22, 50, { rgb(255, 230, 90), rgb(250, 250, 244), rgb(255, 140, 170), rgb(150, 120, 230) })
	Props.flores(f, V(-84, 0, 214), 18, 36, { rgb(255, 230, 90), rgb(250, 250, 244), rgb(255, 140, 170) })
	Props.mariposas(f, V(60, 3, 62), V(40, 4, 40))
	Props.mariposas(f, V(-84, 3, 214), V(30, 4, 30))

	Bosque.poblar(f, 1, {
		zMin = -26,
		zMax = 310,
		separacion = 18,
		arbol = function(padre, pos)
			Props.abedul(padre, pos, true)
		end,
		borde = function(padre, pos)
			Props.abedul(padre, pos, false)
		end,
		helechos = 24,
		moras = 10,
		setas = 6,
		piedras = 8,
		rocas = 14,
		ramas = 20,
		enemigos = 16,
		cercaSendero = 9,
	})
	for x = -160, 160, 11 do
		Props.abedul(f, V(x + Util.entre(-3, 3), 0, Util.entre(-44, -32)), false)
	end
	Props.luciernagas(f, S.campamentos[1] + V(0, 5, 0), V(60, 8, 60))
end

return Abedules
