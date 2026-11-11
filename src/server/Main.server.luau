local Players = game:GetService("Players")

Players.CharacterAutoLoads = false

local Sistemas = script.Parent.Sistemas
require(Sistemas.Estado)

require(script.Parent.Mundo.Construir).construir()

local ORDEN = {
	"Datos",
	"Inventario",
	"Fogata",
	"Recursos",
	"Lia",
	"Enemigos",
	"Armas",
	"Taller",
	"Recuerdos",
	"Obstaculos",
	"Ciclo",
}
for _, nombre in ORDEN do
	local ok, err = pcall(function()
		require(Sistemas[nombre]).iniciar()
	end)
	if not ok then
		warn("[Rumbo al Faro] No se pudo arrancar " .. nombre .. ": " .. tostring(err))
	end
end

Players.RespawnTime = 6
Players.CharacterAutoLoads = true
for _, jugador in Players:GetPlayers() do
	if not jugador.Character then
		task.spawn(function()
			jugador:LoadCharacter()
		end)
	end
end
print("[Rumbo al Faro] ¡Todo listo! Buen viaje.")
