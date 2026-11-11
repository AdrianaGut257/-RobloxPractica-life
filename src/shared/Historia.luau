local Historia = {}

Historia.TITULO = "Rumbo al Faro"

Historia.INTRO = "La carretera desapareció dentro de la niebla. Esquivaste una figura gris y la furgoneta "
	.. "acabó contra un abedul. Lía está bien. Tú también, más o menos.\n\n"
	.. "Mamá os dijo que, pasara lo que pasara, fuerais al faro de la abuela Rosa."

Historia.FINAL = "El sol sale sobre el mar y la Bruma se deshace como el azúcar en el agua. "
	.. "Lía se ha quedado dormida apoyada en tu hombro.\n\n"
	.. "Entonces lo oyes: la sirena de un barco. Abajo, en la cala, entra un pesquero viejo "
	.. "con un nombre pintado en la proa: «Rosa». En la cubierta, dos figuras agitan los brazos.\n\n"
	.. "Lía se despierta de golpe. «¡¡MAMÁ!! ¡¡PAPÁ!!»\n\nEl viaje ha terminado."

Historia.PAGINAS = {
	[1] = {
		titulo = "La nota de mamá",
		autor = "Caída junto a la puerta de la furgoneta",
		texto = "Cariño:\n\n"
			.. "Si lees esto es que no he podido volver a tiempo. La Bruma ha llegado a Valdeniebla "
			.. "y tengo que ayudar a sacar a la gente del hospital.\n\n"
			.. "Coge a Lía y id al faro de la abuela Rosa, en Punta Clara. La carretera estará cortada: "
			.. "seguid el viejo sendero del bosque, siempre hacia el norte. La abuela lo recorrió de niña.\n\n"
			.. "Encended fuego cada noche. La Bruma no soporta la luz.\n\n"
			.. "Papá vendrá por mar en cuanto pueda. Cuida de tu hermana. Os quiero muchísimo.\n\nMamá",
	},
	[2] = {
		titulo = "Cuaderno de Rosa · 1962",
		autor = "Clavada en un abedul del primer campamento",
		texto = "Primer día en el bosque. Tomás tiene ocho años y no deja de preguntar por mamá.\n\n"
			.. "Cuando se fue el sol, las sombras salieron de entre los abedules. Grises, sin cara, "
			.. "como hechas de niebla. Encendimos fuego y se quedaron quietas en el borde de la luz, mirándonos.\n\n"
			.. "No se acercan al fuego. Hay que tenerlo vivo toda la noche: ramas secas, troncos, lo que sea.\n\n"
			.. "(Debajo, con otra letra mucho más reciente:)\n"
			.. "Si sois mis nietos y estáis leyendo esto: lo estáis haciendo muy bien. — La abuela",
	},
	[3] = {
		titulo = "Nota de la abuela",
		autor = "En una lata de galletas, junto al tronco caído",
		texto = "Para mis nietos, por si algún día la Bruma vuelve:\n\n"
			.. "Una tormenta tiró este pino enorme sobre el sendero hace años y nadie lo ha quitado. "
			.. "Con un palo no podréis.\n\n"
			.. "Atad una piedra afilada a un mango de madera con fibra de los helechos: un hacha de piedra, "
			.. "como la que hizo Tomás. Tres de leña, tres piedras y dos de fibra, en la mesa del campamento.\n\n"
			.. "Y no os olvidéis de comer. Las moras de este bosque son las más dulces del mundo.",
	},
	[4] = {
		titulo = "Cuaderno de Rosa · 1962",
		autor = "Bajo una piedra, a orillas del Remanso",
		texto = "Tercer día. Llegamos al río y Tomás se rió por primera vez desde que salimos de casa: "
			.. "intentó pescar una trucha con las manos y se cayó al agua.\n\n"
			.. "Al final la pescamos con un palo y un hilo. La asamos en el fuego. "
			.. "Nunca nada me había sabido tan bien.\n\n"
			.. "Por la noche me preguntó si las sombras eran personas. Le dije que no. No sé si le mentí.",
	},
	[5] = {
		titulo = "Nota de la abuela",
		autor = "Atada al poste del puente colgante",
		texto = "El puente colgante se rompe cada pocos inviernos. En 1962 también estaba roto: "
			.. "Tomás y yo pasamos toda una tarde trenzando cuerda con fibra.\n\n"
			.. "Hacen falta tres cuerdas buenas y ocho tablas (leña). Si os caéis al río, la corriente "
			.. "os devolverá a la orilla, pero el agua está helada. Mejor no.\n\n"
			.. "Al otro lado empieza el Bosque Negro. Allí la Bruma no se va nunca del todo, "
			.. "ni siquiera de día. No os separéis.",
	},
	[6] = {
		titulo = "Aviso del guardabosques",
		autor = "Pegado en la puerta de la caravana",
		texto = "SERVICIO FORESTAL — AVISO\n\n"
			.. "Paso Nevado CERRADO por nieve hasta nueva orden. La llave de la barrera está "
			.. "en lo alto de la torre de vigilancia.\n\n"
			.. "En el armario de esta caravana hay abrigos para excursionistas. Cogedlos si vais hacia el norte: "
			.. "allí arriba uno se congela en un par de minutos.\n\n"
			.. "Cueva del Bosque Negro: cuidado con las telarañas grises de la entrada. NO las toquéis con las manos.\n\n"
			.. "— Anselmo, guarda forestal",
	},
	[7] = {
		titulo = "Cuaderno de Rosa · 1962",
		autor = "Entre las raíces, cerca de la cueva",
		texto = "La boca de la cueva estaba tapada por una telaraña enorme, gris, que se movía sola "
			.. "como si respirara. Tomás la tocó y se le quedó la mano dormida un día entero.\n\n"
			.. "La quemamos con una rama encendida. Ardió como papel de periódico y chilló. Te juro que chilló.\n\n"
			.. "La Bruma teje. La Bruma espera. Pero el fuego siempre gana.",
	},
	[8] = {
		titulo = "Cuaderno de Rosa · 1962",
		autor = "En el refugio de piedra",
		texto = "Nieve. Tomás tiene fiebre y le he dado mi abrigo. Dormimos abrazados junto al fuego del refugio.\n\n"
			.. "Esta noche he pensado en rendirme. Luego Tomás me ha dicho, medio dormido: "
			.. "«Rosa, cuando lleguemos al faro, ¿me dejarás encender la luz?».\n\n"
			.. "Sí, Tomás. Te dejaré.",
	},
	[9] = {
		titulo = "Cuaderno de Rosa · 1962",
		autor = "En lo alto de la torre de vigilancia",
		texto = "Desde lo alto de la torre se ve el mar. Yo nunca lo había visto.\n\n"
			.. "Y allí, en la punta de los acantilados, estaba el faro. Apagado. El viejo Elías, el farero, "
			.. "estaba solo y no le quedaba aceite para la lámpara.\n\n"
			.. "Buscamos bidones por la costa durante todo un día. Cuando por fin se encendió la luz, "
			.. "la Bruma se retiró hacia el mar como un animal asustado.",
	},
	[10] = {
		titulo = "Carta de la abuela Rosa",
		autor = "Sobre la mesa de la casa del faro",
		texto = "Mis niños:\n\n"
			.. "Si estáis leyendo esto, es que la Bruma ha vuelto y yo ya no estoy para encender la luz. "
			.. "No lloréis por eso: he tenido una vida larga y el mar ha sido bueno conmigo.\n\n"
			.. "Ahora os toca a vosotros. Hay aceite por la costa: en la cabaña del pescador, en la barca vieja "
			.. "y en el cobertizo. Subidlo a la lámpara, con leña, y encended el faro.\n\n"
			.. "La luz no solo espanta a la Bruma. También llama a los que se perdieron. "
			.. "Vuestros padres la verán desde donde estén.\n\n"
			.. "¿Sabéis? Tomás nunca llegó a encenderla: se quedó dormido. Encendedla por él.\n\n"
			.. "Os quiere, siempre,\nla abuela Rosa",
	},
}
Historia.TOTAL_PAGINAS = #Historia.PAGINAS

