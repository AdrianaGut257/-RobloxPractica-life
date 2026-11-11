local Bosque = require(script.Parent.Parent.Bosque)
local Props = require(script.Parent.Parent.Props)
local Ruta = require(script.Parent.Parent.Ruta)
local Util = require(script.Parent.Parent.Util)

local Rio = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local C = Props.COLORES
local S = Ruta.SITIOS

local function remanso(padre)
	local f = Util.carpeta("Remanso", padre)
	local c = S.remanso
	for _, a in { math.pi, math.pi * 1.5, math.pi * 0.25 } do
		local borde = c + V(math.cos(a) * 32, 0, math.sin(a) * 32)
		Props.pesca(f, CFrame.lookAt(borde, V(c.X, 0, c.Z)))
	end
	for i = 1, 50 do
		local a = i * (math.pi * 2 / 50)
		local r = Util.entre(26.5, 31)
		local h = Util.entre(2, 4.5)
		local p = c + V(math.cos(a) * r, 0, math.sin(a) * r)
		Util.cilindroV(f, 0.18, h, p + V(0, h / 2 - 1, 0), rgb(110, 140, 70), M.SmoothPlastic, DECO)
	end
	for _ = 1, 14 do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(4, 24)
		Util.cilindroV(f, Util.entre(1.4, 2.4), 0.1, c + V(math.cos(a) * r, -1.05, math.sin(a) * r), rgb(70, 150, 70), M.SmoothPlastic, DECO)
	end
	for i = 1, 8 do
		local a = i * 0.8 + 0.3
		Props.roca(f, c + V(math.cos(a) * 33, 0.4, math.sin(a) * 33), Util.entre(2, 3.5))
	end
	Props.luciernagas(f, c + V(0, 4, 0), V(60, 6, 60))
	local nota = c + V(-24, 0, 24)
	Props.roca(f, nota + V(1.6, 0.4, 0.6), 2)
	Props.pagina(f, CFrame.new(nota + V(-0.4, 0.12, -0.6)) * CFrame.Angles(0, 0.7, 0), 4)

	for _, dz in { -0.8, 0.8 } do
		Util.cilindro(f, 1.2, 14, CFrame.new(62, 0.2, 540 + dz), C.tronco, M.Wood)
	end
end

local function cascada(padre)
	local f = Util.carpeta("Cascada", padre)
	local b = Ruta.BARRANCO
	local alto = -1 - (b.fondo + 9)
	local agua = Util.bloque(f, V(8, alto, 0.6), V(62, -1 - alto / 2, b.zMin + 0.4), rgb(170, 215, 235), M.Glass, {
		Deco = true,
		Transparency = 0.35,
	})
	Util.particulas(agua, {
		Color = ColorSequence.new(rgb(240, 250, 255)),
		Transparency = NumberSequence.new(0.3, 1),
		Size = NumberSequence.new(0.6, 1.6),
		Lifetime = NumberRange.new(0.8, 1.4),
		Rate = 30,
		Speed = NumberRange.new(4, 8),
		Acceleration = V(0, -20, 0),
		EmissionDirection = Enum.NormalId.Back,
		SpreadAngle = Vector2.new(10, 10),
	})
	local espuma = Util.bloque(f, V(12, 1, 6), V(62, b.fondo + 9.5, b.zMin + 3), Color3.new(), M.SmoothPlastic, {
		Deco = true,
		Transparency = 1,
	})
	Util.particulas(espuma, {
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(rgb(235, 245, 250)),
		Transparency = NumberSequence.new(0.4, 1),
		Size = NumberSequence.new(3, 8),
		Lifetime = NumberRange.new(2, 3),
		Rate = 10,
		Speed = NumberRange.new(2, 4),
		EmissionDirection = Enum.NormalId.Top,
		SpreadAngle = Vector2.new(40, 40),
	})
	local banco = V(86, 0, b.zMin - 10)
	Props.mirador(f, CFrame.lookAt(banco, V(62, 0, b.zMin)), 2, V(90, 6, b.zMin - 16), V(60, -16, b.zMin + 6))
end

