import wollok.game.*
import nivel.*
import tablero.*

class Visual {

	method comportamientoNoche(horario) {
	}

	method comportamientoDia(horario) {
	}

//	method tieneComportamiento() = false
	 
}

class ParteCasa inherits Visual {

	var property position
	var property esAtravesable = true
	var property casa 
	method esInteractuado(sujetoParticipe) { //  
		casa.repararCasa(sujetoParticipe) // que parteCasa no hable por casa
	}

	method image() {
		return "tileInvisible.png"
	}

	method cobrarVida() {
	}
 
}
class Casa inherits Visual{
	
	var property esAtravesable = true
	// var property position = game.at(3, 4) // tiene varios position
	var property salud = 80
	var property estaRota
	var property lista = []
	var property nombre = "casa"
	var property position = game.at(3, 4)
	var property tieneComportamiento = false
	
	method repararCasa(sujetoParticipe){ // que la casa hable por si misma
		self.salud(self.salud() + (sujetoParticipe.madera() * 2))
		game.say(self, "salud de casa + " + sujetoParticipe.madera())
		sujetoParticipe.madera(0)
	}
	
	
	method image() = "casa.png"

	method esInteractuado(sujetoParticipe) { // rever
		if (sujetoParticipe.madera() > 0) {
			self.repararCasa(sujetoParticipe)
		}
	}

	method estaRota() {
		return (salud < 0 )
	}

 

	method celdasOcupadas() {
		// return [self.arriba(),self.derecha(),
		// self.derecha().arriba()]
		return [ self.position(), self.position().up(1), self.position().right(1), self.position().up(1).right(1) ]
	}

	method dibujar() {
		game.addVisual(self)
		game.showAttributes(self)
		game.addVisual(new ParteCasa(position = self.position().right(1), casa  = self))
		game.addVisual(new ParteCasa(position = self.position().up(1), casa  = self))
		game.addVisual(new ParteCasa(position = self.position().up(1).right(1), casa  = self))
	}

	method recibeDanio(danio) { // logica repetida, probar clase
		salud = salud - danio
		game.say(self, "ouch, me queda " + salud + " vida")
		if (salud < 0) {
			nivel.escenarioDerrota("la casa ha sido destruida")
		}
	}

	method cobrarVida() {
	}

}
	
class Sonido { // los sonidos pueden ejecutarse una sola vez, 
//entonces instancio?

	var property agonia = game.sound("tomasAgonia.mp3")
	var property meDueleTodo = game.sound("tomasMeDueleTodo.mp3")
	var property golpeMadera = game.sound("golpeMadera.mp3")

}

object sonido{
	var property agonia = game.sound("tomasAgonia.mp3")
}

class Zombie inherits Visual {

	var property position = game.at(20, 20) // game.at(1, 2.randomUpTo(9))
	var property vida = 50
	var danio = 5
	var property nombre = "zombie"
	var property paso = true
	var property tieneComportamiento = true
	var property heroe
	var property hogar
	
	method image() = "zombie3.png"

	method recibeDanio() {
		vida = vida - heroe.danio()
		if (vida <= 0) {
			new Sonido().agonia().play()
		//	sonido.agonia().play()
				// game.removeVisual(self)
			self.moverFueraDelMapa()
				// utilizar enfoque de fabrica de zombies crea muchas instancias de zombie que parecen relentizar el juego al pasar el tiempo(preguntar)
				// utilizar removeVisual y despues addVisualIn no me permite volver a cambiarle la posicion en game.onTick() (preguntar)
			self.traerAlMapa()
		} else self.huye()
	}

	override method comportamientoDia(horario) {
		game.schedule(1000.randomUpTo(2000), { self.moverFueraDelMapa()})
	}

	override method comportamientoNoche(horario) { // spawn progresivo
		game.schedule(500.randomUpTo(4000), { self.traerAlMapa()})
	}
	
	
	
	 method tieneComportamiento() = true

	method moverFueraDelMapa() { // se mueve fuera del mapa para no instanciar nuevos zombies. justificar
		self.removerEventos()
		vida = 50
		self.position(game.at(nivel.ancho() + 5, nivel.alto() + 5))
	}