Historia.TESOROS = {
	[1] = {
		nombre = "Pluma de arrendajo",
		icono = "🪶",
		descripcion = "Azul eléctrico, como si la hubieran pintado.",
		lia = "¡Una pluma azul! Me la pongo en el pelo. ¿A que estoy guapa?",
	},
	[2] = {
		nombre = "Piedra con agujero",
		icono = "🪨",
		descripcion = "Dicen que si miras a través de ella ves cosas mágicas.",
		lia = "Si miro por el agujero... ¡te veo con cara de pato! Jajaja.",
	},
	[3] = {
		nombre = "Chapa de refresco",
		icono = "🔘",
		descripcion = "Oxidada. De una marca que ya no existe.",
		lia = "Papá colecciona chapas. Se la voy a guardar.",
	},
	[4] = {
		nombre = "Concha de río",
		icono = "🦪",
		descripcion = "Por dentro brilla como el nácar.",
		lia = "¡Por dentro tiene un arcoíris!",
	},
	[5] = {
		nombre = "Piedra plana",
		icono = "🥏",
		descripcion = "Perfecta para hacerla saltar sobre el agua.",
		lia = "¡Esta es perfecta! Luego me enseñas a hacer que salte, ¿vale?",
	},
	[6] = {
		nombre = "Canica de cristal",
		icono = "🔵",
		descripcion = "Con una espiral verde dentro.",
		lia = "¡Una canica! Dentro tiene un remolino, como el río.",
	},
	[7] = {
		nombre = "Piña perfecta",
		icono = "🌰",
		descripcion = "Ni una sola escama rota.",
		lia = "Es la piña más perfecta del universo. Se llama Pepa.",
	},
	[8] = {
		nombre = "Campanilla vieja",
		icono = "🔔",
		descripcion = "Suena muy flojito, como si tuviera vergüenza.",
		lia = "Si la toco, ¿las sombras se asustan? ...Tilín.",
	},
	[9] = {
		nombre = "Llavero de zorro",
		icono = "🦊",
		descripcion = "Alguien lo perdió hace mucho tiempo.",
		lia = "Un zorrito... Se parece a mi peluche. Lo echo de menos.",
	},
	[10] = {
		nombre = "Guante de lana",
		icono = "🧤",
		descripcion = "Pequeño, rojo, y solo uno.",
		lia = "¡Me queda perfecto! Bueno, ahora tengo una mano calentita.",
	},
	[11] = {
		nombre = "Bola de nieve de cristal",
		icono = "❄️",
		descripcion = "Si la agitas, nieva sobre un faro diminuto.",
		lia = "¡Mira! ¡Tiene un faro dentro! Es una señal, seguro.",
	},
	[12] = {
		nombre = "Brújula vieja",
		icono = "🧭",
		descripcion = "Ya no marca el norte. Marca... otra cosa.",
		lia = "La aguja apunta hacia allí. Hacia el faro. Lo sé.",
	},
	[13] = {
		nombre = "Estrella de mar",
		icono = "⭐",
		descripcion = "Seca y dura, de un naranja precioso.",
		lia = "¡Una estrella de verdad! Se cayó del cielo al mar.",
	},
	[14] = {
		nombre = "Botella con mensaje",
		icono = "🍾",
		descripcion = "El papel de dentro solo dice: «Volveré».",
		lia = "Alguien la tiró al mar para otra persona. Ojalá la haya leído.",
	},
	[15] = {
		nombre = "Caracola",
		icono = "🐚",
		descripcion = "Si te la acercas a la oreja, suena el mar.",
		lia = "Si me la pongo en la oreja se oye el mar. ¡Pero si el mar está ahí al lado! Jeje.",
	},
}
Historia.TOTAL_TESOROS = #Historia.TESOROS

