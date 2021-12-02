import wollok.game.*
//import nivel.*
import tablero.*
import nivelPrueba.*
import horario.*
import escenarioDerrota.*

class Visual { // comportamiento necesario para polimorfismo de todos los visuales

	method comportamientoNoche(horario) {
	}

	method comportamientoDia(horario) {
	}

	method esAtravesable() = true // default

	method cobrarVida() {
	}

}

class VisualUI inherits Visual { // blueprint de visuales sin logica particular.  No me gusto utilizar solo clase visual para visuales con logica propia y visuales como carteles.

	var property image = null
	var property position = null

	method esInteractuado(p) {
	// no hace nada
	}

// method tieneComportamiento() = false
// No tiene sentido esta clase sin comportamiento ni atributos. 
// Podrian agregarle position e image. Incluso el esAtravesable() 
}

const flechas = new VisualUI(image = "j1Guia.png", position = game.origin())

const guiaJugadorDos = new VisualUI(image = "j2.png", position = game.at(7, 0))

object mapa {

	method crearParedesInvisibles() {
		// game.addVisualIn(new TileInvisible(),game.at(6,4)) //Mejor que el visual tenga la posicion y usar addVisual
		// game.addVisualIn(new TileInvisible(),game.at(8,4))
		game.addVisual(new VisualUI(image = "tileInvisible.png", position = game.at(6, 4))) // Mejor que el visual tenga la posicion y usar addVisual
		game.addVisual(new VisualUI(image = "tileInvisible.png", position = game.at(8, 4))) // Mejor que el visual tenga la posicion y usar addVisual
	}

}

// Idem, no tienen comportamiento diferente, solo un valor diferente para un atributo
class ParteCasa inherits Visual {

	var property position
//	var property esAtravesable = true
	var property casa

	method esInteractuado(sujetoParticipe) { //
		casa.esInteractuado(sujetoParticipe) // que parteCasa no hable por casa
	}

	method image() {
		return "tileInvisible.png"
	}

}

class Casa inherits Visual {

	// var property esAtravesable = true
	var property salud
	var property estaRota
	var property lista = []
	var property nombre = "casa"
	var property tieneComportamiento = false

	method repararCasa(sujetoParticipe) { // que la casa hable por si misma
		game.sound("repararCasa3.mp3").play()
		const maderaRecibida = sujetoParticipe.madera()
		self.salud(self.salud() + maderaRecibida)
		game.say(self, "salud de casa + " + maderaRecibida)
		sujetoParticipe.madera(0)
	}

	method darMensaje() = "si la casa cae pierdes el juego"

	method position() = game.at(3, 4)

	method image() = "casa.png"

	method esInteractuado(sujetoParticipe) { // rever
		if (sujetoParticipe.madera() > 0) {
			self.repararCasa(sujetoParticipe)
		}
	}

	method estaRota() = salud < 0

	method celdasOcupadas() {
		// return [self.arriba(),self.derecha(),
		// self.derecha().arriba()]
		return [ self.position(), self.position().up(1), self.position().right(1), self.position().up(1).right(1) ]
	}

	method dibujar() {
		game.addVisual(self)
		game.showAttributes(self)
		game.addVisual(new ParteCasa(position = self.position().right(1), casa = self))
		game.addVisual(new ParteCasa(position = self.position().up(1), casa = self))
		game.addVisual(new ParteCasa(position = self.position().up(1).right(1), casa = self))
	}

	method recibeDanio(danio) { // logica repetida, probar clase
		salud = salud - danio
			// new Sonido().roturaCasa().play()
		const casaGolpeada = game.sound("roturaCasa.mp3")
		casaGolpeada.play()
		game.say(self, "ouch, me queda " + salud + " vida")
		if (salud < 0) {
			escenarioDerrota.inicio("la casa ha sido destruida")
		}
	}

}

class Zombie inherits Visual {

	var property position = game.at(20, 20) // game.at(1, 2.randomUpTo(9))
	// var property vida = 50
	var danio = 5
	var property nombre = "zombie"
	var property paso = true
	var property tieneComportamiento = true
	var property heroe
	var property hogar
	var property horarioZombie = null
	var vida = 50
	var property direccion = null

	method darMensaje() = "no dejes que los zombies se acerquen a la casa"

	method vida() = vida

	method vida(nro) {
		vida = nro
	}

	method image() = "zombie3.png"

	method recibeDanio() {
		self.vida(self.vida() - heroe.danio())
		if (self.vida() <= 0) {
			estadisticasZombie.incrementarContador()
			const agonia = game.sound("tomasAgonia.mp3")
			agonia.play()
			self.moverFueraDelMapa()
			self.traerAlMapa() // traer al mapa no tiene en cuenta el horario. necesitaria que chequee de alguna manera si es de dia o no 
		} else {
			self.huye()
		}
	}

