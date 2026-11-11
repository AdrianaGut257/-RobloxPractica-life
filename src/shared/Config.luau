local Config = {}

Config.DURACION_DIA = 270
Config.DURACION_NOCHE = 150
Config.DURACION_ULTIMA_NOCHE = 210
Config.AVISO_ANOCHECER = 25

Config.ETAPAS = {
	{ id = "Abedules", nombre = "El Bosque de Abedules", icono = "🌳", zMax = 320 },
	{ id = "Rio", nombre = "El Río", icono = "🌊", zMax = 642 },
	{ id = "BosqueNegro", nombre = "El Bosque Negro", icono = "🌲", zMax = 988, enemigosDeDia = 3 },
	{ id = "PasoNevado", nombre = "El Paso Nevado", icono = "❄️", zMax = 1278, frio = true },
	{ id = "Faro", nombre = "El Faro", icono = "🗼", zMax = math.huge },
}

function Config.etapaEn(z: number): number
	for i, etapa in Config.ETAPAS do
		if z < etapa.zMax then
			return i
		end
	end
	return #Config.ETAPAS
end

Config.FUEGO = {
	LENA_ENCENDER = 3,
	COMBUSTIBLE_INICIAL = 70,
	POR_LENA = 12,
	GASTO_DIA = 0.22,
	GASTO_NOCHE = 0.55,
	DANO_LUZ = 18,
	DISTANCIA_LIA = 45,
	NIVELES = {
		[1] = { maximo = 100, radio = 26 },
		[2] = { maximo = 160, radio = 36 },
		[3] = { maximo = 240, radio = 48 },
	},
}

Config.HAMBRE = {
	MAXIMA = 100,
	GASTO = 0.2,
	DANO_SIN_COMIDA = 2,
	POR_COMIDA = 35,
	CURA_COMIDA = 10,
	AL_REAPARECER = 60,
}

Config.FRIO = {
	MAXIMO = 100,
	GASTO = 1.2,
	GASTO_NOCHE = 1.8,
	CON_ABRIGO = 0.35,
	RECUPERA = 6,
	DANO = 3,
}

Config.LIA = {
	VELOCIDAD = 15,
	VELOCIDAD_CORRER = 21,
	DISTANCIA_SEGUIR = 9,
	DISTANCIA_ALEJARSE = 22,
	DISTANCIA_CORRER = 30,
	CURIOSEAR_CADA = { 5, 12 },
	DISTANCIA_PERDIDA = 95,
	ANIMO_INICIAL = 80,
	ANIMO_MAXIMO = 100,
	ASUSTADA = 25,
	CONTENTA = 70,
	BAJA_DIA = 0.05,
	BAJA_OSCURIDAD = 0.9,
	BAJA_ENEMIGO = 0.6,
	BAJA_FRIO = 0.15,
	GOLPE = 12,
	SUBE_HABLAR = 6,
	ESPERA_HABLAR = 25,
	SUBE_CONSOLAR = 30,
	SUBE_COMIDA = 18,
	SUBE_TESORO = 12,
	SUBE_CHARLA = 25,
	SUBE_MIRADOR = 10,
	SUBE_CAMPAMENTO = 10,
	SUBE_PASO = 8,
	BUSCAR_CADA = 70,
}

Config.RECURSOS = {
	RAMAS_POR_ETAPA = 14,
	REAPARICION_RAMAS = 5,
	PROVISIONES_RECARGA = 200,
	MORAS_POR_ARBUSTO = 3,
	MORA_RECRECE = 45,
	FIBRA_RECRECE = 60,
	SETA_RECRECE = 90,
	PIEDRAS_POR_MONTON = 4,
	PIEDRA_RECARGA = 25,
	PESCA_DURACION = 2.5,
	PESCA_PROBABILIDAD = 0.65,
	PESCA_COMIDA = 2,
	ARBOL_VIDA = 6,
	LENA_POR_ARBOL = 3,
	ARBOL_RECRECE = 150,
	DURACION_SUELTO = 120,
}

Config.ARMAS = {
	Palo = { dano = 14, alcance = 7, cadencia = 0.5, tala = 1 },
	Hacha = { dano = 30, alcance = 8, cadencia = 0.6, tala = 3, troncos = true },
	Lanza = { dano = 46, alcance = 11, cadencia = 0.75, tala = 1 },
	Antorcha = { dano = 12, alcance = 7, cadencia = 0.6, tala = 0 },
}
Config.ANTORCHA = {
	RADIO = 20,
	LENTITUD = 0.5,
}