Historia.MIRADORES = {
	[1] = {
		titulo = "La charca de los patos",
		lineas = {
			"Hace un día precioso. Casi parece una broma.",
			"Hace dos días me quejaba de los deberes de mates. Ahora no sé si mamá está bien.",
			"Lía tira hierbas al agua para los patos. Si ella aguanta, yo también.",
		},
		dibujo = "Dos patos en la charca. Uno lleva corona. Debajo, con letra torcida: «El de la corona eres tú».",
	},
	[2] = {
		titulo = "La cascada",
		lineas = {
			"El ruido del agua lo tapa todo. Hasta lo que pienso.",
			"Papá dice que el agua siempre encuentra el camino al mar. Nosotros también lo encontraremos.",
			"Ojalá su barco esté bien.",
		},
		dibujo = "Una cascada enorme y, abajo, un barco pequeñito. Al lado pone «PAPÁ» en mayúsculas.",
	},
	[3] = {
		titulo = "El Árbol Viejo",
		lineas = {
			"Este árbol tiene que tener mil años. Ya ha visto llegar a la Bruma. Y la ha visto irse.",
			"Las luciérnagas no tienen miedo. Ni siquiera aquí.",
			"Lía dice que el árbol le ha guiñado un ojo. No pienso discutírselo.",
		},
		dibujo = "Un árbol gigante con cara sonriente, rodeado de puntitos amarillos.",
	},
	[4] = {
		titulo = "La cumbre",
		lineas = {
			"Desde aquí arriba se ve todo el camino. El río, el Bosque Negro... hasta los abedules.",
			"Hemos andado muchísimo. Lía con sus botas de agua y yo sin saber muy bien lo que hacía.",
			"Ya no queda tanto. Ya casi.",
		},
		dibujo = "Un camino que serpentea entre montañas y, en lo más alto, dos monigotes de la mano.",
	},
	[5] = {
		titulo = "El fin del camino",
		lineas = {
			"El mar. Huele a sal y a algo más que no sé nombrar.",
			"De peque venía aquí cada verano. La abuela me subía al faro y me dejaba tocar la lámpara.",
			"Esta vez la luz la vamos a encender nosotros.",
		},
		dibujo = "El faro con un rayo de luz amarillo enorme. En una ventana, una abuela que saluda.",
	},
}
Historia.TOTAL_MIRADORES = #Historia.MIRADORES

