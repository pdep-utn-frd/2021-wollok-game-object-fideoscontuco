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

	method reiniciarEstado() {
		salud = 40
	}

}

object tablero {

	method celdasVaciasBordes() { // completar
		const posiciones = []
		const ancho = game.width() - 2
		const alto = game.height() - 2
		(0 .. alto  ).forEach{ num => posiciones.add(game.at(0, num))} // lado izquierdo
		(0 .. alto  ).forEach{ num => posiciones.add(game.at(ancho, num))} // derecha 
		(0 .. ancho ).forEach{ num => posiciones.add(game.at(num, alto))} // arriba 
		(0 .. ancho ).forEach{ num => posiciones.add(game.at(num, 0))}
		return posiciones.filter{ pos => game.getObjectsIn(pos).isEmpty() } // array solo con true
	}

	method espacioLibreAlrededor(posicion) { // tom 4 direcciones posibles y toma la aprimera que este empty
		const posiciones = [ posicion.up(1), posicion.down(1), posicion.right(1), posicion.left(1) ]
		return posiciones.filter{ p => self.puedeMoverseA(p) }.anyOne() // check si esta fuera de limite o 
	}

	// logica repetida 
	method fueraDelLimite(nuevaPos) {
		const x = nuevaPos.x()
		const y = nuevaPos.y()
		return (x > game.width() or x < 0) or ( y >= game.height() or y < 0)
	}

	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return ( not self.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() }) // get objectsIn devuelve lista. 
		//
	}

	method reiniciarEstado() {
	}
	
	
	method espacioLibreEnMapa(){  // preguntar
		var listaOcupados = []
		var listaTotal = []
		(0 .. 10).forEach{ x=> (x .. 10).forEach{ y => listaTotal.add(game.at(x,y))}} 
		game.allVisuals().forEach{ v => listaOcupados.add(v.position())}
		listaTotal.removeAll(listaOcupados)
		return listaTotal 
	}
	
	method posRandom(){
		return self.espacioLibreEnMapa().anyOne()
	}
	 
}

class Sonido{ // los sonidos pueden ejecutarse una sola vez, 
//entonces instanciamos
	var property agonia = game.sound("tomasAgonia.mp3")
}

object zombie {

	var property position = game.at(1, 0) // game.at(1, 2.randomUpTo(9))
	var property image = "zombie3.png"
	var property vida = 100
	var danio = 10
	 
	
	method recibeDanio() {
		vida = vida - personajePrincipal.danio()
		 
		if (vida <= 0) {
			new Sonido().agonia().play()
			self.position(game.at(15, 15)) // moverlo a 15 o respawnear? Preguntar mejor enfoque
			self.hacerMasFuerte()
			
			game.schedule(2000, { self.position(tablero.celdasVaciasBordes().anyOne())})
		} else self.huye()
	}

	// logica repetida con personajePrincipal , pasar a clase mas adelante
	method fueraDelLimite(nuevaPos) {
		const x = nuevaPos.x()
		const y = nuevaPos.y()
		return (x > game.width() or x <= -1) or ( y > game.height() or y <= -1) // rever 
	}

	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return ( not self.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() }) // get objectsIn devuelve lista. 
	}

	// //
	method huye() { // que espacio hay libre disponible alrededor de el??
		self.position(tablero.espacioLibreAlrededor(self.position()))
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
		position = game.at(1, 0)
		danio = 10
		vida = 100
	}

}

class Arbol {

	var property position = tablero.posRandom()
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
			madera = 0
		}
	}

	method reiniciarEstado() {
		estaEnPie = true
		madera = 40
	}

}
/*  
object listaDeArboles{
	var lista = []
	
	method cuantosArboles(nro){
		nro.times{game.addVisualnew Arbol()}
	}
}
 */
class BayasMedianas {

	var property esAtravesable = true
	var property calorias = 10
	var property position = game.at(1, 3)

	method image() = "bayasMedianas.png"

	method esInteractuado(sujetoParticipe) {
		sujetoParticipe.sumarEnergia(calorias)
		game.say(sujetoParticipe, "ñam")
		game.removeVisual(self)
	}

	method reiniciarEstado() {
	}

}

object roca {

	var property position = game.at(2, 8)
	var property esAtravesable = false
	var property c = 0
	var property diccio = new Dictionary() // const y objeto mismo nombre rompen todo

	// const presentacion = diccio.put(presentacion,"interactua con sujetos presionando la c")
	method llenarDiccio() {
		diccio.put(new Arbol(), "la madera pueda utilizarse para reparar  la casa")
			// diccio.put(bayasMedianas, "bayas aparecen cada cierto tiempo")
		diccio.put(casa, "si la casa cae pierdes el juego")
		diccio.put(zombie, "no dejes que los zombies se acerquen a la casa")
	}

	method image() = "piedra80.png"

	method mensajeDeBienvenida() {
		self.llenarDiccio()
		return "preciona C para interactuar con objetos"
	}

