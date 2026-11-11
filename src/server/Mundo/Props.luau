local Util = require(script.Parent.Util)

local Props = {}

local M = Enum.Material
local rgb = Util.rgb
local DECO = Util.DECO
local V = Vector3.new

Props.COLORES = {
	tronco = rgb(105, 76, 52),
	troncoOscuro = rgb(64, 52, 44),
	abedul = rgb(232, 228, 216),
	mancha = rgb(40, 38, 36),
	hojas = rgb(78, 140, 62),
	helecho = rgb(70, 132, 60),
	nieve = rgb(245, 248, 255),
	piedra = rgb(132, 130, 126),
	madera = rgb(146, 104, 66),
	maderaOscura = rgb(98, 70, 46),
	pergamino = rgb(240, 228, 196),
	oro = rgb(255, 204, 96),
	fuego = rgb(255, 170, 80),
}
local C = Props.COLORES

local ABEDUL_HOJAS = {
	rgb(150, 196, 86),
	rgb(176, 204, 92),
	rgb(214, 196, 84),
	rgb(128, 178, 78),
}

Props.marcadores = nil :: Folder?

function Props.marcador(pos: Vector3, etiqueta: string, etapa: number?)
	local p = Util.parte({
		Parent = Props.marcadores,
		Name = etiqueta,
		Size = V(1, 1, 1),
		Position = pos,
		Transparency = 1,
		Deco = true,
		Etiqueta = etiqueta,
	})
	if etapa then
		p:SetAttribute("Etapa", etapa)
	end
	return p
end

function Props.ramasAlrededor(base: Vector3, cantidad: number, rMin: number, rMax: number, etapa: number)
	for _ = 1, cantidad do
		local angulo = Util.entre(0, math.pi * 2)
		local r = Util.entre(rMin, rMax)
		Props.marcador(base + V(math.cos(angulo) * r, 0.4, math.sin(angulo) * r), "PuntoRama", etapa)
	end
end