	method removerEventos() {
		game.removeTickEvent("zombie se mueve")
	}

	// //
	method huye() { // que espacio hay libre disponible alrededor de el??
		self.position(tablero.espacioLibreAlrededor(self).anyOne())
	}

	method hacerMasFuerte() {
		vida = 100
		danio = danio + 10
	}

	method cobrarVida() {
		self.comenzarMovimiento(hogar)
	}

	// var nombre
	method esInteractuado(sujetoParticipe) {
		game.say(self, "ouch")
		self.recibeDanio()
	}

	method esAtravesable() = true
 

	method puedeMoverseA(nuevaPos) { // zombie huye solo a tiles vacios
		return ( not tablero.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).isEmpty()) // get objectsIn devuelve lista. 
		//
	}

	method traerAlMapa() { // necesito un objeto casa que sea golpeable
		game.schedule(1500, {=> 
			self.position(tablero.celdasVaciasBordes().anyOne())
				self.comenzarMovimiento(hogar)
		})
	
	}

	method comenzarMovimiento(casa) {
		game.onTick(3000.randomUpTo(6000), "zombie se mueve", { => try {
			if (self.estaAlBordeDeLaCasa()) { // si la casa esta a su alcance ataca
				new Sonido().golpeMadera().play()
				casa.recibeDanio(danio)
			} else { // si no, se mueve
				self.position(tablero.posicionMasCercanaACasa(self))
			}
		} catch e : wollok.lang.ElementNotFoundException {
			game.say(self, "no tengo donde ir")
		}
		})
	}

	method estaAlBordeDeLaCasa() {
		return tablero.posicionesProximas(self).any{ c => hogar.celdasOcupadas().contains(c) }
	}

}

class Arbol inherits Visual {

	var property position = tablero.posRandom()
	var property esAtravesable = true
	var property calorias = 0
	var estaEnPie = true
	var property madera = 40
	var property nombre = "arbol"
	var property tieneComportamiento = true

	method image() {
		if (not estaEnPie) {
			return "tronco.png"
		}
		return "arbol801.png"
	}

	method esInteractuado(sujetoParticipe) {
		if (estaEnPie) {
			estaEnPie = false
			if (madera > 0) {
				sujetoParticipe.cansar(10) // reever
				sujetoParticipe.madera(sujetoParticipe.madera() + madera)
				game.say(sujetoParticipe, "madera  + " + madera)
				madera = 0
				game.schedule(9200, { self.reinicio()})
			}
		}
	}
 
	method reinicio(){
		madera = 40
		estaEnPie = true
	}
	
	method cobrarVida() {
	}

}

object visualYAtributos {

	method addVisual(sujeto) {
		game.addVisual(sujeto)
		game.showAttributes(sujeto)
	}

}

class BayasMedianas inherits Visual {

	var property esAtravesable = true
	var property calorias = 100
	var property position = tablero.posRandom()
	var property nombre = "bayasMedianas"
	var property tieneComportamiento = true

	method image() = "bayasMedianas.png"

	method esInteractuado(sujetoParticipe) { // bayas vuelven a aparecer cada cierto tiempo
		sujetoParticipe.sumarEnergia(calorias)
			// game.removeVisual(self)  
			// game.schedule(100.randomUpTo(1230), { game.addVisual(new BayasMedianas())})
		self.position(game.at(25, 25))
		game.schedule(6000, { => self.position(tablero.posRandom())})
	}
 
	method cobrarVida() {
		calorias = 100
	}

}

class Roca inherits Visual {

	var property position = game.at(2, 8)
	var property esAtravesable = false
	var property c = 0
	var property diccio = new Dictionary() // const y objeto mismo nombre rompen todo
	var property tieneComportamiento = false

	// const presentacion = diccio.put(presentacion,"interactua con sujetos presionando la c")
	method llenarDiccio() {
		diccio.put("arbol", "la madera pueda utilizarse para reparar  la casa") // probar
		diccio.put("bayasMedianas", "bayas aparecen cada cierto tiempo")
		diccio.put("casa", "si la casa cae pierdes el juego")
		diccio.put("zombie", "no dejes que los zombies se acerquen a la casa")
		diccio.put("personajePrincipal", "pierdes el juego al quedarte sin energia")
	}

