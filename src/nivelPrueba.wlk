import wollok.game.*
import models.*
import tablero.*
import models.*

const reloj = new Horario()
const anchoVentanas = 15
const altoVentanas = 15

class Ventanas {

	var property ancho = anchoVentanas
	var property alto = anchoVentanas
	
	//configurar pantalla podria ir aca y utilizarse super en otras.
}
object elegirDif inherits Visual{
	method image() = "elegirDif.png"
	method cobrarVida(){}
}

object pantallaNegra inherits Visual{
	method image() = "pantallaNegra.png"
	method cobrarVida(){}
}

object dialogoCuidadoZombies{
	method image() = "cuidado2.png"
	method cobrarVida(){}
}

object guiaDificultad{
	method image() = "Screenshot_8.png"
	method cobrarVida(){}
}
object seleccionDificultad inherits Ventanas { // como se podra usar el mouse?
	 var property dificultad = facil
	
	method inicio() { // pantalla inicial de seleccion de dificultades
		
		 
		game.height(alto)
		game.width(ancho)
	//	game.boardGround("tileNegro.png")
	 	game.title("fideosConTuco  X salir / L nueva dificultad / C interactuar")
		
		game.addVisualIn(pantallaNegra,game.origin())
		game.addVisualIn(elegirDif, game.at(4,12))
		game.addVisualIn(guiaDificultad,game.origin())
		game.addVisual(dificil)
		game.addVisual(facil)
		game.addVisual(normal)
	 	 
		self.configurarTeclado()
		
	}

	method configurarTeclado() { // mover con las flechas pasa de un objeto a otro, seleccionar ejecuta el nivel.
		keyboard.x().onPressDo({game.stop()})
		keyboard.up().onPressDo({ 
	 		new Sonido().sonidoMenu().play()
			dificultad.quitarMarca() // quita marca a dificultad actual 
			dificultad.siguiente().remarcar()   // pone marca en dificultad siguiente
			self.nuevaDificultad(dificultad.siguiente()) // nueva dificultad para
			 
		})
	 	keyboard.down().onPressDo({ 
	 		new Sonido().sonidoMenu().play()
	 		dificultad.quitarMarca() // quita marca a dificultad actual 
			dificultad.anterior().remarcar()   // pone marca en dificultad siguiente
			self.nuevaDificultad(dificultad.anterior()) // nueva dificultad para
			 
	 	}) 
		keyboard.enter().onPressDo({ dificultad.seleccionar()})
	}
	
	//estaria bueno una confirmacion, tipo.  SEGURO Y N  en una ventana.
	
 	 
 	method nuevaDificultad(nuevaDificultad){
 		dificultad = nuevaDificultad
 	}
 	
 
 	
}


object facil inherits Visual {

	var property position = game.at(4, 3)
	var property estaRemarcado = true

	method image() { // podria resumirse en clase
		if (not estaRemarcado) {
			return "facil2.png"
		} else {
			return "facilRemarcado2.png"
		}
	}
 	
 	method siguiente() = normal
 	
	method anterior () = dificil
	method remarcar() {
		estaRemarcado = true
	}
	
	method quitarMarca(){
		estaRemarcado = false
	}
	
	method seleccionar(){
		game.clear()
		game.title("sdsdsdsd")
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		game.schedule(1, {=>   nivelFacil.inicio()})
		
		 
	}
	
}

 
object dificil inherits Visual {

	var property position = game.at(4, 9)
	var property estaRemarcado = false

	method image() { // podria resumirse en clase
		if (not estaRemarcado) {
			return "dificil.png"
		} else {
			return "dificilRemarcado.png"
		}
	}
 
		method quitarMarca(){
		estaRemarcado = false
	}
	
	method remarcar() { //  le quita la marca a uno anterior, y  remarca uno nuevo,
		 
		estaRemarcado = true
	}
	
	method siguiente() = facil
	method anterior() = normal
	
