import wollok.game.*
import nivel.*
import tablero.*
	/*  
class Visuales{
	method cobrarVida()
	method reiniciarEstado()
	
}*/

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

 	method cobrarVida(){}
	method reiniciarEstado(){}
}

object casa  {

	var property esAtravesable = true
	var property position = game.at(3, 4) // tiene varios position
	var property salud = 40
	var property estaRota
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

	method dibujar() {
		game.addVisual(self) // si esta al final se rompe
		game.addVisual(new ParteCasa(position = self.position().up(1)))
		game.addVisual(new ParteCasa(position = self.position().right(1)))
		game.addVisual(new ParteCasa(position = self.position().right(1).up(1)))
		game.showAttributes(self)
	}
	
	method recibeDanio(danio){ // logica repetida, probar clase
		salud = salud - danio
		game.say(self,"ouch, me queda " + salud + " vida")
		if (salud < 0){
			nivel.escenarioDerrota()
		}
	}
	
	method cobrarVida(){}
 
}

class Sonido { // los sonidos pueden ejecutarse una sola vez, 
//entonces instanciamos

	var property agonia = game.sound("tomasAgonia.mp3")

}


class Zombie  {
	var property position = tablero.celdasVaciasBordes().anyOne()// game.at(1, 2.randomUpTo(9))
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
		self.position(tablero.espacioLibreAlrededor(self.position()).anyOne())
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
	
	
  method cobrarVida(){ // necesito un objeto casa que sea golpeable
		
 
		game.onTick(4000, "zombie se mueve", { => 
			self.position(tablero.posicionMasCercanaACasa(self))
			if (self.llegoALaCasa(self.position()) ){
				game.removeTickEvent("zombie se mueve")
				game.say(self,"llegue")
				self.atacar()
			}
			
				 
				 
			})
			}
		
		/* 
		game.onCollideDo(self, { casa =>
			casa.recibeDanio(self.danio())
			game.removeTickEvent("zombie se mueve")
		})
		*/
	
	
	method llegoALaCasa(posicion){
	const posiciones = [ posicion.up(1), posicion.down(1), posicion.right(1), posicion.left(1) ]
	return posiciones.any{p => game.getObjectsIn(p) == [casa]}
	}
	
	method atacar(){
		game.onTick(6000,"zombie ataca", { => var sonido = new Sonido() 
			sonido.agonia().play() 
			casa.recibeDanio(danio)
		})
		
	}
	
}

 
class Arbol  {

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
			sujetoParticipe.madera(sujetoParticipe.madera() + 15)
			game.say(sujetoParticipe, "madera  + " + madera)
			madera = 0
		}
	}

	  method reiniciarEstado() {
		estaEnPie = true
		madera = 40
	}

	method instanciarNuevo() {
		return new Arbol()
	}
	
	  method cobrarVida(){}
}

object visualYAtributos {

	method addVisual(sujeto) {
		game.addVisual(sujeto)
		game.showAttributes(sujeto)
	}

}

class BayasMedianas {

	var property esAtravesable = true
	var property calorias = 10
	var property position = tablero.posRandom()

	method image() = "bayasMedianas.png"

	method esInteractuado(sujetoParticipe) {
		sujetoParticipe.sumarEnergia(calorias)
		game.say(sujetoParticipe, "ñam")
		game.removeVisual(self)
	}

	method reiniciarEstado() {
	}

	method instanciarNuevo() {
		return new BayasMedianas()
	}
	
	  method cobrarVida(){}
}

object roca {

	var property position = game.at(2, 8)
	var property esAtravesable = false
	var property c = 0
	var property diccio = new Dictionary() // const y objeto mismo nombre rompen todo

	// const presentacion = diccio.put(presentacion,"interactua con sujetos presionando la c")
	method llenarDiccio() {
		diccio.put(new Arbol(), "la madera pueda utilizarse para reparar  la casa") // probar
			// diccio.put(bayasMedianas, "bayas aparecen cada cierto tiempo")
		diccio.put(casa, "si la casa cae pierdes el juego")
		diccio.put(new Zombie(), "no dejes que los zombies se acerquen a la casa")
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
	
	method reiniciarEstado(){}

	method cobrarVida(){
		game.schedule(3000, {game.say(self,self.mensajeDeBienvenida())})		
	}
}

object personajePrincipal {

	var property energia = 333
	var property position = game.at(1, 3)
	var property madera = 0
	var property contadorEscondidoDePasos = 0
	var property danio = 5

	method image() = "shovelMain.png"

	method interactuarPosicion() {
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			itemFound.esInteractuado(self)
		// roca.darConsejo(itemFound)
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

	method irA(nuevaPos) { // toma objeto pos
	// cada paso chequeo si no hay energia o casa esta rota
		if (self.puedeMoverseA(nuevaPos)) { // solo si casillero siguiente es objeto atravesable
			self.cansar(2)
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

	method reiniciarEstado() { // rever, cambiar energia requeire en ambos lugares,no esta bueno
		self.energia(333)
		position = game.center()
		madera = 0
		contadorEscondidoDePasos = 0
		danio = 5
	}
	
	method cobrarVida(){
		
	}
	
}

object dia {

	var property estado = "dia"

	method cambiarEstado() {
		if (self.estado() == "dia") {
			self.oscurer()
		} else self.esclarecer()
	}

	method esclarecer() { // cambia el bg, simple por ahora. extender con dif modelos o musica
		game.ground("dia.png")
	// game.allVisuals().forEach{ v => v.image("vNoche")}
	}

	method oscurer() {
		game.ground("oscurecer")
	}

	method reiniciarEstado() {
		estado = "dia"
	}
	
	method cobrarVida(){}
}

object nube {

	var property position = game.at(1, 9)
	var property estadoNormal = true
	var property esAtravesable = true
	var property cDias = 0 // medida de tiempo, cuando la nube vuelve pasa de dia a noche
	// var property contadorDeOdio

	method esInteractuado(sujeto) {
		game.say(self, "una pista o consejo") // o cambiar el clima, se ponga a llover
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
	
	method cobrarVida(){
		
	}
	
}