	override method comportamientoDia(horario) { // de dia se va del mapa
		game.schedule(1000.randomUpTo(2000), { self.moverFueraDelMapa()})
	}

	override method comportamientoNoche(horario) { // spawn progresivo
		game.schedule(500.randomUpTo(6000), { self.traerAlMapa()})
	}

	method moverFueraDelMapa() { // se mueve fuera del mapa para no instanciar nuevos zombies. justificar
		self.removerEventos()
		vida = 50
		self.position(game.at(anchoVentanas + 5, altoVentanas + 5)) // espera que se termina el ultimo tick por las dudas.
	}

	method traerAlMapa() { // necesito un objeto casa que sea golpeable
		game.schedule(4000.randomUpTo(6000), {=>
				// si es de dia, no haga nada
			if (not reloj.esDeDia()) {
				self.position(tablero.celdasVaciasBordes().anyOne())
				self.comenzarMovimiento(hogar)
					// establee su direccion una sola vez para no preguntar en cada paso, mas perf
				self.direccion(tablero.parteCasaMasCercana(self.position()))
			}
		})
	}

	method tieneComportamiento() = true

	method removerEventos() {
		try {
			game.removeTickEvent("zombie se mueve")
		} catch e : Exception { // evento puede no existir si ocurre que el zombie no vuelve al mapa por ser justo de dia
		//
		}
	}

	// //
	method huye() { // spacio que hay disponible alrededor 
		return self.position(tablero.espacioLibreAlrededor(self).anyOne())
	}

	method hacerMasFuerte() {
		vida = 100
		danio = danio + 10
	}

	// var nombre
	method esInteractuado(sujetoParticipe) {
		game.say(self, "ouch")
		sujetoParticipe.accionar()
		self.recibeDanio()
	}

	method puedeMoverseA(nuevaPos) { // zombie huye solo a tiles vacios
		return ( not tablero.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).isEmpty()) // get objectsIn devuelve lista. 
		//
	}

	method nuevaPos(pos) {
		position = pos
	}

	method estaFueraDelMapa() {
		return self.position().equals(game.at(anchoVentanas + 5, altoVentanas + 5))
	}

	method darUnPaso() {
		// if (not self.estaFueraDelMapa()) { // con remove tick event, parece que lo remueve pero se dispara una ultima vez.
		self.position(tablero.posicionMasCercanaACasa(self))
	// }
	}

	method comenzarMovimiento(casa) {
		game.onTick(4000, "zombie se mueve", { => try {
			if (self.estaAlBordeDeLaCasa()) { // si la casa esta a su alcance ataca
				const golpe = game.sound("golpeMadera.mp3")
				golpe.play()
				casa.recibeDanio(danio)
			} else { // si no, se mueve
				self.darUnPaso()
			}
		} catch e : wollok.lang.ElementNotFoundException {
			game.say(self, "no tengo donde ir")
		// e.printStackTrace()
		}
		})
	}

	method estaAlBordeDeLaCasa() {
		return tablero.posicionesProximas(self).any{ c => hogar.celdasOcupadas().contains(c) }
	}

}

class Arbol inherits Visual {

	var property position = tablero.posRandom()
	var property calorias = 0
	var property estaEnPie = true
	var property madera = 40
	var property nombre = "arbol"
	var property tieneComportamiento = true

	method darMensaje() = "la madera pueda utilizarse para reparar  la casa"

	method image() = if (not self.estaEnPie()) "tronco.png" else "arbol801.png"

	method esInteractuado(sujetoParticipe) {
		if (self.estaEnPie()) {
			self.estaEnPie(false)
			sujetoParticipe.cansar(10) // reever
			sujetoParticipe.madera(sujetoParticipe.madera() + self.madera())
			sujetoParticipe.accionar()
			game.say(sujetoParticipe, "madera  + " + self.madera())
			self.madera(0)
			game.schedule(9200, { self.reinicio()})
		}
	}

	method reinicio() {
		self.madera(40)
		self.estaEnPie(true)
	}

}

object visualYAtributos {

	method addVisual(sujeto) {
		game.addVisual(sujeto)
		game.showAttributes(sujeto)
	}

}

class BayaAuto inherits BayaMediana { // baya que se regenera en la misma pos cada cierto tiempo y en la misma ubicacion, da vida y ademas aumenta el daño

	var property posicionOriginal = null

	override method moverFueraDelMapa() { // antes de sacar del mapa guarda pos original para volver a esta
		self.posicionOriginal(self.position())
		self.position(game.at(25, 25))
	}

