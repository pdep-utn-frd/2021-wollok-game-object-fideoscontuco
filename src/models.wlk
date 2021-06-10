import wollok.game.*
import nivel.*
import tablero.*

/*  
 * class Visuales{
 * method cobrarVida()
 * method nombre()
 * method reiniciarEstado()
 * method esAtravezable() = true
 * method puedeMoverse(sujeto)
 * method posicionesProximas(sujeto){ // codigo repetido en otros
 * 		return [sujeto.position().up(1), sujeto.position().down(1), sujeto.position().right(1), sujeto.position().left(1) ]
 * 	}
 */
class ParteCasa {

	var property position
	var property esAtravesable = true

	method esInteractuado(sujetoParticipe) {
		casa.salud(casa.salud() + (sujetoParticipe.madera() * 2))
		game.say(casa, "salud de casa + " + sujetoParticipe.madera())
		sujetoParticipe.madera(0)
	}

	method image() {
		return "tileInvisible.png"
	}

	method cobrarVida() {
	}

	method reiniciarEstado() {
	}

}

/*  
 * class Direccion{
 * 	var property position
 * 	method arriba(){
 * 		return self.position().up(1)
 * 	}
 * 	method derecha(){
 * 		return self.position().right(1)
 * 	}
 * 	method izquierda(){
 * 		return self.position().left(1)
 * 	}
 * 	method abajo(){
 * 		return self.position().down(1)
 * 	}
 * }
 */
object casa {

	var property esAtravesable = true
	// var property position = game.at(3, 4) // tiene varios position
	var property salud = 80
	var property estaRota
	var property lista = []
	var property nombre = "casa"
	var property position = game.at(3, 4)

	method image() = "casa.png"

	method esInteractuado(sujetoParticipe) {
		if (sujetoParticipe.madera() > 0){
		salud = salud + (sujetoParticipe.madera() * 2)
		game.say(self, "salud de casa + " + sujetoParticipe.madera())
		sujetoParticipe.madera(0)
		
		}
	}

	method estaRota() {
		return (salud < 0 )
	}

	method reiniciarEstado() {
		salud = 40
	}

	method celdasOcupadas() {
		// return [self.arriba(),self.derecha(),
		// self.derecha().arriba()]
		return [ self.position().up(1), self.position().right(1), self.position().up(1).right(1) ]
	}

	method dibujar() {
		game.addVisual(self)
		game.showAttributes(self)
		game.addVisual(new ParteCasa(position = self.position().right(1)))
		game.addVisual(new ParteCasa(position = self.position().up(1)))
		game.addVisual(new ParteCasa(position = self.position().up(1).right(1)))
	}

	method recibeDanio(danio) { // logica repetida, probar clase
		salud = salud - danio
		game.say(self, "ouch, me queda " + salud + " vida")
		if (salud < 0) {
			nivel.escenarioDerrota()
		}
	}

	method cobrarVida() {
	}

}

class Sonido { // los sonidos pueden ejecutarse una sola vez, 
//entonces instanciamos

	var property agonia = game.sound("tomasAgonia.mp3")

}

class Zombie {

	var property position = tablero.celdasVaciasBordes().anyOne() // game.at(1, 2.randomUpTo(9))
	var property image = "zombie3.png"
	var property vida = 100
	var danio = 10
	var property nombre = "zombie"

	method recibeDanio() {
		vida = vida - personajePrincipal.danio()
		if (vida <= 0) {
			new Sonido().agonia().play()
			game.removeVisual(self)
			const zombieNuevo = new Zombie()
			game.schedule(3000, { game.addVisual(zombieNuevo)
				zombieNuevo.cobrarVida()
			}) // reemplazante
		} else self.huye()
	}

	method removerEventos(){
		 game.removeTickEvent("zombie se mueve")
		try{
			  game.removeTickEvent("zombie ataca")
		}catch e: Exception{
			
		}
	}
	// //
	method huye() { // que espacio hay libre disponible alrededor de el??
		self.position(tablero.espacioLibreAlrededor(self).anyOne())
	}

	method hacerMasFuerte() {
		vida = 100
		danio = danio + 10
	}

	// var nombre
	method esInteractuado(sujetoParticipe) {
		game.say(self, "ouch")
		self.recibeDanio()
	}

	method esAtravesable() = true

	method reiniciarEstado() {
		danio = 10
		vida = 100
	}