Historia.CHARLAS = {
	[1] = {
		{ quien = "Lia", texto = "¿Crees que mamá ya ha salido del hospital?" },
		{ quien = "Tu", texto = "Seguro que sí. Ella siempre sabe qué hacer." },
		{ quien = "Lia", texto = "Pero tú no siempre sabes qué hacer." },
		{ quien = "Tu", texto = "...Gracias, Lía. Qué amable." },
		{ quien = "Lia", texto = "¡Jo, no lo decía mal! Hoy lo has hecho bien. Has hecho fuego y todo." },
		{ quien = "Tu", texto = "Con tu ayuda. Tú encontraste las mejores ramas." },
		{ quien = "Lia", texto = "Es verdad. Soy buenísima encontrando ramas." },
		{ quien = "Lia", texto = "¿Me cuentas el cuento del faro? El de la abuela." },
		{ quien = "Tu", texto = "Había una vez una niña que cruzó el bosque entero con su hermano pequeño..." },
		{ quien = "Lia", texto = "...y encendieron la luz, y la Bruma se fue al mar. Me lo sé. Pero cuéntamelo igual." },
	},
	[2] = {
		{ quien = "Lia", texto = "Oye... ¿las sombras eran personas antes?" },
		{ quien = "Tu", texto = "No. Son solo niebla. Niebla con muy mal genio." },
		{ quien = "Lia", texto = "Una se parecía al señor Benito, el del quiosco. Llevaba su sombrero." },
		{ quien = "Tu", texto = "El señor Benito estará en el polideportivo con todo el pueblo, quejándose del café." },
		{ quien = "Lia", texto = "...Vale. Me lo creo." },
		{ quien = "Lia", texto = "¿Mañana me enseñas a pescar como el tío Tomás?" },
		{ quien = "Tu", texto = "Mañana te enseño. Pero sin caerte al agua." },
		{ quien = "Lia", texto = "No prometo nada." },
	},
	[3] = {
		{ quien = "Lia", texto = "Aquí no me gusta. Parece que los árboles me miran." },
		{ quien = "Tu", texto = "¿Te sabes el truco de la abuela para no tener miedo?" },
		{ quien = "Lia", texto = "¿Qué truco?" },
		{ quien = "Tu", texto = "Cuentas estrellas. Cuando llegas a cien, el miedo se aburre y se va." },
		{ quien = "Lia", texto = "Pero aquí no se ven las estrellas. Hay mucha niebla." },
		{ quien = "Tu", texto = "Pues cuentas chispas del fuego. Mira: una, dos, tres..." },
		{ quien = "Lia", texto = "...cuatro, cinco, seis... Oye, pues sí que funciona un poco." },
		{ quien = "Lia", texto = "¿Tú también tienes miedo?" },
		{ quien = "Tu", texto = "Un montón. Pero contigo al lado, menos." },
	},
	[4] = {
		{ quien = "Lia", texto = "Tengo los dedos de los pies congelados. Son cubitos." },
		{ quien = "Tu", texto = "Acércalos al fuego. Pero no tanto, que te los asas." },
		{ quien = "Lia", texto = "Toma, ponte este guante. Tú tienes dos manos y yo también, así que es justo." },
		{ quien = "Tu", texto = "Es diminuto, Lía." },
		{ quien = "Lia", texto = "Pues en un dedo. Es por si acaso." },
		{ quien = "Lia", texto = "¿Papá estará pasando frío en el barco?" },
		{ quien = "Tu", texto = "Papá lleva el jersey ese horrible de rombos. No pasa frío ni en el Polo Norte." },
		{ quien = "Lia", texto = "Jajaja. Es feísimo. Lo echo de menos." },
		{ quien = "Tu", texto = "Yo también." },
	},
	[5] = {
		{ quien = "Lia", texto = "Ya hemos llegado. Pero la abuela no está." },
		{ quien = "Tu", texto = "No... La abuela se fue el invierno pasado, ¿te acuerdas? Pero nos dejó el camino preparado." },
		{ quien = "Lia", texto = "Todas las notas eran para nosotros." },
		{ quien = "Tu", texto = "Todas." },
		{ quien = "Lia", texto = "¿Y si papá y mamá no ven la luz?" },
		{ quien = "Tu", texto = "La verán. El faro se ve desde todo el mar. La abuela lo prometió." },
		{ quien = "Lia", texto = "Cuando venga mamá le voy a enseñar todos mis tesoros." },
		{ quien = "Lia", texto = "Y le voy a decir que has cuidado de mí todo el rato." },
		{ quien = "Tu", texto = "Lo hemos hecho juntos, enana." },
	},
}

