import wollok.game.*
import nivel.*

object casa {

	var property esAtravesable = true
	var property position = game.at(3, 4) // tiene varios position
	var property salud = 40

	method image() = "casa.png"

	method esInteractuado(sujetoParticipe) {
		salud = salud + (sujetoParticipe.madera() * 2)
		game.say(self, "salud de casa + " + sujetoParticipe.madera())
		sujetoParticipe.madera(0)
	}

	method estaRota() {
		return (salud < 0 )
	}

}

object palmera {

	var property position = game.center()
	var property esAtravesable = true
	var property calorias = 0
	var estaEnPie = true
	var property madera = 40

	method image() {
		if (not estaEnPie) {
			return "tronco.png"
		}
		return "arbol801.png"
	}

	method esInteractuado(sujetoParticipe) {
		if (estaEnPie) {
			estaEnPie = false
			sujetoParticipe.cansar(10) // reever
			sujetoParticipe.madera(15)
			game.say(sujetoParticipe, "madera  + " + madera)
			roca.darConsejo(self)
			madera = 0
		}
	}

	method reiniciarEstado() {
		estaEnPie = true
	}

}

object bayasMedianas {

	var property esAtravesable = true
	var property calorias = 10
	var property position = game.at(1, 3)

	method image() = "bayasMedianas.png"

	method esInteractuado(sujetoParticipe) {
		sujetoParticipe.sumarEnergia(calorias)
		game.say(sujetoParticipe, "ñam")
		game.removeVisual(self)
		roca.darConsejo(self)
	}

}

object roca {

	var property position = game.at(2, 8)
	var property esAtravesable = false
	var property c = 0

	method image() = "piedra80.png"

	method mensajeDeBienvenida() {
		return "preciona C para interactuar con objetos"
	}

	method mensajeDeDespedida() { // expandir con razon de derrota
		return "te has quedado sin energia presiona una tecla para volver a comenzar"
	}

	method darConsejo(sobreQuien) { // consejo se elegi arb 
		try {
			game.say(self, diccioDeBuenosConsejos.diccio().get(sobreQuien))
		} catch e : ElementNotFoundException {
			game.say(self, "consejo")
		}
	}

}

object diccioDeBuenosConsejos {

	var property diccio = new Dictionary()
	// const presentacion = diccio.put(presentacion,"interactua con sujetos presionando la c")
	const madera = diccio.put(palmera, "la madera pueda utilizarse para reparar  la casa")
	const girasoles = diccio.put(girasolesSentientes, "pierdes el juego si te quedas sin energia")

}

// para que las paredes de la casa no puedan ser atravesadas y solo pueda entrarse por la puerta
// un mejor enfoque seria dividir la imagen en 4 de la casa, y tener un objeto padre que
// conoce la salud de la casa, y pasarle a los  hijos que se encargen del metodo imagen c/u
object techoCasa {

	var property position = casa.position().up(1)
	var property esAtravesable = false

	method image() {
		return "tileInvisible.png"
	}

}

object chimeneaCasa {

	var property position = casa.position().right(1)
	var property esAtravesable = false

	method image() {
		return "tileInvisible.png"
	}

}

object jardinCasa {

	var property position = casa.position().right(1).up(1)
	var property esAtravesable = false

	method image() {
		return "tileInvisible.png"
	}

}

////
object girasolesSentientes {

	var property energia = 666
	var property position = game.at(1, 3)
	var property madera = 0
	var property contadorEscondidoDePasos = 0

	method image() = "girasoles.png"

	method interactuarPosicion() {
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			itemFound.esInteractuado(self)
		// game.say(self,"interactuo con " + itemFound.toString()) // testing
		} catch e : wollok.lang.Exception {
			game.say(self, "no hay nada aqui para interactuar")
		}
	}

	method cansar(nro) {
		energia = energia - nro
		self.alarmaDeEnergia()
	}

	method sumarEnergia(nro) {
		energia = energia + nro
	}

	method cansado() {
		return (energia <= 0)
	}

	method fueraDelLimite(nuevaPos) {
		const x = nuevaPos.x()
		const y = nuevaPos.y()
		return (x >= game.width() or x <= -1) or ( y >= game.height() or y <= -1)
	}

	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return ( not self.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() }) // get objectsIn devuelve lista. 
	}

	// si no hay objeto es atravezable para el.
	// pregunto si es una locacion que  
	// game.colliders(self).all{sujeto => sujeto.esAtravesable()}
	method irA(nuevaPos) { // toma objeto pos
	// cada paso chequeo si no hay energia o casa esta rota
		if (self.puedeMoverseA(nuevaPos)) { // solo si casillero siguiente es objeto atravesable
			self.cansar(5)
			position = nuevaPos // asigna nueva posicion
			contadorEscondidoDePasos = contadorEscondidoDePasos + 1
		}
		derrota.hayDerrota(self) // si queda con e nergia negativa o su casa esta rota luego de
		// finalizar el paso pierde
	}

	method alarmaDeEnergia() {
		if (energia < 15) {
			game.say(self, "me estoy quedando sin energia")
			roca.darConsejo(self)
		}
	}

	method interactuar(sujetoComestible) { // chequear como desaparece
		sujetoComestible.esInteractuado()
	}

}

object derrota {

	method hayDerrota(sujeto) {
		if (sujeto.cansado() or casa.estaRota()) {
			nivel.escenarioDerrota() // cambia escena
		}
	}

}

object nube {

	var property position = game.at(1, 9)
	var property estadoNormal = true
	var property esAtravesable = true

	// var property contadorDeOdio
	method esInteractuado(sujeto) {
		game.say(self, "una pista o consejo") // o cambiar el clima, se ponga a llover
	}

	/*  
	 * method enojarse(sujeto){
	 * 	game.schedule(5000,estadoNormal = false)//estado cambiado x tiempo
	 * 	game.removeTickEvent("nubesSeMueven")
	 * 	self.position(casa.position()) // venganza
	 * }
	 */
	method image() {
		if (estadoNormal) return "nube80.png"
		return "nube5.png"
	}

	method moverDerecha() {
		if ((self.position().x() > game.width()) && (self.position().y() < game.height())) { // si la siguiente celda en x no es 0
			self.position(game.at(1, 9)) // mueve al inicio y suma 1 dia
			dia.pasarUnDia()
		} else self.position((self.position().right(1)))
		self.position(self.position().down(1))
	}

}

object dia {

	var property dia = 0

	method pasarUnDia() {
		dia = dia + 1 // si pasan 5 dias aparecen plantas, igual mobs. timer
	}

}

