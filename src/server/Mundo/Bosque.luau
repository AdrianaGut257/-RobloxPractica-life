local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Props = require(script.Parent.Props)
local Ruta = require(script.Parent.Ruta)
local Util = require(script.Parent.Util)

local Bosque = {}

local V = Vector3.new

local function sitio(zMin: number, zMax: number, valido): Vector3?
	for _ = 1, 40 do
		local p = V(Util.entre(-132, 132), 0, Util.entre(zMin + 4, zMax - 4))
		if valido(p) then
			return p
		end
	end
	return nil
end

function Bosque.poblar(padre: Instance, etapa: number, op)
	local zMin, zMax = op.zMin, op.zMax
	local arboles = Util.carpeta("Arboles", padre)
	local plantas = Util.carpeta("Plantas", padre)

	local sep = op.separacion
	for x = -136, 136, sep do
		for z = zMin, zMax, sep do
			local p = V(x + Util.entre(-sep * 0.45, sep * 0.45), 0, z + Util.entre(-sep * 0.45, sep * 0.45))
			if Ruta.libre(p, op.margen or 10) then
				op.arbol(arboles, p)
			end
		end
	end
	for z = zMin, zMax, 10 do
		for _, lado in { -1, 1 } do
			op.borde(arboles, V(lado * Util.entre(146, 158), 0, z + Util.entre(-4, 4)))
		end
	end

	local function cerca(margen)
		return function(p)
			return Ruta.libre(p, margen)
		end
	end
	local lista = {
		{ op.helechos or 0, Props.helecho },
		{ op.moras or 0, Props.moras },
		{ op.setas or 0, Props.setas },
		{ op.piedras or 0, Props.montonPiedras },
	}
	for _, info in lista do
		for _ = 1, info[1] do
			local p = sitio(zMin, zMax, cerca(4))
			if p then
				info[2](plantas, p)
			end
		end
	end
	for i = 1, op.cercaSendero or 6 do
		local p = sitio(zMin, zMax, function(q)
			return Ruta.libre(q, 3) and Ruta.distanciaSendero(q) < 14
		end)
		if p then
			if i % 3 == 0 then
				Props.montonPiedras(plantas, p)
			elseif i % 3 == 1 then
				Props.helecho(plantas, p)
			else
				Props.moras(plantas, p)
			end
		end
	end
	for _ = 1, op.rocas or 0 do
		local p = sitio(zMin, zMax, cerca(6))
		if p then
			Props.roca(plantas, p, Util.entre(2, 6), op.colorRoca)
		end
	end

	for _, punto in Ruta.puntosCada(9) do
		if Config.etapaEn(punto.pos.Z) == etapa and punto.pos.Z > zMin and punto.pos.Z < zMax then
			local perpendicular = V(-punto.dir.Z, 0, punto.dir.X)
			local lado = if Util.azar:NextNumber() < 0.5 then -1 else 1
			local p = punto.pos + perpendicular * lado * Util.entre(4, 14)
			if Ruta.caminable(p) then
				Props.marcador(p + V(0, 0.4, 0), "PuntoRama", etapa)
			end
		end
	end
	for _ = 1, op.ramas or 20 do
		local p = sitio(zMin, zMax, Ruta.caminable)
		if p then
			Props.marcador(p + V(0, 0.4, 0), "PuntoRama", etapa)
		end
	end

	local campamento = Ruta.SITIOS.campamentos[etapa]
	for _ = 1, op.enemigos or 16 do
		local p = sitio(zMin, zMax, function(q)
			return Ruta.caminable(q) and Ruta.libre(q, 2) and Util.dist2D(q, campamento) > 50
		end)
		if p then
			Props.marcador(p + V(0, 1, 0), "PuntoEnemigo", etapa)
		end
	end
end

return Bosque