	method seleccionar(){
		//preguntar si esta seguro?
		game.clear()
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		game.schedule(1, {=> nivelDificil.inicio()})
	
	}

}
 

object normal inherits Visual {

	var property position = game.at(4, 6)
	var property estaRemarcado = false

	method image() { // podria resumirse en clase
		if (not estaRemarcado) {
			return "normal.png"
		} else {
			return "normalRemarcado.png"
		}
	}
	
	
	
	method quitarMarca(){
		estaRemarcado = false
	}
	
	method siguiente() = dificil
	method anterior() = facil 
	method remarcar() {
		estaRemarcado = true
	}
	
	method seleccionar(){
		game.clear()
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		game.schedule(1, {=> nivelNormal.inicio()})
		
	}

}



object burbujaC inherits Visual{
	method image(){
		return "burbuja.png"
	}
	method cobrarVida(){}
	method esAtravesable() = true
}

object flechas inherits Visual{
	method image(){
		return "guia15.png"
	}
	method cobrarVida(){}
	method esAtravesable() = true
	
	 
}

class TileInvisible inherits Visual{
	method image(){
		return "tileInvisible.png"
	}
	method cobrarVida(){}
	method esAtravesable() = false
}

object mapa{
	method crearParedesInvisibles(){
		game.addVisualIn(new TileInvisible(),game.at(6,4))
		game.addVisualIn(new TileInvisible(),game.at(8,4))
	}
}
// que hace siguiente? remarca al siguiente, lo elegido.  y lo pone como la decision actual
class Nivel inherits Ventanas { // 750 * 750  // plano de niveles

	// var property ancho = 15
	// var property alto = 15
	//var property multiplicador   // incrementa o reduce la capacidad de actores
	const casaActual = new Casa(estaRota = false )
	const roca = new Roca()
	const nube = new Nube() // hacerlos por fuera de nivel?
	const personajePrincipal = new PersonajePrincipal(  rocaConsejera = roca)
	var property reiniciado = false

	method inicio() {
		game.clear()
		self.configurarPantalla()
		game.addVisual(reloj) // que no sea al mismo tiempo.
		mapa.crearParedesInvisibles()
		casaActual.dibujar()
		tablero.casa(casaActual)
		visualYAtributos.addVisual(personajePrincipal)
		//game.addVisualIn(dialogoCuidadoZombies, game.at(3,10) )
		
		game.addVisual(nube)
		game.addVisual(roca)
		 
		roca.construirRoca()
	//	4.randomUpTo(8).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
		
		self.spawnear()
		game.addVisualIn(flechas,game.at(0,0))
		game.schedule(reloj.tiempoDelDia()/2,{=> game.removeVisual(flechas)})
		 //game.addVisualIn(flechas,game.at(10,9)
		
		mapa.crearParedesInvisibles()
		
		game.allVisuals().forEach{ v => v.cobrarVida()} // no esta bueno dos propositos en mismo mensaje
		self.configurarTeclado()
	}

	/*  
	 * 
	 *  // rever,  discrimina  los objetos, preferible game.allvisuals
	 * 	method visualesComportamiento() { // se filtra para reducir el numero, por ej, quitar arboles, y reducir la carga del pedido.
	 * 
	 * 	//return game.allVisuals().filter{ v => v.tieneComportamiento() }
	 * 	return game.allVisuals().filter{ v => (v.comportamientoDia()) == null && (v.comportamientoNoche() == null) } // si ambas dan null no tiene nada que ofrecer y es quitado de la lista
	 * 	// se quita para reducir la lista y que la transicion no demore mucho por una lista muy grande(muchos arboles)
	 * }
	 */
	method spawnear()