local function centro(m: Model, pos: Vector3, tam: Vector3?)
	local p = Util.bloque(m, tam or V(1.5, 1.5, 1.5), pos, Color3.new(), M.SmoothPlastic, {
		Name = "Centro",
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	m.PrimaryPart = p
	return p
end

local function marcarTalable(m: Model, talable: boolean?)
	if talable then
		Util.etiquetar(m, "Talable")
	end
end

function Props.abedul(padre, base: Vector3, talable: boolean?)
	local m = Util.modelo("Abedul", padre)
	local h = Util.entre(14, 20)
	local d = Util.entre(1.1, 1.5)
	local tronco = Util.cilindroV(m, d, h, base + V(0, h / 2, 0), C.abedul, M.SmoothPlastic)
	tronco.Name = "Tronco"
	for _ = 1, 3 do
		local y = Util.entre(1, h - 3)
		local a = Util.entre(0, math.pi * 2)
		Util.bloque(
			m,
			V(d * 0.55, Util.entre(0.12, 0.25), 0.14),
			CFrame.new(base + V(math.cos(a) * d * 0.47, y, math.sin(a) * d * 0.47)) * CFrame.Angles(0, -a - math.pi / 2, 0),
			C.mancha,
			M.SmoothPlastic,
			DECO
		)
	end
	local color = Util.elegir(ABEDUL_HOJAS)
	for _ = 1, 5 do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(0.4, 2.6)
		local y = h * Util.entre(0.55, 0.95)
		Util.elipsoide(
			m,
			V(Util.entre(4, 6.5), Util.entre(3.5, 5), Util.entre(4, 6.5)),
			base + V(math.cos(a) * r, y, math.sin(a) * r),
			color:Lerp(rgb(230, 220, 120), Util.entre(0, 0.25)),
			M.LeafyGrass,
			DECO
		)
	end
	Util.elipsoide(m, V(3.5, 4.5, 3.5), base + V(0, h + 1, 0), color, M.LeafyGrass, DECO)
	m.PrimaryPart = tronco
	marcarTalable(m, talable)
	return m
end

function Props.pino(padre, base: Vector3, opciones, talable: boolean?)
	opciones = opciones or {}
	local s = Util.entre(0.85, 1.35) * (opciones.escala or 1)
	local m = Util.modelo("Pino", padre)
	local hTronco = 5 * s
	local niveles = 4
	local alturaTotal = hTronco + niveles * 3.4 * s
	local tronco = Util.cilindroV(
		m,
		1.3 * s,
		alturaTotal,
		base + V(0, alturaTotal / 2, 0),
		if opciones.oscuro then C.troncoOscuro else C.tronco,
		M.Wood
	)
	tronco.Name = "Tronco"
	local verde = opciones.color or (if opciones.oscuro then rgb(30, 54, 42) else rgb(46, 94, 58))
	for i = 1, niveles do
		local t = (i - 1) / (niveles - 1)
		local ancho = (10 - 6.5 * t) * s
		local alto = (4.6 - 0.8 * t) * s
		local y = hTronco + (i - 1) * 3.4 * s + alto / 2 - 0.5
		Util.elipsoide(m, V(ancho, alto, ancho), base + V(0, y, 0), verde:Lerp(rgb(20, 40, 30), Util.entre(0, 0.25)), M.LeafyGrass, DECO)
		if opciones.nieve then
			Util.elipsoide(m, V(ancho * 0.82, alto * 0.45, ancho * 0.82), base + V(0, y + alto * 0.32, 0), C.nieve, M.Snow, DECO)
		end
	end
	Util.elipsoide(m, V(2 * s, 4 * s, 2 * s), base + V(0, alturaTotal + 1.2 * s, 0), verde, M.LeafyGrass, DECO)
	if opciones.nieve then
		Util.elipsoide(m, V(1.6 * s, 1.4 * s, 1.6 * s), base + V(0, alturaTotal + 2.6 * s, 0), C.nieve, M.Snow, DECO)
	end
	m.PrimaryPart = tronco
	marcarTalable(m, talable)
	return m
end

function Props.roble(padre, base: Vector3, talable: boolean?, colorHojas: Color3?)
	local h = Util.entre(11, 16)
	local m = Util.modelo("Roble", padre)
	local hTronco = h * 0.55
	local tronco = Util.cilindroV(m, Util.entre(1.6, 2.2), hTronco, base + V(0, hTronco / 2, 0), C.tronco, M.Wood)
	tronco.Name = "Tronco"
	local copa = base + V(0, hTronco + h * 0.15, 0)
	local color = colorHojas or C.hojas
	Util.elipsoide(m, V(h * 0.75, h * 0.5, h * 0.75), copa, color, M.LeafyGrass, DECO)
	for i = 1, 4 do
		local a = i * math.pi / 2 + Util.entre(-0.4, 0.4)
		local offset = V(math.cos(a) * h * 0.25, Util.entre(-0.5, 1.5), math.sin(a) * h * 0.25)
		Util.elipsoide(m, V(h * 0.45, h * 0.35, h * 0.45), copa + offset, color:Lerp(rgb(120, 170, 70), Util.entre(0, 0.3)), M.LeafyGrass, DECO)
	end
	m.PrimaryPart = tronco
	marcarTalable(m, talable)
	return m
end

function Props.arbolSeco(padre, base: Vector3, talable: boolean?, color: Color3?)
	local m = Util.modelo("ArbolSeco", padre)
	local alto = Util.entre(9, 14)
	local c = color or C.troncoOscuro
	local tronco = Util.cilindroV(m, 1.7, alto, base + V(0, alto / 2, 0), c, M.Wood)
	tronco.Name = "Tronco"
	for i = 1, 4 do
		local a = i * 1.6 + Util.entre(-0.4, 0.4)
		local desde = base + V(0, alto * Util.entre(0.55, 0.9), 0)
		local hasta = desde + V(math.cos(a) * Util.entre(3, 5), Util.entre(2, 4), math.sin(a) * Util.entre(3, 5))
		Util.barra(m, 0.5, desde, hasta, c, M.Wood, DECO)
	end
	m.PrimaryPart = tronco
	marcarTalable(m, talable)
	return m
end

function Props.arbolViejo(padre, base: Vector3)
	local m = Util.modelo("ArbolViejo", padre)
	local alto = 30
	local tronco = Util.cilindroV(m, 9, alto, base + V(0, alto / 2, 0), rgb(78, 62, 48), M.Wood)
	tronco.Name = "Tronco"
	Util.cilindroV(m, 11, 4, base + V(0, 2, 0), rgb(70, 56, 44), M.Wood)
	for i = 1, 8 do
		local a = i * (math.pi / 4) + Util.entre(-0.2, 0.2)
		local desde = base + V(math.cos(a) * 3, 3, math.sin(a) * 3)
		local hasta = base + V(math.cos(a) * 10, -0.4, math.sin(a) * 10)
		Util.barra(m, 1.6, desde, hasta, rgb(72, 58, 46), M.Wood)
	end
	for i = 1, 5 do
		local a = i * 1.25
		local desde = base + V(0, alto - 6, 0)
		local hasta = base + V(math.cos(a) * 14, alto + 4, math.sin(a) * 14)
		Util.barra(m, 1.8, desde, hasta, rgb(78, 62, 48), M.Wood, DECO)
		Util.elipsoide(m, V(16, 9, 16), hasta + V(0, 2, 0), rgb(40, 74, 46):Lerp(rgb(60, 96, 52), Util.entre(0, 1)), M.LeafyGrass, DECO)
	end
	Util.elipsoide(m, V(24, 12, 24), base + V(0, alto + 6, 0), rgb(44, 80, 48), M.LeafyGrass, DECO)
	for _ = 1, 10 do
		local a = Util.entre(0, math.pi * 2)
		local y = Util.entre(2, alto - 4)
		Util.elipsoide(m, V(2.6, 1.4, 2.6), base + V(math.cos(a) * 4.4, y, math.sin(a) * 4.4), rgb(70, 120, 56), M.LeafyGrass, DECO)
	end
	for _ = 1, 16 do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(6, 14)
		local p = base + V(math.cos(a) * r, 0, math.sin(a) * r)
		local h = Util.entre(0.5, 1.2)
		Util.cilindroV(m, 0.25, h, p + V(0, h / 2, 0), rgb(220, 235, 230), M.SmoothPlastic, DECO)
		local sombrero = Util.elipsoide(m, V(1, 0.45, 1), p + V(0, h + 0.1, 0), rgb(110, 230, 255), M.Neon, DECO)
		if Util.azar:NextNumber() < 0.3 then
			Util.luz(sombrero, rgb(110, 220, 255), 8, 0.8)
		end
	end
	m.PrimaryPart = tronco
	return m
end

function Props.helecho(padre, base: Vector3, color: Color3?)
	local m = Util.modelo("Helecho", padre)
	centro(m, base + V(0, 0.8, 0))
	local c = color or C.helecho
	local n = Util.azar:NextInteger(6, 8)
	for i = 1, n do
		local a = i * (math.pi * 2 / n) + Util.entre(-0.2, 0.2)
		local largo = Util.entre(2.2, 3.4)
		local cf = CFrame.new(base + V(0, 0.25, 0))
			* CFrame.Angles(0, a, 0)
			* CFrame.Angles(math.rad(Util.entre(30, 55)), 0, 0)
			* CFrame.new(0, 0, -largo / 2)
		Util.bloque(m, V(0.9, 0.12, largo), cf, c:Lerp(rgb(120, 170, 70), Util.entre(0, 0.3)), M.LeafyGrass, {
			Deco = true,
			Name = "Hoja",
		})
	end
	Util.etiquetar(m, "Fibra")
	return m
end

function Props.moras(padre, base: Vector3)
	local m = Util.modelo("Moras", padre)
	centro(m, base + V(0, 1.2, 0))
	local copa = base + V(0, 1.4, 0)
	Util.elipsoide(m, V(4.2, 3, 4.2), copa, rgb(52, 98, 46), M.LeafyGrass, DECO)
	Util.elipsoide(m, V(3, 2.4, 3), copa + V(1.2, 0.5, 0.6), rgb(62, 110, 52), M.LeafyGrass, DECO)
	for i = 1, 8 do
		local a = i * (math.pi * 2 / 8) + Util.entre(-0.2, 0.2)
		local p = copa + V(math.cos(a) * 1.9, Util.entre(-0.6, 0.9), math.sin(a) * 1.9)
		local fruto = Util.bola(m, 0.5, p, rgb(70, 20, 60), M.SmoothPlastic, DECO)
		fruto.Name = "Fruto"
	end
	Util.etiquetar(m, "Moras")
	return m
end

function Props.setas(padre, base: Vector3)
	local m = Util.modelo("Setas", padre)
	centro(m, base + V(0, 0.6, 0))
	for _ = 1, Util.azar:NextInteger(3, 5) do
		local p = base + V(Util.entre(-1, 1), 0, Util.entre(-1, 1))
		local h = Util.entre(0.5, 1)
		Util.cilindroV(m, 0.3, h, p + V(0, h / 2, 0), rgb(236, 228, 210), M.SmoothPlastic, { Deco = true, Name = "Seta" })
		Util.elipsoide(m, V(1.1, 0.5, 1.1), p + V(0, h + 0.12, 0), rgb(176, 112, 60), M.SmoothPlastic, { Deco = true, Name = "Seta" })
	end
	Util.etiquetar(m, "Setas")
	return m
end

function Props.flores(padre, centroPos: Vector3, radio: number, n: number, colores)
	for _ = 1, n do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(0, radio)
		local p = centroPos + V(math.cos(a) * r, 0, math.sin(a) * r)
		local h = Util.entre(0.6, 1.2)
		Util.bloque(padre, V(0.14, h, 0.14), p + V(0, h / 2, 0), rgb(70, 130, 55), M.SmoothPlastic, DECO)
		Util.bola(padre, Util.entre(0.45, 0.65), p + V(0, h + 0.15, 0), Util.elegir(colores), M.SmoothPlastic, DECO)
	end
end

function Props.roca(padre, pos: Vector3, tam: number, color: Color3?, material: Enum.Material?)
	local base = color or C.piedra
	return Util.elipsoide(
		padre,
		V(tam * Util.entre(0.9, 1.4), tam * Util.entre(0.5, 0.8), tam * Util.entre(0.9, 1.3)),
		CFrame.new(pos) * CFrame.Angles(0, Util.entre(0, 3), 0),
		base:Lerp(rgb(160, 150, 135), Util.entre(0, 0.6)),
		material or M.Slate
	)
end

function Props.montonPiedras(padre, base: Vector3)
	local m = Util.modelo("Piedras", padre)
	centro(m, base + V(0, 1, 0), V(3, 2, 3))
	for i = 1, 6 do
		local a = i * 1.05
		local r = if i == 6 then 0 else Util.entre(0.6, 1.4)
		local tam = Util.entre(0.9, 1.5)
		local p = base + V(math.cos(a) * r, tam * 0.3 + (if i == 6 then 0.7 else 0), math.sin(a) * r)
		local piedra = Util.elipsoide(
			m,
			V(tam * 1.2, tam * 0.75, tam),
			CFrame.new(p) * CFrame.Angles(0, Util.entre(0, 3), Util.entre(-0.3, 0.3)),
			C.piedra:Lerp(rgb(170, 165, 150), Util.entre(0, 0.6)),
			M.Slate,
			DECO
		)
		piedra.Name = "Piedra"
	end
	Util.etiquetar(m, "Piedras")
	return m
end

function Props.troncoTumbado(padre, cf: CFrame, largo: number, diametro: number?)
	local d = diametro or 1.8
	local t = Util.cilindro(padre, d, largo, cf * CFrame.new(0, d / 2, 0), C.tronco, M.Wood)
	Util.cilindro(padre, d * 0.8, 0.1, cf * CFrame.new(largo / 2 + 0.02, d / 2, 0), rgb(196, 160, 110), M.Wood, DECO)
	Util.cilindro(padre, d * 0.8, 0.1, cf * CFrame.new(-largo / 2 - 0.02, d / 2, 0), rgb(196, 160, 110), M.Wood, DECO)
	Util.bloque(padre, V(largo * 0.5, 0.2, d * 0.6), cf * CFrame.new(Util.entre(-1, 1), d + 0.02, 0), rgb(76, 126, 60), M.LeafyGrass, DECO)
	return t
end

function Props.tocon(padre, base: Vector3, diametro: number?, alto: number?)
	local d = diametro or 2.6
	local h = alto or 1.6
	local t = Util.cilindroV(padre, d, h, base + V(0, h / 2, 0), C.tronco, M.Wood)
	Util.cilindroV(padre, d * 0.85, 0.08, base + V(0, h + 0.03, 0), rgb(200, 164, 112), M.Wood, DECO)
	return t
end

local function tienda(padre, base: Vector3, color: Color3)
	Util.fronton(padre, base, 7, 5, 8, color, M.Fabric)
	Util.cuna(padre, V(2.4, 3, 0.2), CFrame.new(base + V(0, 1.5, -4.05)) * CFrame.Angles(0, math.pi, 0), rgb(40, 34, 30), M.Fabric, DECO)
	Util.bloque(padre, V(8, 0.15, 9), base + V(0, 0.08, 0), rgb(90, 80, 60), M.Fabric, DECO)
end

function Props.campamento(padre, centroPos: Vector3, etapa: number, nombre: string, colorTienda: Color3, giro: number?)
	local m = Util.modelo("Campamento_" .. etapa, padre)
	m:SetAttribute("Etapa", etapa)
	local cf = CFrame.new(centroPos) * CFrame.Angles(0, giro or 0, 0)
	local function en(x, y, z)
		return cf * CFrame.new(x, y, z)
	end

	for i = 1, 9 do
		local a = i * (math.pi * 2 / 9)
		Util.elipsoide(m, V(1.1, 0.7, 1.1), en(math.cos(a) * 2.3, 0.3, math.sin(a) * 2.3), rgb(110, 108, 104), M.Slate, DECO)
	end
	for i = 1, 3 do
		local a = i * (math.pi / 3)
		Util.cilindro(m, 0.6, 3.6, en(0, 0.5, 0) * CFrame.Angles(0, a, 0.25), C.maderaOscura, M.Wood, DECO)
	end
	local brasas = Util.cilindroV(m, 2.2, 0.3, en(0, 0.2, 0).Position, rgb(60, 40, 30), M.SmoothPlastic, DECO)
	brasas.Name = "Brasas"

	for i = 1, 14 do
		local a = i * (math.pi * 2 / 14)
		local p = Util.elipsoide(m, V(1.3, 1, 1.3), en(math.cos(a) * 3.4, 0.45, math.sin(a) * 3.4), rgb(140, 136, 128), M.Slate, DECO)
		p.Name = "Nivel2"
		p.Transparency = 1
	end
	for i = 1, 5 do
		local a = i * (math.pi * 2 / 5)
		local p = Util.cilindro(m, 0.9, 5, en(math.cos(a) * 0.8, 1.6, math.sin(a) * 0.8) * CFrame.Angles(0, a, math.rad(62)), C.madera, M.Wood, DECO)
		p.Name = "Nivel3"
		p.Transparency = 1
	end

	local fuego = Util.bloque(m, V(2, 2, 2), en(0, 1.2, 0), Color3.new(), M.SmoothPlastic, {
		Name = "Fuego",
		Transparency = 1,
		CanCollide = false,
	})
	local llamas = Instance.new("Fire")
	llamas.Size = 6
	llamas.Heat = 9
	llamas.Color = rgb(255, 140, 50)
	llamas.SecondaryColor = rgb(255, 220, 120)
	llamas.Enabled = false
	llamas.Parent = fuego
	local luz = Util.luz(fuego, rgb(255, 170, 90), 30, 2.5, true)
	luz.Enabled = false
	local chispas = Util.particulas(fuego, {
		Color = ColorSequence.new(rgb(255, 200, 110), rgb(255, 110, 40)),
		LightEmission = 1,
		Size = NumberSequence.new(0.18, 0.02),
		Lifetime = NumberRange.new(1, 2.4),
		Rate = 10,
		Speed = NumberRange.new(3, 7),
		SpreadAngle = Vector2.new(25, 25),
		Acceleration = V(0, 2, 0),
		EmissionDirection = Enum.NormalId.Top,
		Enabled = false,
	})
	chispas.Name = "Chispas"
	local humo = Util.particulas(fuego, {
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(rgb(90, 90, 90)),
		Transparency = NumberSequence.new(0.6, 1),
		Size = NumberSequence.new(2, 7),
		Lifetime = NumberRange.new(4, 6),
		Rate = 3,
		Speed = NumberRange.new(2, 4),
		SpreadAngle = Vector2.new(10, 10),
		Enabled = false,
	})
	humo.Name = "Humo"

	local asiento = Props.troncoTumbado(m, en(0, 0, 6.5), 6, 1.6)
	asiento.Name = "Asiento"
	Props.troncoTumbado(m, en(-6.5, 0, 0) * CFrame.Angles(0, math.pi / 2, 0), 5, 1.6)

	local mesa = Util.modelo("Mesa", m)
	local tablero = Props.tocon(mesa, en(7, 0, -2).Position, 3.4, 2.4)
	tablero.Name = "Tablero"
	mesa.PrimaryPart = tablero
	local arriba = en(7, 2.45, -2)
	Util.bloque(mesa, V(1.6, 0.15, 0.5), arriba * CFrame.new(-0.4, 0.08, 0.6) * CFrame.Angles(0, 0.4, 0), rgb(170, 170, 176), M.Metal, DECO)
	Util.bloque(mesa, V(0.25, 0.25, 1.2), arriba * CFrame.new(-0.4, 0.12, -0.2) * CFrame.Angles(0, 0.4, 0), C.maderaOscura, M.Wood, DECO)
	Util.cilindroV(mesa, 1, 0.4, (arriba * CFrame.new(0.7, 0.2, -0.3)).Position, rgb(196, 170, 110), M.Fabric, DECO)
	Util.elipsoide(mesa, V(0.8, 0.5, 0.6), arriba * CFrame.new(0.6, 0.25, 0.7), rgb(120, 118, 112), M.Slate, DECO)

	tienda(m, en(-3, 0, -10).Position, colorTienda)
	for i = 0, 2 do
		for j = 0, 2 - i do
			Util.cilindro(m, 0.8, 3, en(-8.5 + j * 0.85 + i * 0.42, 0.4 + i * 0.7, 5) * CFrame.Angles(0, math.pi / 2, 0), C.maderaOscura, M.Wood, DECO)
		end
	end

	local poste = Util.bloque(m, V(0.4, 5, 0.4), en(10, 2.5, 6), C.maderaOscura, M.Wood)
	poste.Name = "Poste"
	local tabla = Util.bloque(m, V(5.6, 2, 0.25), en(10, 4.4, 6) * CFrame.Angles(0, math.pi, 0), C.madera, M.WoodPlanks, DECO)
	Util.letrero(tabla, Enum.NormalId.Front, "⛺ " .. nombre, rgb(55, 38, 24))
	Util.letrero(tabla, Enum.NormalId.Back, "⛺ " .. nombre, rgb(55, 38, 24))

	local aparicion = Util.bloque(m, V(1, 1, 1), en(-4, 0.5, 2), Color3.new(), M.SmoothPlastic, {
		Name = "Aparicion",
		Transparency = 1,
		Deco = true,
	})
	aparicion:SetAttribute("Etapa", etapa)

	m.PrimaryPart = fuego
	Util.etiquetar(m, "Campamento")
	return m
end

function Props.provisiones(padre, cf: CFrame, tipo: string)
	local m = Util.modelo(tipo, padre)
	local cuerpo
	if tipo == "Mochila" then
		local color = Util.elegir({ rgb(190, 70, 60), rgb(60, 110, 170), rgb(220, 160, 50), rgb(80, 130, 80) })
		cuerpo = Util.bloque(m, V(1.8, 2.2, 1.1), cf * CFrame.new(0, 1.1, 0) * CFrame.Angles(math.rad(-12), 0, 0), color, M.Fabric)
		Util.bloque(m, V(1.6, 0.9, 0.5), cf * CFrame.new(0, 0.8, -0.65) * CFrame.Angles(math.rad(-12), 0, 0), color:Lerp(Color3.new(), 0.2), M.Fabric, DECO)
		Util.bloque(m, V(1.9, 0.6, 1.2), cf * CFrame.new(0, 2.1, 0.15) * CFrame.Angles(math.rad(-12), 0, 0), color:Lerp(Color3.new(), 0.1), M.Fabric, DECO)
	elseif tipo == "Nevera" then
		cuerpo = Util.bloque(m, V(2.6, 1.6, 1.6), cf * CFrame.new(0, 0.8, 0), rgb(235, 238, 240), M.SmoothPlastic)
		Util.bloque(m, V(2.7, 0.35, 1.7), cf * CFrame.new(0, 1.75, 0), rgb(50, 110, 190), M.SmoothPlastic, DECO)
		Util.bloque(m, V(1.2, 0.2, 0.3), cf * CFrame.new(0, 2.02, 0), rgb(40, 40, 44), M.SmoothPlastic, DECO)
	else
		cuerpo = Util.bloque(m, V(2.4, 1.6, 1.8), cf * CFrame.new(0, 0.8, 0), rgb(156, 112, 70), M.WoodPlanks)
		for _, x in { -0.95, 0.95 } do
			Util.bloque(m, V(0.2, 1.65, 1.85), cf * CFrame.new(x, 0.82, 0), rgb(110, 78, 50), M.Wood, DECO)
		end
		Util.bloque(m, V(2.45, 0.2, 1.85), cf * CFrame.new(0, 1.62, 0), rgb(120, 86, 54), M.WoodPlanks, DECO)
	end
	cuerpo.Name = "Cuerpo"
	m.PrimaryPart = cuerpo
	m:SetAttribute("Tipo", tipo)
	Util.etiquetar(m, "Provisiones")
	return m
end

function Props.pagina(padre, cf: CFrame, numero: number)
	local p = Util.bloque(padre, V(1.3, 0.06, 1.7), cf, C.pergamino, M.SmoothPlastic, {
		CanCollide = false,
		CanTouch = false,
		Name = "Pagina_" .. numero,
	})
	Util.luz(p, rgb(255, 240, 200), 6, 1.2)
	local brillo = Instance.new("Sparkles")
	brillo.SparkleColor = rgb(255, 240, 200)
	brillo.Parent = p
	p:SetAttribute("Numero", numero)
	Util.etiquetar(p, "Pagina")
	return p
end

function Props.tesoro(padre, pos: Vector3, numero: number)
	local p = Util.bola(padre, 0.7, pos + V(0, 0.4, 0), rgb(255, 236, 170), M.Neon, {
		CanCollide = false,
		CanTouch = false,
		Name = "Tesoro_" .. numero,
	})
	Util.luz(p, rgb(255, 220, 150), 7, 1.4)
	local brillo = Instance.new("Sparkles")
	brillo.SparkleColor = rgb(255, 210, 120)
	brillo.Parent = p
	p:SetAttribute("Numero", numero)
	Util.etiquetar(p, "Tesoro")
	return p
end

function Props.mirador(padre, cf: CFrame, numero: number, camPos: Vector3, camMira: Vector3)
	local m = Util.modelo("Mirador_" .. numero, padre)
	local asiento = Util.parte({
		Clase = "Seat",
		Parent = m,
		Name = "Asiento",
		Size = V(5, 0.5, 1.6),
		CFrame = cf * CFrame.new(0, 1.6, 0),
		Color = C.madera,
		Material = M.WoodPlanks,
	})
	Util.bloque(m, V(5, 1.4, 0.35), cf * CFrame.new(0, 2.6, 0.75) * CFrame.Angles(math.rad(-12), 0, 0), C.madera, M.WoodPlanks, DECO)
	for _, x in { -2, 2 } do
		Util.bloque(m, V(0.5, 1.4, 1.4), cf * CFrame.new(x, 0.7, 0), C.maderaOscura, M.Wood)
	end
	local brillo = Util.bloque(m, V(1, 1, 1), cf * CFrame.new(0, 2.4, 0), Color3.new(), M.SmoothPlastic, {
		Deco = true,
		Transparency = 1,
		Name = "Brillo",
	})
	local chispas = Instance.new("Sparkles")
	chispas.SparkleColor = rgb(180, 220, 255)
	chispas.Parent = brillo
	m.PrimaryPart = asiento
	m:SetAttribute("Numero", numero)
	m:SetAttribute("CamPos", camPos)
	m:SetAttribute("CamMira", camMira)
	Util.etiquetar(m, "Mirador")
	return m
end

function Props.pesca(padre, cf: CFrame)
	local m = Util.modelo("Pesca", padre)
	local tabla = Util.bloque(m, V(4, 0.4, 9), cf * CFrame.new(0, 0.2, -3.5), C.madera, M.WoodPlanks)
	tabla.Name = "Muelle"
	for _, x in { -1.7, 1.7 } do
		for _, z in { -7.5, -2 } do
			Util.bloque(m, V(0.5, 4, 0.5), cf * CFrame.new(x, -1.6, z), C.maderaOscura, M.Wood, DECO)
		end
	end
	Util.barra(m, 0.16, (cf * CFrame.new(1.3, 0.5, -1)).Position, (cf * CFrame.new(1.6, 4.5, -6)).Position, C.maderaOscura, M.Wood, DECO)
	Util.cilindroV(m, 1, 1, (cf * CFrame.new(-1.2, 0.9, -1)).Position, rgb(120, 130, 140), M.Metal, DECO)
	m.PrimaryPart = tabla
	Util.etiquetar(m, "Pesca")
	return m
end

function Props.poste(padre, cf: CFrame, texto: string)
	Util.bloque(padre, V(0.45, 6, 0.45), cf * CFrame.new(0, 3, 0), C.maderaOscura, M.Wood)
	local tabla = Util.bloque(padre, V(4.6, 1.3, 0.25), cf * CFrame.new(1.4, 5, 0), C.madera, M.WoodPlanks, DECO)
	Util.cuna(padre, V(0.25, 1.3, 0.9), cf * CFrame.new(4.15, 5, 0) * CFrame.Angles(0, -math.pi / 2, 0), C.madera, M.WoodPlanks, DECO)
	Util.letrero(tabla, Enum.NormalId.Front, texto, rgb(55, 38, 24))
	Util.letrero(tabla, Enum.NormalId.Back, texto, rgb(55, 38, 24))
end

function Props.luciernagas(padre, centroPos: Vector3, tam: Vector3, siempre: boolean?)
	local p = Util.bloque(padre, tam, centroPos, Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	p.Name = "Luciernagas"
	local e = Util.particulas(p, {
		Color = ColorSequence.new(rgb(220, 255, 120)),
		LightEmission = 1,
		LightInfluence = 0,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0.25),
			NumberSequenceKeypoint.new(0.8, 0.25),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Lifetime = NumberRange.new(4, 7),
		Rate = math.max(2, tam.X * tam.Z / 400),
		Speed = NumberRange.new(0.3, 1.2),
		SpreadAngle = Vector2.new(180, 180),
		Acceleration = V(0, 0.15, 0),
		Enabled = siempre == true,
	})
	if not siempre then
		Util.etiquetar(e, "Luciernagas")
	end
	return p
end

function Props.mariposas(padre, centroPos: Vector3, tam: Vector3)
	local p = Util.bloque(padre, tam, centroPos, Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	p.Name = "Mariposas"
	local e = Util.particulas(p, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, rgb(255, 230, 90)),
			ColorSequenceKeypoint.new(0.5, rgb(255, 160, 210)),
			ColorSequenceKeypoint.new(1, rgb(150, 200, 255)),
		}),
		LightInfluence = 1,
		Size = NumberSequence.new(0.35),
		Lifetime = NumberRange.new(5, 8),
		Rate = math.max(1, tam.X * tam.Z / 900),
		Speed = NumberRange.new(1, 2.5),
		SpreadAngle = Vector2.new(180, 180),
		RotSpeed = NumberRange.new(-200, 200),
		Enabled = true,
	})
	Util.etiquetar(e, "Mariposas")
	return p
end

return Props