	method puedeMoverseA(nuevaPos) { // zombie huye solo a tiles vacios
		return ( not tablero.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).isEmpty()) // get objectsIn devuelve lista. 
		//
	}

	method cobrarVida() { // necesito un objeto casa que sea golpeable
		game.onTick(4000, "zombie se mueve", { =>
			self.position(tablero.posicionMasCercanaACasa(self))
			if (self.estaAlBordeDeLaCasa(self)) {
				game.removeTickEvent("zombie se mueve")
					// game.say(self, "llegue")   preguntar por que da error
				self.atacar()
			}
		})
	}

	/* 
	 * game.onCollideDo(self, { casa =>
	 * 	casa.recibeDanio(self.danio())
	 * 	game.removeTickEvent("zombie se mueve")
	 * })
	 */
	method estaAlBordeDeLaCasa(sujeto) {
		return tablero.posicionesProximas(sujeto).any{ c => casa.celdasOcupadas().contains(c) }
	}

	method atacar() {
		game.onTick(8000, "zombie ataca", { =>
			var sonido = new Sonido()
			sonido.agonia().play()
			casa.recibeDanio(danio)
		})
	}

}

class Arbol {

	var property position = tablero.posRandom()
	var property esAtravesable = true
	var property calorias = 0
	var estaEnPie = true
	var property madera = 40
	var property nombre = "arbol"

	method image() {
		if (not estaEnPie) {
			return "tronco.png"
		}
		return "arbol801.png"
	}

	method esInteractuado(sujetoParticipe) {
		if (estaEnPie) {
			estaEnPie = false
			if (madera > 0){ 
			sujetoParticipe.cansar(10) // reever
			sujetoParticipe.madera(sujetoParticipe.madera() + madera)
			game.say(sujetoParticipe, "madera  + " + madera)
			madera = 0
			game.schedule(500, { self.reiniciarEstado()})
			}
		}
	}

	method reiniciarEstado() {
		estaEnPie = true
		madera = 40
	}

	method instanciarNuevo() {
		return new Arbol()
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

class BayasMedianas {

	var property esAtravesable = true
	var property calorias = 100
	var property position = tablero.posRandom()
	var property nombre = "bayasMedianas"

	method image() = "bayasMedianas.png"

	method esInteractuado(sujetoParticipe) { // bayas vuelven a aparecer cada cierto tiempo
		sujetoParticipe.sumarEnergia(calorias)
		game.removeVisual(self)
		game.schedule(100.randomUpTo(1230), { game.addVisual(new BayasMedianas())})
	}

	method reiniciarEstado() {
	}

	method instanciarNuevo() {
		return new BayasMedianas()
	}

	method cobrarVida() {
		calorias = 100
	}

}

object roca {

	var property position = game.at(2, 8)
	var property esAtravesable = false
	var property c = 0
	var property diccio = new Dictionary() // const y objeto mismo nombre rompen todo

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

	method reiniciarEstado() {
		self.position(tablero.posicionesProximas(self).anyOne())
	}

	method cobrarVida() {
		self.llenarDiccio()
		game.say(self, "preciona C para interactuar con objetos")
	}

}

object personajePrincipal {

	var property energia = 333
	var property position = game.at(1, 3)
	var property madera = 0
	var property contadorEscondidoDePasos = 0
	var property danio = 40
	var property nombre = "personajePrincipal"
	var property estaEnPie = false

	method interactuarPosicion() {
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			itemFound.esInteractuado(self)
			self.cansar(10)
			roca.darConsejo(itemFound)
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
			self.cansar(5)
			position = nuevaPos // asigna nueva posicion
			contadorEscondidoDePasos = contadorEscondidoDePasos + 1
		}
		if (self.estaCansado()) {
			nivel.escenarioDerrota()
		}
	}

	method image() {
		if (self.estaEnPie()) {
			return "shovelMain.png"
		} else return "shovelMain2.png"
	}

	method alarmaDeEnergia() {
		if (energia < 15) {
			game.say(self, "me estoy quedando sin energia")
			roca.darConsejo(self)
		}
	}

	method reiniciarEstado() { // rever, cambiar energia requeire en ambos lugares,no esta bueno
		self.energia(333)
		position = game.center()
		madera = 0
		contadorEscondidoDePasos = 0
		danio = 40
	}

	method cobrarVida() {
	}

}

object dia {

	var property estado = true

	method cambiarEstado() {
		if (self.estado()) {
			game.ground("Terreno.png")
			self.estado(false)
		} else game.boardGround("noche.png")
		self.estado(true)
	}

	method reiniciarEstado() {
	}

	method cobrarVida() {
	}

}

object nube {

	var property position = game.at(1, 9)
	var property estadoNormal = true
	var property esAtravesable = true
	var property cDias = 0 // medida de tiempo, cuando la nube vuelve pasa de dia a noche
	var property nombre = nube

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

	method reiniciarEstado() {
		position = game.at(1, 9)
	}

	method cobrarVida() {
		game.onTick(800, "nubesSeMueven", {=> self.moverDerecha()})
	}

}