	method configurarPantalla() {
		// game.clear()
		game.height(alto)
		game.width(ancho)
		 
	}
	
	
	method configurarTeclado() {
		keyboard.x().onPressDo({game.stop()})
		keyboard.c().onPressDo{ personajePrincipal.interactuarPosicion()}
		keyboard.up().onPressDo({ personajePrincipal.irA(personajePrincipal.position().up(1))})
		keyboard.down().onPressDo({ personajePrincipal.irA(personajePrincipal.position().down(1))})
		keyboard.right().onPressDo({ personajePrincipal.irA(personajePrincipal.position().right(1))})
		keyboard.left().onPressDo({ personajePrincipal.irA(personajePrincipal.position().left(1))})
		keyboard.l().onPressDo({
	 		game.removeTickEvent("dia cambia")
			 game.clear()
			 reloj.estado(dia)  // probar instanciar
			game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
			 
		//	game.schedule(1, {=> self.inicio()}) // utilizo schedule para que wollok ejecute self.inicio() ejecute el bloque solo cuando termino de dibujar, sino se tildaria con la pantalla anterior dibujada.
			// onPressDo espera a que finalice  inicio para continuar por estar dentro de bloque.  game.schedule tiene su propio bloque
			game.schedule(1,{=> seleccionDificultad.inicio()})
		})
	}
	/*  
	method escenarioDerrota(razon) {
		game.clear()
			// game.addVisualIn("derrota.png", game.origin())
		game.width(ancho)
		game.title("fideosConTuco-casero")
		game.height(alto)
		game.addVisualIn(roca, game.center())
		game.say(roca, "has perdido: " + razon) // razon de derrota.
		game.schedule(6000, {=>
			game.say(roca, "presiona cualquier tecla para volver a comenzar")
			keyboard.any().onPressDo{ game.clear() // como reinicio
				game.addVisual(new Cargando())
				game.schedule(500, {=> self.inicio()})
			}
		})
	}
	 */
}

object multiplicador{
	var property numero
 
}

object listaBayas{
	var property lista = []
}
//repite mucho factor = multiplicador, demasiados mensajes. ademas si aplica a todos tendria que repetir eso mil veces
//

object nivelFacil inherits Nivel { // y si la dificultad cambiase el comportamiento de zombies? 
	  // es utilizado en el comportamiento de los sujetos que se mueven en el mapa para variar su dificultad
	
	 
	override method inicio(){
		multiplicador.numero(2) // podria tambien pasando parametro multiplacador a cada instancia, 
		//pero seria mas corto que cada objeto conozca mensaje multiplicador.numero() y actue diferente
		super()
	 }
	
	override method spawnear() {
		
		//6.randomUpTo(12).times{ l => game.addVisual(new Arbol())}
		 
		4.randomUpTo(10).times{ l => listaBayas.lista().add(new BayasMedianas())} // guardo en una lista para que nube pregunte si se topa con una de las bayas
		listaBayas.lista().forEach{ l => game.addVisual(l)}
		8.times{ l => game.addVisual(new Arbol())}
		1.randomUpTo(3).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	}

}

object nivelDificil inherits Nivel{
	  // es utilizado en el comportamiento de los sujetos que se mueven en el mapa para variar su dificultad
	
	override method inicio(){
		multiplicador.numero(0.2) // podria tambien pasando parametro multiplacador a cada instancia, 
		//pero seria mas corto que cada objeto conozca mensaje multiplicador.numero() y actue diferente
		super()
	 }
	
