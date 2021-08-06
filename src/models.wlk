import wollok.game.*
//import nivel.*
import tablero.*
import nivelPrueba.*
import horario.*
import escenarioDerrota.*

class Visual{ // comportamiento necesario para polimorfismo de todos los visuales
 	
	method comportamientoNoche(horario) {
	}

	method comportamientoDia(horario) {
	}
	method esAtravesable() = true // default
	
	method cobrarVida(){}
	
	
  	
}
  
class VisualUI inherits Visual { // blueprint de visuales sin logica particular.  No me gusto utilizar solo clase visual para visuales con logica propia y visuales como carteles.
	var property image = null
	var property position = null
	//	method tieneComportamiento() = false
	 
	// No tiene sentido esta clase sin comportamiento ni atributos. 
	// Podrian agregarle position e image. Incluso el esAtravesable() 
}
  
const flechas = new VisualUI(image = "j1Guia.png", position = game.origin()) 
const guiaJugadorDos = new VisualUI(image = "j2.png", position = game.at(7,0))
//object flechas inherits Visual{ /* objetos visual sin comportamiento particular, usualmente dialogos, paso a instanciarlo con imagen como parametro desde clase Visual */
//	override method image(){
//		return "j1Guia.png"
//	}
//	method cobrarVida(){}
	//method esAtravesable() = true
	
	 
//}// mas que herencia,serian instancias de Visual  

/*  
class TileInvisible inherits Visual{
	override method image(){
		return "tileInvisible.png"
	}
	//method cobrarVida(){}
	//method esAtravesable() = false
}
*/
object mapa{
	method crearParedesInvisibles(){
	//	game.addVisualIn(new TileInvisible(),game.at(6,4)) //Mejor que el visual tenga la posicion y usar addVisual
	//	game.addVisualIn(new TileInvisible(),game.at(8,4))
		game.addVisual(new VisualUI(image = "tileInvisible.png", position = game.at(6,4))) //Mejor que el visual tenga la posicion y usar addVisual
		game.addVisual(new VisualUI(image = "tileInvisible.png", position = game.at(8,4))) //Mejor que el visual tenga la posicion y usar addVisual
	 
	}
}

 /*   paso a instanciarlos desde clase visual
object elegirDif inherits Visual{ 
	override method image() = "elegirDif.png"
	//method cobrarVida(){}
}
 
object pantallaNegra inherits Visual{
	override method image() = "pantallaNegra.png"
//	method cobrarVida(){}
	
}

object dialogoCuidadoZombies{
	method image() = "cuidado2.png"
//	method cobrarVida(){}
}

object guiaDificultad{
	method image() = "Screenshot_8.png"
//	method cobrarVida(){}
}
* 
*/
// Idem, no tienen comportamiento diferente, solo un valor diferente para un atributo

class ParteCasa inherits Visual {
 var property position
//	var property esAtravesable = true
	var property casa 
	  
	method esInteractuado(sujetoParticipe) { //  
		casa.repararCasa(sujetoParticipe) // que parteCasa no hable por casa
	}
	
	  method image() {
		return "tileInvisible.png"
	}
	
}
class Casa inherits Visual{
	
	//var property esAtravesable = true
	 
	var property salud 
	var property estaRota
	var property lista = []
	var property nombre = "casa"
	var property tieneComportamiento = false
 
 	
	method repararCasa(sujetoParticipe){ // que la casa hable por si misma
		self.salud(self.salud() + (sujetoParticipe.madera() * 2))
		game.say(self, "salud de casa + " + sujetoParticipe.madera())
		sujetoParticipe.madera(0)
	}
	
	method darMensaje() = "si la casa cae pierdes el juego"
	method position(){
		return  game.at(3, 4)
	}
	
     method image() = "casa.png"

	method esInteractuado(sujetoParticipe) { // rever
		if (sujetoParticipe.madera() > 0) {
			self.repararCasa(sujetoParticipe)
		}
	}

	method estaRota() {
		//return (salud < 0 )
		return false
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
	//	new Sonido().roturaCasa().play()
		const casaGolpeada = game.sound("roturaCasa.mp3")
		casaGolpeada.play()
		game.say(self, "ouch, me queda " + salud + " vida")
		if (salud < 0) {
	//		nivel.escenarioDerrota("la casa ha sido destruida")
			escenarioDerrota.inicio("la casa ha sido destruida")		
		}
	}

	 

}
	 
 
class Zombie inherits Visual {