	method mensajeDeDespedida() { // expandir con razon de derrota
		return "te has quedado sin energia presiona una tecla para volver a comenzar"
	}

	/*  
	 * method darConsejoTemporizado(sobreQuien){
	 * 	game.schedule(10000,self.darConsejo(sobreQuien)) // ver 
	 } */
	method darConsejo(sobreQuien) { // consejo se elegi arb 
		try { // que no lo de al mismo tiempo que ocurre el mensaje de la accion
			var consejo = diccio.get(sobreQuien)
			game.schedule(3000, { game.say(self, consejo) // bloques
				diccio.remove(sobreQuien)
			})
		} catch e : ElementNotFoundException {
		// game.say(self,"no deberia decir nada ahora")// hacer nada - preguntar 
		}
	}

	method reiniciarEstado() {
	}

}

//como inicializo u n dictionary y lo populo de mejor manera?
/*  
 * object diccioDeBuenosConsejos { //quiero que los consejos se agoten. sean un one shot 

 * 	var property diccio = new Dictionary() // const y objeto mismo nombre rompen todo
 * 	// const presentacion = diccio.put(presentacion,"interactua con sujetos presionando la c")
 * 	const madera = diccio.put(arbol, "la madera pueda utilizarse para reparar  la casa")
 * 	const bayas = diccio.put(bayasMedianas, "bayas aparecen cada cierto tiempo")
 * 	const hogar = diccio.put(casa, "si la casa cae pierdes el juego")
 * 	const zomb = diccio.put(zombie, "no dejes que los zombies se acerquen a la casa")
 * 	
 * 	 
 }*/
// para que las paredes de la casa no puedan ser atravesadas y solo pueda entrarse por la puerta
// un mejor enfoque seria dividir la imagen en 4 de la casa, y tener un objeto padre que
// conoce la salud de la casa, y pasarle a los  hijos que se encargen del metodo imagen c/u
object techoCasa { // ver unir casa 

	var property position = casa.position().up(1)
	var property esAtravesable = false

	method image() {
		return "tileInvisible.png"
	}

	method reiniciarEstado() {
	}

}

object chimeneaCasa {

	var property position = casa.position().right(1)
	var property esAtravesable = false

	method image() {
		return "tileInvisible.png"
	}

	method reiniciarEstado() {
	}

}

object jardinCasa {

	var property position = casa.position().right(1).up(1)
	var property esAtravesable = false

	method image() {
		return "tileInvisible.png"
	}

	method reiniciarEstado() {
	}

}

////
object personajePrincipal {

	var property energia = 333
	var property position = game.at(1, 3)
	var property madera = 0
	var property contadorEscondidoDePasos = 0
	var property danio = 40

	method image() = "shovelMain.png"

	method interactuarPosicion() {
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			itemFound.esInteractuado(self)
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
	}

	method estaCansado() {
		return (energia <= 0)
	}

	method fueraDelLimite(nuevaPos) {
		const x = nuevaPos.x()
		const y = nuevaPos.y()
		return (x >= game.width() or x <= -1) or ( y >= game.height() or y <= -1)
	}

	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return ( not self.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() }) // get objectsIn devuelve lista. 
		//
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
		if (self.estaCansado()) {
			nivel.escenarioDerrota()
		}
	// si queda con e nergia negativa o su casa esta rota luego de
	// finalizar el paso pierde
	}

	method alarmaDeEnergia() {
		if (energia < 15) {
			game.say(self, "me estoy quedando sin energia")
			roca.darConsejo(self)
		}
	}

	method reiniciarEstado() {
		self.energia(333)
		position = game.center()
		madera = 0
		contadorEscondidoDePasos = 0
		danio = 40
	}

}

/*  
 * object derrota {

 * 	method comprobarDerrota(sujeto) {
 * 		if (sujeto.cansado() or casa.estaRota()) {
 * 			nivel.escenarioDerrota() // cambia escena
 * 		}
 * 	}

 * }
 */
object nube {

	var property position = game.at(1, 9)
	var property estadoNormal = true
	var property esAtravesable = true

	// var property contadorDeOdio
	method esInteractuado(sujeto) {
		game.say(self, "una pista o consejo") // o cambiar el clima, se ponga a llover
	}

	method avanzarElTiempo() {
	}

	method image() {
		if (estadoNormal) return "nube80.png"
		return "nube5.png"
	}

	method moverDerecha() {
		if ((self.position().x() > game.width()) && (self.position().y() < game.height())) { // si la siguiente celda en x no es 0
			self.position(game.at(1, 9)) // mueve al inicio y suma 1 dia
		} else self.position((self.position().right(1)))
		self.position(self.position().down(1))
	}

	method reiniciarEstado() {
		position = game.at(1, 9)
	}

}

object dia {

	var property dia = 0

	method pasarUnDia() {
		dia = dia + 1 // si pasan 5 dias aparecen plantas, igual mobs. timer. 
	}

}