Config.ENEMIGOS = {
	MAXIMO_VIVOS = 22,
	BASE = 3,
	POR_NOCHE = 2,
	VIDA_POR_NOCHE = 0.08,
	ULTIMA_NOCHE = 36,
	TIPOS = {
		Brumoso = {
			nombre = "Brumoso",
			vida = 50,
			velocidad = 11,
			dano = 10,
			cadencia = 1.2,
			escala = 1,
			desdeEtapa = 1,
			peso = 10,
		},
		Corredor = {
			nombre = "Corredor",
			vida = 34,
			velocidad = 17,
			dano = 6,
			cadencia = 0.9,
			escala = 0.85,
			desdeEtapa = 2,
			peso = 5,
		},
		Gigante = {
			nombre = "Gigante de Bruma",
			vida = 210,
			velocidad = 8,
			dano = 22,
			cadencia = 1.8,
			escala = 1.7,
			desdeEtapa = 3,
			peso = 2,
		},
		Rey = {
			nombre = "El Rey de la Niebla",
			vida = 1500,
			velocidad = 12,
			dano = 32,
			cadencia = 1.5,
			escala = 2.6,
			jefe = true,
		},
	},
}

Config.PASOS = {
	TRONCO_VIDA = 12,
	PUENTE = { Cuerda = 3, Lena = 8 },
}
Config.FARO = {
	ACEITE = 3,
	LENA = 10,
}

Config.RECETAS = {
	{
		id = "Hacha",
		nombre = "Hacha de Piedra",
		icono = "🪓",
		descripcion = "Tala árboles rápido y corta troncos gruesos. Pega más fuerte que el palo.",
		coste = { Lena = 3, Piedra = 3, Fibra = 2 },
		unica = "TieneHacha",
	},
	{
		id = "Botiquin",
		nombre = "Vendaje de Hierbas",
		icono = "🩹",
		descripcion = "Cura toda tu vida al instante.",
		coste = { Fibra = 3, Comida = 1 },
	},
	{
		id = "Cuerda",
		nombre = "Cuerda",
		icono = "🪢",
		descripcion = "Fibra trenzada. Sirve para reparar cosas (como un puente...).",
		coste = { Fibra = 3 },
		requiereEtapa = 2,
		pista = "Llega al Río",
	},
	{
		id = "Lanza",
		nombre = "Lanza",
		icono = "🔱",
		descripcion = "Mucho daño y mucho alcance. Mantén a los Brumosos lejos.",
		coste = { Lena = 4, Piedra = 5, Fibra = 3 },
		unica = "TieneLanza",
		requiereEtapa = 2,
		pista = "Llega al Río",
	},
	{
		id = "Antorcha",
		nombre = "Antorcha",
		icono = "🔥",
		descripcion = "Da luz, frena a los Brumosos cercanos y quema lo que teje la bruma.",
		coste = { Lena = 2, Fibra = 2 },
		unica = "TieneAntorcha",
		requiereEtapa = 3,
		pista = "Llega al Bosque Negro",
	},
	{
		id = "Abrigo",
		nombre = "Abrigo de Viaje",
		icono = "🧥",
		descripcion = "Pierdes calor mucho más despacio en la nieve.",
		coste = { Fibra = 6, Lena = 2 },
		unica = "TieneAbrigo",
		requiereEtapa = 4,
		pista = "Llega al Paso Nevado",
	},
	{
		id = "Fuego2",
		nombre = "Círculo de Piedras",
		icono = "🔥",
		descripcion = "Fuego nivel 2: más combustible y una luz más grande en todos los campamentos.",
		coste = { Piedra = 8, Lena = 4 },
		requiereNoches = 1,
		requiereNivel = 1,
		pista = "Sobrevive a la primera noche",
	},
	{
		id = "Fuego3",
		nombre = "Hoguera Grande",
		icono = "🔥",
		descripcion = "Fuego nivel 3: la luz más grande de todas.",
		coste = { Piedra = 14, Lena = 8, Fibra = 4 },
		requiereEtapa = 3,
		requiereNivel = 2,
		pista = "Llega al Bosque Negro y mejora antes al nivel 2",
	},
}

Config.RECURSOS_MOCHILA = { "Lena", "Piedra", "Fibra", "Comida", "Cuerda" }
Config.NOMBRES_RECURSOS = {
	Lena = "Leña",
	Piedra = "Piedra",
	Fibra = "Fibra",
	Comida = "Comida",
	Cuerda = "Cuerda",
}
Config.ICONOS_RECURSOS = {
	Lena = "🪵",
	Piedra = "🪨",
	Fibra = "🌿",
	Comida = "🍎",
	Cuerda = "🪢",
}

function Config.recetaDesbloqueada(receta, estado: Instance)
	if receta.requiere and estado:GetAttribute(receta.requiere) ~= true then
		return false, receta.pista
	end
	if receta.requiereEtapa and (estado:GetAttribute("Etapa") or 1) < receta.requiereEtapa then
		return false, receta.pista
	end
	if receta.requiereNoches and (estado:GetAttribute("NochesSobrevividas") or 0) < receta.requiereNoches then
		return false, receta.pista
	end
	if receta.requiereNivel then
		local nivel = estado:GetAttribute("NivelFuego") or 1
		if nivel > receta.requiereNivel then
			return false, "Ya está mejorado"
		elseif nivel < receta.requiereNivel then
			return false, receta.pista
		end
	end
	return true, nil
end

Config.NOMBRE_DATASTORE = "RumboAlFaro_v1"

return Config