Historia.LIA = {
	inicio = {
		"¿Estás bien? ¡La furgo se ha roto!",
		"¡Se ha caído la nota de mamá! Está ahí, junto a la puerta.",
	},
	campamento = {
		[1] = "¡Un campamento! ¿Vamos a dormir aquí? ¡Qué guay! Bueno, qué miedo. Bueno, las dos cosas.",
		[2] = "¡Se oye el río! ¿Puedo meter los pies? ¡Porfa!",
		[3] = "Aquí está muy oscuro... ¿Seguro que es por aquí?",
		[4] = "¡NIEVE! ...Vale, sí, hace un frío que pela.",
		[5] = "¡La casa de la abuela! ¡Y el faro! ¡Hemos llegado!",
	},
	camino = {
		[1] = {
			"¿Sabías que los abedules tienen la piel como de papel?",
			"Tengo hambre. No mucha. Un poco. Bastante.",
			"¿Cuánto falta? Ya sé que no lo sabes. Pero ¿cuánto?",
			"Mira, una seta. ¡No la toco! Ya lo sé.",
		},
		[2] = {
			"El agua está fría pero mola.",
			"¿Los peces duermen? ¿Con los ojos abiertos?",
			"Si me caigo al río, ¿me rescatas?",
			"Huele a hierba mojada. Me gusta.",
		},
		[3] = {
			"No me sueltes, ¿vale?",
			"He oído algo... Ah, no, era mi tripa.",
			"Esos árboles parecen gigantes dormidos.",
			"Si cantamos, ¿la niebla se va? La, la, laaa...",
		},
		[4] = {
			"Mis botas hacen crunch, crunch.",
			"¡Mira, echo humo por la boca como un dragón!",
			"Tengo los mocos congelados. Es verdad, mira.",
			"¿Aquí viven osos polares? Espero que no.",
		},
		[5] = {
			"¡Huele a mar! ¡Huele a mar!",
			"¿Crees que papá ya está cerca?",
			"La abuela me enseñaba a buscar cangrejos en las rocas.",
			"Hay gaviotas. Son unas cotillas.",
		},
	},
	hablar = {
		"¿Sabías que soy la mejor buscadora de ramas del mundo?",
		"Cuando lleguemos, ¿haremos chocolate caliente?",
		"Me gusta andar contigo.",
		"¿Tú crees que la abuela nos ve?",
		"¿Qué le dice un árbol a otro? ¡Nos vemos en la raíz! Jajaja.",
		"Cuando sea mayor quiero ser farera. O astronauta. O las dos.",
	},
	noche = {
		"Ya es de noche... Vamos al fuego, porfa.",
		"Me quedo junto al fuego. Tú también, ¿vale?",
		"No te vayas muy lejos...",
	},
	amanecer = {
		"¡Ya es de día! Hemos sobrevivido otra vez.",
		"Buenos días... He soñado con mamá.",
		"¡Sol! Sol, sol, sol.",
	},
	fuegoBajo = {
		"¡El fuego se está apagando! ¡Trae leña!",
		"El fuego se está haciendo pequeñito...",
	},
	fuegoApagado = {
		"¡Se ha apagado! ¡No veo nada!",
		"¡Ayuda! ¡No hay luz!",
	},
	asustada = {
		"Quiero irme a casa...",
		"No quiero andar más. Quiero a mamá.",
		"Tengo mucho miedo... No me muevo de aquí.",
	},
	consolada = {
		"...Vale. Ya estoy mejor. Gracias.",
		"¿Me das la mano? Así sí puedo seguir.",
		"Snif... Vale. Vamos.",
	},
	encontrar = {
		"¡Mira lo que he encontrado!",
		"¡Toma! Lo he encontrado yo solita.",
		"¡Para ti! Bueno, para el viaje.",
	},
	comer = {
		"¡Ñam! Gracias.",
		"Qué rico... aunque echo de menos las croquetas de mamá.",
		"¡Estaba muerta de hambre!",
	},
	lleno = {
		"No tengo hambre ahora. Guárdalo para luego.",
	},
	enemigo = {
		"¡Ahí hay uno! ¡Una sombra!",
		"¡Viene a por nosotros!",
	},
	golpe = {
		"¡Aaah! ¡Me ha tocado! ¡Está helado!",
		"¡Ayuda!",
	},
	frio = {
		"Tengo muchísimo frío...",
		"Necesito acercarme al fuego...",
	},
	perdida = {
		"¡Esperadme! ¡No me dejéis atrás!",
	},
	paso = {
		[1] = "¡Toma ya! ¡Has partido el tronco!",
		[2] = "¡El puente ya está! ...¿Seguro que aguanta? Ve tú primero.",
		[3] = "¡Ha chillado! ¡La telaraña ha chillado! Qué asco.",
		[4] = "¡La barrera está abierta! ¡Al fondo se ve el mar!",
	},
	faro = "¡Está encendido! ¡Papá, mamá, estamos aquí!",
	final = "¡¡MAMÁ!! ¡¡PAPÁ!!",
}

return Historia