	method image() = "piedra80.png"

	method mensajeDeDespedida() { // expandir con razon de derrota
		return "te has quedado sin energia presiona una tecla para volver a comenzar"
	}

	method darConsejo(sobreQuien) { // consejo se elegi arb 
		try { // que no lo de al mismo tiempo que ocurre el mensaje de la accion
			var consejo = diccio.get(sobreQuien.nombre())
			game.schedule(7000, { game.say(self, consejo) // bloques
				diccio.remove(sobreQuien.nombre())
			})
		} catch e : ElementNotFoundException {
		// game.say(self,"no deberia decir nada ahora")// hacer nada - preguntar 
		}
	}

	 
	method cobrarVida() {
		self.llenarDiccio()
		game.say(self, "preciona C para interactuar con objetos")
	}

}


class PersonajePrincipal inherits Visual {

	var property energia = 2
	var property position = game.at(1, 3)
	var property madera = 0
	var property contadorEscondidoDePasos = 0
	var property danio = 45
	var property nombre = "personajePrincipal"
	var property estaEnPie = false
	var property tieneComportamiento = false
	var property rocaConsejera
	method interactuarPosicion() {
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			itemFound.esInteractuado(self)
			self.cansar(10)
			rocaConsejera.darConsejo(itemFound)
		// game.say(self,"interactuo con " + itemFound.toString()) // testing
		} catch e : wollok.lang.Exception {
		// game.say(self, "no hay nada aqui para interactuar")
		}
	}

	method cansar(nro) {
		energia = energia - nro
		self.alarmaDeEnergia()
	}

	method sumarEnergia(nro) {
		energia = energia + nro
		game.say(self, "ñam")
	}

	method estaCansado() {
		return (energia <= 0)
	}

	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return ( not tablero.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() }) // get objectsIn devuelve lista. 
	}

	method irA(nuevaPos) { // toma objeto pos
	// cada paso chequeo si no hay energia o casa esta rota
		if (self.puedeMoverseA(nuevaPos)) { // solo si casillero siguiente es objeto atravesable
			estaEnPie = not estaEnPie // preguntar
			self.cansar(2)
			position = nuevaPos // asigna nueva posicion
			contadorEscondidoDePasos = contadorEscondidoDePasos + 1
		}
		if (self.estaCansado()) {
			nivel.escenarioDerrota("te has quedado sin energia")
		// sprite en el piso
		}
	}
	
	method cobrarVida(){ // conviene inicializar objeto
		energia = 1000
	  position = game.at(1, 3)
	  madera = 0
	}
	method image() {
		if (self.estaEnPie()) {
			return "shovelMain.png"
		} else return "shovelMain2.png"
	}

	method alarmaDeEnergia() {
		if (energia < 50) {
			game.say(self, "me estoy quedando sin energia")
			rocaConsejera.darConsejo(self)
		}
	}
 
	 
}

class Nube inherits Visual {

	var property position = game.at(1, 9)
	var property estadoNormal = true
	var property esAtravesable = true
	var property cDias = 0 // medida de tiempo, cuando la nube vuelve pasa de dia a noche
	var property tieneComportamiento = true

	method esInteractuado(sujeto) {
		game.say(self, "una pista o consejo") // o cambiar el clima, se ponga a llover
	}

	method image() {
		if (estadoNormal) return "nube80.png"
		return "nube5.png"
	}

	method moverDerecha() {
		if ((self.position().x() > game.width()) && (self.position().y() < game.height())) { // si la siguiente celda en x no es 0
			self.position(game.at(1, 9)) // mueve al inicio 
		} else self.position((self.position().right(1)))
		self.position(self.position().down(1))
	}

	 
	method cobrarVida() {
		game.onTick(800, "nubesSeMueven", {=> self.moverDerecha()})
	}

	override method comportamientoNoche(horario) {
		game.schedule(horario.tiempoDelDia() - 8000, { => game.say(self, "dentro de poco sera de dia")})
	}

	override method comportamientoDia(horario) {
		game.schedule(horario.tiempoDelDia() - 8000, { => game.say(self, "dentro de poco sera de noche")})
	}

}


