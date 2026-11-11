local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Clima = require(script.Clima)
local Escenas = require(script.Escenas)
local Hud = require(script.Hud)
local Interfaz = require(script.Interfaz)
local Ventanas = require(script.Ventanas)

local jugador = Players.LocalPlayer
local estado = ReplicatedStorage:WaitForChild("Estado")
local remotos = ReplicatedStorage:WaitForChild("Remotos") :: Folder
local playerGui = jugador:WaitForChild("PlayerGui")

local gui = Interfaz.crear("ScreenGui", {
	Name = "InterfazViaje",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})
local pantalla = Interfaz.crear("ScreenGui", {
	Name = "InterfazPantalla",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 10,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local hud = Hud.crear(gui, pantalla, estado)
local ventanas = Ventanas.crear(gui, pantalla, estado, remotos)
local escenas = Escenas.crear(pantalla, hud)
Clima.iniciar(estado)

local function comer()
	remotos:WaitForChild("Comer"):FireServer()
end
hud.alComer = comer
hud.alCuaderno = ventanas.alternarCuaderno

remotos:WaitForChild("Notificar").OnClientEvent:Connect(hud.notificar)
remotos:WaitForChild("Anuncio").OnClientEvent:Connect(hud.anunciar)
remotos:WaitForChild("MostrarPagina").OnClientEvent:Connect(ventanas.mostrarPagina)
remotos:WaitForChild("AbrirTaller").OnClientEvent:Connect(ventanas.abrirTaller)
remotos:WaitForChild("Subtitulos").OnClientEvent:Connect(escenas.subtitulos)
remotos:WaitForChild("Mirador").OnClientEvent:Connect(function(n, camPos, camMira)
	ventanas.cerrarTodo()
	escenas.mirador(n, camPos, camMira)
end)
remotos:WaitForChild("Tesoro").OnClientEvent:Connect(escenas.tesoro)
remotos:WaitForChild("Victoria").OnClientEvent:Connect(ventanas.final)

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado then
		return
	end
	if entrada.KeyCode == Enum.KeyCode.F then
		comer()
	elseif entrada.KeyCode == Enum.KeyCode.J then
		ventanas.alternarCuaderno()
	end
end)