	override method traerAlMapaTemporizado() {
		const tiempo = 6000.randomUpTo(10000)
		game.schedule(tiempo, { => self.position(self.posicionOriginal())})
	}

	override method image() = "bayaBonus.png"

	override method esInteractuado(sujetoParticipe) {
		sujetoParticipe.danioBase(sujetoParticipe.danioBase() + 10)
		sujetoParticipe.accionar()
		game.say(sujetoParticipe, "danio: " + sujetoParticipe.danio())
		self.moverFueraDelMapa()
		self.traerAlMapaTemporizado()
	}

}

class BayaMediana inherits Visual {

	var property calorias = 100
	var property position = tablero.posRandom()
	var property nombre = "BayaMediana"
	var property tieneComportamiento = true

	method image() = "BayaMediana.png"

	method darMensaje() = "Bayas aparecen cada cierto tiempo"

	method esInteractuado(sujetoParticipe) { // Baya vuelven a aparecer cada cierto tiempo
	// sujetoParticipe.sumarEnergia(calorias,self)
		sujetoParticipe.sumarEnergia(calorias)
		sujetoParticipe.accionar()
		game.say(sujetoParticipe, "energia: " + sujetoParticipe.energia())
		self.moverFueraDelMapa()
		self.traerAlMapaTemporizado()
	}

	method moverFueraDelMapa() {
		self.position(game.at(25, 25))
	}

	method traerAlMapaTemporizado() {
		const tiempo = 4000.randomUpTo(8000)
		game.schedule(tiempo, { => self.position(tablero.posRandom())})
	}

	override method cobrarVida() {
		calorias = 100 // * multiplicador.numero()
	}

}

class PartePiedra inherits Visual { // tiles invisibles que ocupan el espacio del game.say, para que no sea spawneado por un arbol.

	var property position

	// var property casa 
	method esInteractuado(sujetoParticipe) { //
	// no hace nada
	}

	method image() {
		return "tileInvisible.png"
	}

}

class Roca inherits Visual {

	var property position = game.at(2, 8)
	var property c = 0
	var property diccio = new Dictionary() // const y objeto mismo nombre rompen todo
	var property tieneComportamiento = false
	var listaProhibida = []

	override method esAtravesable() = false

	method construirRoca() {
		const position1 = self.position().up(1).right(1) // uno arriba y a la derecha
		const position2 = self.position().right(1)
		const position3 = self.position().up(1)
		const position4 = self.position().right(2)
		const position5 = self.position().right(3)
		game.addVisual(new PartePiedra(position = position1))
		game.addVisual(new PartePiedra(position = position2))
		game.addVisual(new PartePiedra(position = position3))
		game.addVisual(new PartePiedra(position = position4))
		game.addVisual(new PartePiedra(position = position5))
	}

	method image() = "piedra80.png"

	method mensajeDeDespedida() { // expandir con razon de derrota
		return "te has quedado sin energia presiona una tecla para volver a comenzar"
	}

	method guardarMensaje(m) {
		listaProhibida.add(m)
	}

	method darConsejo(sobreQuien) { // no se repitan los mensajes, 
		var mensaje = sobreQuien.darMensaje()
		if (not listaProhibida.contains(mensaje)) {
			self.guardarMensaje(mensaje)
			game.schedule(10000, game.say(self, mensaje))
		}
	}

	override method cobrarVida() {
		// self.llenarDiccio()
		game.say(self, "preciona C para interactuar con objetos")
	}

}

class PersonajePrincipal inherits Visual { // Tal vez se pueda pensar en una subclase comun a algunos Visuales

	var property energia = 500
	var property position = game.at(1, 3)
	var property madera = 0
	var property contadorEscondidoDePasos = 0
	// var property danio = 45
	var property nombre = "personajePrincipal"
	var property estaEnPie = false
	var property tieneComportamiento = false
	var property rocaConsejera = null
	var property image = "shovelMain.png"
	var property estaAnimando = false
	// var property image = "shovelMain.png"
	var property accion1 = "accion1.png" // se utiliza redefinicion para nuevos personajes
	var property accion2 = "accion2.png"
	var property imagenPrincipal = "shovelMain.png"
	var property imagenPasoDado = "shovelMain2.png"
	var property danioBase = 45

	method darMensaje() = "pierdes el juego al quedarte sin energia"

	method danio() {
		return self.danioBase() * multiplicador.numero()
	}