	 var property position = game.at(20, 20) // game.at(1, 2.randomUpTo(9))
	//var property vida = 50
	var danio = 5
	var property nombre = "zombie"
	var property paso = true
	var property tieneComportamiento = true
	var property heroe
	var property hogar
	var property horarioZombie = null
	var vida = 50
 
	method darMensaje() = "no dejes que los zombies se acerquen a la casa"
	
	
	method vida(){
		return vida  
	}
	
	method vida(nro){
		vida = nro
	}
	method image() = "zombie3.png"
	
	method recibeDanio() {
		self.vida(self.vida() - heroe.danio())
		if (self.vida() <= 0) {
			estadisticasZombie.incrementarContador()
		//	new Sonido().agonia().play()
			const agonia = game.sound("tomasAgonia.mp3")
			agonia.play()
		//	sonido.agonia().play()
				// game.removeVisual(self)
			self.moverFueraDelMapa()
				// utilizar enfoque de fabrica de zombies crea muchas instancias de zombie que parecen relentizar el juego al pasar el tiempo(preguntar)
				// utilizar removeVisual y despues addVisualIn no me permite volver a cambiarle la posicion en game.onTick() (preguntar)
			self.traerAlMapa() // traer al mapa no tiene en cuenta el horario. necesitaria que chequee de alguna manera si es de dia o no 
		}
		 else self.huye()
	}

	override method comportamientoDia(horario) { // de dia se va del mapa
		game.schedule(1000.randomUpTo(2000), { self.moverFueraDelMapa()  })  
	}

	override method comportamientoNoche(horario) { // spawn progresivo
	//	game.schedule(500.randomUpTo(4000), { self.traerAlMapa()})
 	// 	horarioZombie = horario
		game.schedule(500.randomUpTo(6000), { 
				self.traerAlMapa()}
				
		)
 
	}
	
	
		
	method moverFueraDelMapa() { // se mueve fuera del mapa para no instanciar nuevos zombies. justificar
		self.removerEventos()
		vida = 50
	    self.position(game.at( anchoVentanas + 5,  altoVentanas + 5))  // espera que se termina el ultimo tick por las dudas.
	}
	
	
	method traerAlMapa() { // necesito un objeto casa que sea golpeable

			game.schedule(4000.randomUpTo(6000), {=> 
			//  si es de dia, no haga nada
			if (not reloj.esDeDia()){
				self.position(tablero.celdasVaciasBordes().anyOne())
				self.comenzarMovimiento(hogar)
		}})
	
	}
	
	
	 method tieneComportamiento() = true
 
