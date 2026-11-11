local Config = require(script.Parent.Config)

local Progreso = {}

function Progreso.objetivo(estado: Instance, jugador: Player?): string
	local function tiene(atributo: string): boolean
		return estado:GetAttribute(atributo) == true
	end
	local function jugadorTiene(atributo: string): boolean
		return jugador ~= nil and jugador:GetAttribute(atributo) == true
	end

	local fase = estado:GetAttribute("Fase")
	if fase == "Final" then
		return "¡Lo habéis conseguido! Mirad hacia el mar..."
	end
	if fase == "UltimaNoche" then
		return "¡Resistid junto al fuego hasta el amanecer! El faro está llamando a vuestros padres."
	end
	if estado:GetAttribute("EstadoLia") == "Asustada" then
		return "Lía tiene miedo y no quiere seguir. Ve a hablar con ella para consolarla."
	end

	local etapa = estado:GetAttribute("Etapa") or 1
	if etapa == 1 and not tiene("Pagina_1") then
		return "Lee la nota de mamá: está en el suelo, junto a la puerta de la furgoneta."
	end
	if not tiene("CampamentoEncendido") then
		return "Recoge ramas (🪵 " .. Config.FUEGO.LENA_ENCENDER .. ") y enciende la hoguera del campamento: sigue el sendero hacia el norte."
	end
	if etapa < #Config.ETAPAS and tiene("Paso_" .. etapa) then
		return "¡El camino está libre! Sigue el sendero con Lía y enciende la hoguera del siguiente campamento (🪵 "
			.. Config.FUEGO.LENA_ENCENDER
			.. ")."
	end

	if etapa == 1 then
		if jugador and not jugadorTiene("TieneHacha") then
			return "Fabrica un hacha de piedra en la mesa del campamento (🪵3 🪨3 🌿2) y corta el tronco que bloquea el sendero."
		end
		return "Corta con el hacha el tronco caído que bloquea el sendero, al norte del campamento."
	elseif etapa == 2 then
		local coste = Config.PASOS.PUENTE
		return string.format(
			"Repara el puente colgante: 🪢 Cuerda %d/%d · 🪵 Leña %d/%d. Las cuerdas se fabrican con fibra en la mesa.",
			estado:GetAttribute("PuenteCuerda") or 0,
			coste.Cuerda,
			estado:GetAttribute("PuenteLena") or 0,
			coste.Lena
		)
	elseif etapa == 3 then
		if jugador and not jugadorTiene("TieneAntorcha") then
			return "Fabrica una antorcha en la mesa y quema las telarañas que tapan la entrada de la cueva (al norte)."
		end
		return "Saca la antorcha y quema las telarañas que tapan la entrada de la cueva (al norte)."
	elseif etapa == 4 then
		local abrigo = if jugador and not jugadorTiene("TieneAbrigo")
			then "Hace un frío terrible: fabrica un abrigo en la mesa o coge uno de la caravana. "
			else ""
		if not tiene("LlaveGuarda") then
			return abrigo .. "Sube a la torre de vigilancia (al este) a por la llave de la barrera."
		end
		return abrigo .. "Abre la barrera del paso con la llave del guarda (al norte)."
	end

	local aceite = estado:GetAttribute("AceiteEncontrado") or 0
	if aceite < Config.FARO.ACEITE then
		return string.format(
			"Busca bidones de aceite por la costa (%d/%d): la cabaña del pescador, la barca vieja y el cobertizo.",
			aceite,
			Config.FARO.ACEITE
		)
	end
	return string.format(
		"Sube a lo alto del faro con leña (🪵 %d/%d) y enciende la lámpara. Preparaos: será la última noche.",
		estado:GetAttribute("FaroLena") or 0,
		Config.FARO.LENA
	)
end

return Progreso