local function puente(padre)
	local m = Util.modelo("Puente", padre)
	local z1, z2 = 596, 644
	local ancho = 6
	local madera = rgb(130, 94, 60)
	local postes = {}
	for _, z in { z1 - 1, z2 + 1 } do
		for _, x in { -3.6, 3.6 } do
			local p = Util.bloque(m, V(1, 6, 1), V(x, 3, z), C.maderaOscura, M.Wood)
			table.insert(postes, p)
		end
	end
	postes[1].Name = "Poste"

	local n = 24
	local function altura(t: number): number
		return -0.25 - 1.6 * math.sin(math.pi * t)
	end
	for i = 0, n - 1 do
		local t = (i + 0.5) / n
		local z = z1 + t * (z2 - z1)
		local pendiente = -1.6 * math.pi / (z2 - z1) * math.cos(math.pi * t)
		local tabla = Util.bloque(
			m,
			V(ancho, 0.5, 1.7),
			CFrame.new(Util.entre(-0.15, 0.15), altura(t), z) * CFrame.Angles(-math.atan(pendiente), 0, Util.entre(-0.03, 0.03)),
			madera:Lerp(rgb(100, 70, 46), Util.entre(0, 0.5)),
			M.WoodPlanks
		)
		tabla.Name = "Tabla"
		tabla:SetAttribute("Orden", i)
		if i >= 3 and i <= n - 4 then
			tabla.Transparency = 1
			tabla.CanCollide = false
			tabla:SetAttribute("Rota", true)
		end
	end

	for _, x in { -3.6, 3.6 } do
		local tramos = 6
		for k = 0, tramos - 1 do
			local ta, tb = k / tramos, (k + 1) / tramos
			local a = V(x, altura(ta) + 3.4, z1 + ta * (z2 - z1))
			local b = V(x, altura(tb) + 3.4, z1 + tb * (z2 - z1))
			local cuerda = Util.barra(m, 0.25, a, b, rgb(196, 170, 120), M.Fabric, DECO)
			cuerda.Name = "Cuerda"
			cuerda.Transparency = 1
		end
	end
	for _, z in { z1 - 1, z2 + 1 } do
		for _, x in { -3.6, 3.6 } do
			local rota = Util.barra(m, 0.25, V(x, 5.5, z), V(x + Util.entre(-0.5, 0.5), -6, z + (if z < 620 then 2 else -2)), rgb(196, 170, 120), M.Fabric, DECO)
			rota.Name = "CuerdaRota"
		end
	end
	for _, x in { -3.4, 3.4 } do
		local muro = Util.bloque(m, V(0.4, 6, z2 - z1), V(x, 1, (z1 + z2) / 2), Color3.new(), M.SmoothPlastic, {
			Name = "Barandilla",
			Transparency = 1,
			CanQuery = false,
		})
		muro.CanCollide = false
	end
	m.PrimaryPart = postes[1]
	Util.etiquetar(m, "Puente")

	Props.pagina(padre, CFrame.new(V(3.6, 3.4, z1 - 1.56)) * CFrame.Angles(math.pi / 2, 0, 0), 5)
	Props.poste(padre, CFrame.new(V(10, 0, z1 - 10)) * CFrame.Angles(0, -math.pi / 2, 0), "Bosque Negro ↑")
	return m
end

function Rio.construir(raiz: Instance)
	local f = Util.carpeta("2_Rio", raiz)
	remanso(f)
	cascada(f)
	puente(f)

	Props.campamento(f, S.campamentos[2], 2, "Campamento 2 · El Río", rgb(70, 130, 200), -0.4)
	Props.provisiones(f, CFrame.new(S.campamentos[2] + V(-6, 0, -12)) * CFrame.Angles(0, 1.2, 0), "Caja")

	Props.provisiones(f, CFrame.new(V(30, 0, 400)) * CFrame.Angles(0, 0.4, 0), "Nevera")
	Props.provisiones(f, CFrame.new(V(-92, 0, 520)) * CFrame.Angles(0, 2.2, 0), "Mochila")
	Props.provisiones(f, CFrame.new(V(104, 0, 360)) * CFrame.Angles(0, 0.9, 0), "Caja")
	Props.provisiones(f, CFrame.new(V(-60, 0, 340)) * CFrame.Angles(0, 0.1, 0), "Mochila")

	Props.tesoro(f, V(-72, 0, 472), 4)
	Props.tesoro(f, V(96, 0, 404), 5)
	Props.tesoro(f, V(-104, 0, 566), 6)

	Props.flores(f, V(-80, 0, 380), 18, 30, { rgb(250, 250, 244), rgb(150, 190, 255), rgb(255, 230, 90) })
	Props.mariposas(f, V(-80, 3, 380), V(30, 4, 30))

	Bosque.poblar(f, 2, {
		zMin = 336,
		zMax = 594,
		separacion = 19,
		arbol = function(padre, pos)
			local r = Util.azar:NextNumber()
			if r < 0.45 then
				Props.roble(padre, pos, true)
			elseif r < 0.75 then
				Props.pino(padre, pos, nil, true)
			else
				Props.abedul(padre, pos, true)
			end
		end,
		borde = function(padre, pos)
			Props.pino(padre, pos, { escala = 1.3 }, false)
		end,
		helechos = 26,
		moras = 10,
		setas = 6,
		piedras = 10,
		rocas = 16,
		ramas = 20,
		enemigos = 16,
		cercaSendero = 9,
	})
	Props.luciernagas(f, S.campamentos[2] + V(0, 5, 0), V(60, 8, 60))
end

return Rio