	method removerEventos() {
		try{ 
		game.removeTickEvent("zombie se mueve")
		}catch e: Exception{ // evento puede no existir si ocurre que el zombie no vuelve al mapa por ser justo de dia
			//
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

	 

	method puedeMoverseA(nuevaPos) { // zombie huye solo a tiles vacios
		return ( not tablero.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).isEmpty()) // get objectsIn devuelve lista. 
		//
	}
	
	method nuevaPos(pos){
		position = pos
	}
	method estaFueraDelMapa(){
		return self.position().equals(game.at(anchoVentanas + 5, altoVentanas + 5))
	}
	
	method darUnPaso(){
		if (not self.estaFueraDelMapa()){ // con remove tick event, parece que lo remueve pero se dispara una ultima vez.
		self.position(tablero.posicionMasCercanaACasa(self))
		}
	}
	
	method comenzarMovimiento(casa) {
		game.onTick(700.randomUpTo(2009), "zombie se mueve", { => try {
			if (self.estaAlBordeDeLaCasa()) { // si la casa esta a su alcance ataca
			//	new Sonido().golpeMadera().play()
				const golpe = game.sound("golpeMadera.mp3")
				golpe.play()
				casa.recibeDanio(danio)
			} else { // si no, se mueve
				self.darUnPaso()
			}
		} catch e : wollok.lang.ElementNotFoundException {
			game.say(self, "no tengo donde ir")
			e.printStackTrace()
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
	var estaEnPie = true
	var property madera = 40
	var property nombre = "arbol"
	var property tieneComportamiento = true
 
 
	method darMensaje() = "la madera pueda utilizarse para reparar  la casa"
	
	
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
				sujetoParticipe.accionar()
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
	
	

}

object visualYAtributos {

	method addVisual(sujeto) {
		game.addVisual(sujeto)
		game.showAttributes(sujeto)
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
	//	sujetoParticipe.sumarEnergia(calorias,self)
	 
		sujetoParticipe.sumarEnergia(calorias)
		sujetoParticipe.accionar()
		self.position(game.at(25, 25))
		//var posicionNueva = tablero.posRandom()
		var tiempo = 4000.randomUpTo(8000)
		game.schedule(tiempo, { => self.reaparecer()})
		 	// game.removeVisual(self)  
			// game.schedule(100.randomUpTo(1230), { game.addVisual(new BayaMediana())})
 
	}
 	
 	method reaparecer(){
 
 		 
 	//	game.schedule(4000.randomUpTo(8000), { => self.position(posicionNueva)})
 	 	var posicionNueva = tablero.posRandom()
 	 	 self.position(posicionNueva)
 	 
 	}
	override method cobrarVida() {
		calorias = 100 //* multiplicador.numero()
	}

}


class PartePiedra inherits Visual{ // tiles invisibles que ocupan el espacio del game.say, para que no sea spawneado por un arbol.
 	 var property position
 
	//var property casa 
	
	 
	method esInteractuado(sujetoParticipe) { //  
	 	//no hace nada
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
	 override  method esAtravesable() = false
	
	method construirRoca(){
		var position1 =  self.position().up(1).right(1) // uno arriba y a la derecha
		var position2 =  self.position().right(1)
		var position3 = self.position().up(1)
		var position4 = self.position().right(2)
		var position5 = self.position().right(3)
	 	game.addVisual(new PartePiedra(position = position1))
	 	game.addVisual(new PartePiedra(position = position2))
	 	game.addVisual(new PartePiedra(position = position3))
	 	game.addVisual(new PartePiedra(position = position4))
	 	game.addVisual(new PartePiedra(position = position5))
	}
	
	
	//const presentacion = diccio.put(presentacion,"interactua con sujetos presionando la c")
	/*  
	method llenarDiccio() {
		diccio.put("arbol", "la madera pueda utilizarse para reparar  la casa") // probar
		diccio.put("BayaMediana", "Baya aparecen cada cierto tiempo")
		diccio.put("casa", "si la casa cae pierdes el juego")
		diccio.put("zombie", "no dejes que los zombies se acerquen a la casa")
		diccio.put("personajePrincipal", "pierdes el juego al quedarte sin energia")
	}
	*/
	method image() = "piedra80.png"

	method mensajeDeDespedida() { // expandir con razon de derrota
		return "te has quedado sin energia presiona una tecla para volver a comenzar"
	}
	/*  
	method darConsejo(sobreQuien) { // consejo se elegi arb 
		try { // que no lo de al mismo tiempo que ocurre el mensaje de la accion
			var consejo = diccio.get(sobreQuien.nombre())
			game.schedule(6000, { 
				game.say(self, consejo) // bloques
				diccio.remove(sobreQuien.nombre())
			})
		} catch e : ElementNotFoundException {
		// game.say(self,"no deberia decir nada ahora")// hacer nada - preguntar 
		}
	}
	// Esta parte, mas facil con polimorfismo, sin diccionario. 
	 */
	method guardarMensaje(m){
		listaProhibida.add(m)
	}
	 
	method darConsejo(sobreQuien){ // no se repitan los mensajes, 
			var mensaje = sobreQuien.darMensaje()
			if (not listaProhibida.contains(mensaje)){
				self.guardarMensaje(mensaje)
				game.schedule(10000, game.say(self, mensaje))
		 
			}}
			
	
			 
			
	
	
	override method cobrarVida() {
	//	self.llenarDiccio()
		game.say(self, "preciona C para interactuar con objetos")
	}

}


class PersonajePrincipal inherits Visual { // Tal vez se pueda pensar en una subclase comun a algunos Visuales

	var property energia = 500
     var property position = game.at(1, 3)
	var property madera = 0
	var property contadorEscondidoDePasos = 0
	var property danio = 45
	var property nombre = "personajePrincipal"
	var property estaEnPie = false
	var property tieneComportamiento = false
	var property rocaConsejera = null
  	var property image = "shovelMain.png"
  
	var property estaAnimando = false
	//var property image = "shovelMain.png"
	var property accion1 = "accion1.png"  // se utiliza redefinicion para nuevos personajes
	var property accion2 = "accion2.png"
	var property imagenPrincipal = "shovelMain.png"
	var property imagenPasoDado = "shovelMain2.png"
 
	 
 	method darMensaje(){
 		return "pierdes el juego al quedarte sin energia"
 	}
 	 
 	
	method danio(){
		return danio * multiplicador.numero()
	}
	
	method interactuarPosicion() {
		 
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			itemFound.esInteractuado(self)
			self.cansar(10)
			
		  rocaConsejera.darConsejo(itemFound)
		// game.say(self,"interactuo con " + itemFound.toString()) // testing
		} catch e : wollok.lang.Exception { // Illegal operation 'uniqueElement' on collection with 2 elements
		 //	e.printStackTrace()  tests
			var lista = game.getObjectsIn(position)
		 	
	 		lista.forEach{ v => v.esInteractuado(self)}
		 	
		}
	}
	method moverPala(){
		estaAnimando = true
		image = accion1
		game.schedule(100,{=>image =accion2})
			
			game.schedule(200,{=>self.cambiarImagen(imagenPrincipal)
				estaAnimando = false
			})
		}
	
	
	
	method hacerPasos(){
		if (image == imagenPrincipal){
			image = imagenPasoDado
		} else{
			image = imagenPrincipal
		}
	}
		
		
	method accionar(){
		game.say(self,"energia : " + self.energia())
		self.moverPala()
		
		
	}
	method cambiarImagen(img){
		image = img
	}

	
	method esInteractuado(personaje){
		//no hace nada
	}


	// method sumarEnergia(nro,baya) {
	method sumarEnergia(nro) {
		energia = energia + nro
	// 	game.say(self, "ñam   Energia : " + self.energia() + " (" + baya.calorias() + ") ")
	}

	method estaCansado() {
		return (energia <= 0)
	}
	/*  
	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return ( not tablero.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() }) // get objectsIn devuelve lista. 
	} */
	
	method puedeMoverseA(nuevaPos) { // si es atravezable y no esta fuera del limite
		return  game.getObjectsIn(nuevaPos).all{ sujeto => sujeto.esAtravesable() } // get objectsIn devuelve lista. 
	}
	
	
	
	method cansar(nro) {
	//	energia = energia - nro
	}
	
	method alarmaDeEnergia(){
		if (energia < 0){
			escenarioDerrota.inicio("te has quedado sin energia")
		}
	}
	method efectoDeCaminar(){ 
		self.aumentarContadorPasos()
		self.alarmaDeEnergia()
	  	estaEnPie = not estaEnPie
		self.ruido().play()
	}
	
	method aumentarContadorPasos(){
		contadorEscondidoDePasos = contadorEscondidoDePasos + 1
	}
	
	method ruido(){
		if (contadorEscondidoDePasos % 2 == 0){ 
	 		//return new Sonido().paso1() 
	 		const paso1 = game.sound("caminata1.mp3")
	  		 return paso1
	 	}else{
	 	 //   return  new Sonido().paso2() 
	 	     const paso2 = game.sound("caminata2.mp3")
	 	     return paso2
	 	}
	}
	
	 
	
	

	
	

	
 
	 
}

 


class Nube inherits Visual {

	  var property position = game.at(1, 9)
	var property estadoNormal = true
 
	var property cDias = 0 // medida de tiempo, cuando la nube vuelve pasa de dia a noche
	var property tieneComportamiento = true
	var property loc = null
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
		} else 
			self.position((self.position().right(1)))
			self.position(self.position().down(1))
			if (self.hayUnaBaya()){
				self.comerBaya()
				estadisticasBayas.incrementarContador()
			}
	}
	
	
	method comerBaya(){
		game.say(self,"ñam")
	 loc.reaparecer()
	}
	 
	method hayUnaBaya(){
	   
	 	try{
	 		loc = game.uniqueCollider(self)
	 	 	return listaBaya.lista().contains(loc)
		}catch e : Exception{
			return false
		}
		  /*
		 if (game.colliders(self).isEmpty()){
		 	return false
		 }else{
		 	return listaBaya.lista().contains(game.colliders(self))
		 }
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