	override method spawnear() {
		3.randomUpTo(6).times{ l => game.addVisual(new Arbol())}
		//4.times{ l => game.addVisual(new BayasMedianas())}
		2.randomUpTo(4).times{ l => listaBayas.lista().add(new BayasMedianas())} // guardo en una lista para que nube pregunte si se topa con una de las bayas
		listaBayas.lista().forEach{ l => game.addVisual(l)}
		6.randomUpTo(14).times{ l => game.addVisual(new Zombie( hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	}

}

object nivelNormal inherits Nivel {
 	override method inicio(){
		multiplicador.numero(1) // podria tambien pasando parametro multiplacador a cada instancia, 
		//pero seria mas corto que cada objeto conozca mensaje multiplicador.numero() y actue diferente
		super()
	 }
	override method spawnear() {
		4.randomUpTo(10).times{ l => game.addVisual(new Arbol())}
		//9.times{ l => game.addVisual(new BayasMedianas())}
		4.randomUpTo(9).times{ l => listaBayas.lista().add(new BayasMedianas())} // guardo en una lista para que nube pregunte si se topa con una de las bayas
		listaBayas.lista().forEach{ l => game.addVisual(l)}
		4.randomUpTo(7).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	}

}

object escenarioDerrota inherits Ventanas{  // nuevo nivel
	 
	const roca1 = new Roca()
	
	method inicio(razon){
		game.clear()
			// game.addVisualIn("derrota.png", game.origin())
		game.width(ancho)
		game.title("fideosConTuco-casero")
		game.height(alto)
		game.addVisualIn(roca1, game.center())
		game.say(roca1, "has perdido: " + razon) // razon de derrota.
		game.schedule(6000, {=>
			game.say(roca1, "presiona cualquier tecla para volver a comenzar")
			keyboard.any().onPressDo{ 
				game.removeTickEvent("dia cambia")
				game.clear() // como reinicio
				reloj.estado("dia")
				game.addVisual(new Cargando()) // es necesario?
				game.schedule(500, {=> seleccionDificultad.inicio()})
			}
		})
		
		}
}
class Cargando inherits Visual { // pasar a clase

	method image() = "cargandoChico.png"
	
	method position() = game.at(8, 13)

	method cobrarVida() {
	}

	method esAtravesable() = true

}

class PantallaNegra inherits Visual { // pasar a clase

	method image() = "pantallaCarga1.gif"

	method position() = game.origin()

	method cobrarVida() {
	}

}

class Horario inherits Visual {

	var property tiempoDelDia = 20000
	var property position = game.origin()
	var property estado = dia // polimorfismo? estado.ejecutar()

	method image() {
		/*  
		if (estado == "dia") {
			return "escenaDiaGrande.png"
		}
		return "escenaNocheGrande.png"
		 */
		return estado.getImagen() // probar
	}
	
	method quedaTiempoDisponible(nro) { //
		return tiempoDelDia - nro >= 1
	}
  
	method esDeDia() {
		return (estado.equals(dia))
	}
	 
	//method comportamiento       estado.cambiarHorario()
	method cobrarVida() {
		game.onTick(tiempoDelDia, "dia cambia", {=>
			/*  
			if (estado == "dia") { // probar ocn objeto en vez de string
				self.cambiar()
					// nivel.visualesComportamiento().forEach{ v => v.comportamientoNoche(self)}
				game.allVisuals().forEach{ v => v.comportamientoNoche(self)}
			} else {
				self.cambiar()
					//
					// nivel.visualesComportamiento().forEach{ v => v.comportamientoDia(self)}   
				game.allVisuals().forEach{ v => v.comportamientoDia(self)} // probar si tilda
			}*/
			var estadoSiguiente = estado.escenarioSiguiente()
			 self.cambiarEstado(estadoSiguiente) // estado dia cambia a noche, noche a dia
			 estadoSiguiente.ejecutar(self) 
		})
	}
	
	method cambiarEstado(nuevoEstado){
		estado = nuevoEstado
	}
	method esAtravesable() {
		return true
	}

}

object dia{
	method escenarioSiguiente() = noche
	method ejecutar(phorario){
		 
		game.allVisuals().forEach{ v => v.comportamientoDia(phorario)} 
	}
	
	
	
	method getImagen() = "escenaDiaGrande.png"
	
}

object noche{
	method escenarioSiguiente() = dia
	method ejecutar(phorario){
		game.allVisuals().forEach{ v => v.comportamientoNoche(phorario)}
	}
	
	method getImagen() = "escenaNocheGrande.png"
}


 