	method interactuarPosicion() {
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			itemFound.esInteractuado(self)
			self.cansar(10)
			rocaConsejera.darConsejo(itemFound)
		// game.say(self,"interactuo con " + itemFound.toString()) // testing
		} catch e : wollok.lang.Exception { // Illegal operation 'uniqueElement' on collection with 2 elements
		// e.printStackTrace()  tests
			var lista = game.getObjectsIn(position)
			lista.forEach{ v => v.esInteractuado(self)}
		}
	}

	method moverPala() {
		estaAnimando = true
		image = accion1
		game.schedule(100, {=> image = accion2})
		game.schedule(200, {=>
			self.image(imagenPrincipal)
			estaAnimando = false
		})
	}

	override method cobrarVida() {
		madera = 0
		energia = 500
		position = game.at(1, 3)
	}

	// //
	method puedeMoverse(pos) { // si hay una animacion (para no cortarla con la animacion de movimiento) o si hay algo en esa direccion que no es atravesable
		return ( (self.puedeMoverseA(pos)) and (not self.estaAnimando()))
	}

	method moverse(nuevaPos) { // rever
		if (self.puedeMoverse(nuevaPos)) {
			self.position(nuevaPos)
			self.efectoDeCaminar() // setter energia e imagen, delego cambio a posicionNueva a game.addVisualCharacter por rendimiento	
			self.hacerPasos() // cambio de visual
		}
	}

	method hacerPasos() {
		if (image == imagenPrincipal) {
			image = imagenPasoDado
		} else {
			image = imagenPrincipal
		}
	}

	method accionar() {
		// game.say(self, "energia : " + self.energia())
		self.moverPala()
	}

	method esInteractuado(personaje) {
	// no hace nada
	}

	// method sumarEnergia(nro,baya) {
	method sumarEnergia(nro) {
		energia = energia + nro
	// game.say(self, "ñam   Energia : " + self.energia() + " (" + baya.calorias() + ") ")
	}

	method estaCansado() {
		return (energia < 0)
	}

	/*  
	 * method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
	 * 	return ( not tablero.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() }) // get objectsIn devuelve lista. 
	 } */
	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() } && not tablero.fueraDelLimite(nuevaPos) // get objectsIn devuelve lista. 
	}

	method cansar(nro) {
		energia = energia - (nro / multiplicador.numero())
	}

	method alarmaDeEnergia() {
		if (self.estaCansado()) {
			escenarioDerrota.inicio("te has quedado sin energia")
		}
	}

	method advertenciaEnergia() {
		if (self.energia() < 80) {
			game.say(self, "me estoy quedando sin energia")
			
		}
	}

	method efectoDeCaminar() {
		self.aumentarContadorPasos()
		self.cansar(4)
		self.advertenciaEnergia()
		self.alarmaDeEnergia()
		estaEnPie = not estaEnPie
		self.ruido().play()
	}

	method aumentarContadorPasos() {
		contadorEscondidoDePasos = contadorEscondidoDePasos + 1
	}

	method ruido() = if (contadorEscondidoDePasos % 2 == 0) game.sound("caminata1.mp3") else game.sound("caminata2.mp3")

}

class Nube inherits Visual {

	var property position = game.at(1, 9)
	var property estadoNormal = true
	var property cDias = 0 // medida de tiempo, cuando la nube vuelve pasa de dia a noche
	var property tieneComportamiento = true
	var property loc = null

	method esInteractuado(sujeto) {
		game.say(self, "bayas son parte de una dieta saludable") // o cambiar el clima, se ponga a llover
	}

	method image() {
		if (estadoNormal) return "nube80.png"
		return "nube5.png"
	}

	method moverDerecha() {
		if ((self.position().x() > game.width()) && (self.position().y() < game.height())) { // si la siguiente celda en x no es 0
			self.position(game.at(2, 9)) // mueve al inicio 
		} else self.position((self.position().right(1)))
		self.position(self.position().down(1))
		if (self.hayUnaBaya()) {
			self.comerBaya()
			estadisticasBayas.incrementarContador()
		}
	}

	method comerBaya() {
		game.say(self, "ñam")
		loc.moverFueraDelMapa()
		loc.traerAlMapaTemporizado()
	}

	method hayUnaBaya() {
		try {
			loc = game.uniqueCollider(self)
			return listaBaya.lista().contains(loc)
		} catch e : Exception {
			return false
		}
	/*
	 * 		 if (game.colliders(self).isEmpty()){
	 * 		 	return false
	 * 		 }else{
	 * 		 	return listaBaya.lista().contains(game.colliders(self))
	 * 		 }
	 * 
	 */
	}

	override method cobrarVida() {
		game.onTick(800, "nubesSeMueven", {=> self.moverDerecha()})
	}

	override method comportamientoNoche(horario) {
		game.schedule(horario.tiempoDelDia() - 8000, { => game.say(self, "dentro de poco sera de dia")})
	}

	override method comportamientoDia(horario) {
		game.schedule(horario.tiempoDelDia() - 8000, { => game.say(self, "dentro de poco sera de noche")})
	}

}

