import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import fabricaSujetos.*
import nivelPrueba.*
import escenarioDerrota.*
import nivelPrueba.*
import seleccionDificultad.*

object seleccionJugadores inherits Ventanas { // pantalla de seleccion jugadores

	var property seleccion = botonUnJugador

	method inicio() {
		self.configurarPantalla()
		game.title("fideosConTuco  X salir / L nueva dificultad / C interactuar")
		game.addVisualIn(pantallaNegra, game.origin())
		game.addVisualIn(carteleraJugadores, game.at(4, 10))
		game.addVisualIn(guiaDificultad, game.origin())
		game.addVisualIn(botonUnJugador, game.at(4, 7))
		 
		game.addVisualIn(botonDosJugadores, game.at(4, 4))
		self.configurarTeclado()
	}

	method configurarPantalla() {
		game.clear()
		game.height(15)
		game.width(15)
	}
	
	method configurarTeclado() { // mover con las flechas pasa de un objeto a otro, seleccionar ejecuta el nivel.
		keyboard.x().onPressDo({ game.stop()})
		keyboard.up().onPressDo({ new Sonido().sonidoMenu().play()
			seleccion.quitarMarca() // quita marca a seleccion actual 
			seleccion.siguiente().remarcar() // pone marca en seleccion siguiente
			self.nuevaSeleccion(seleccion.siguiente()) // nueva dificultad para
		})
		keyboard.down().onPressDo({ new Sonido().sonidoMenu().play()
			seleccion.quitarMarca() // quita marca a seleccion actual 
			seleccion.anterior().remarcar() // pone marca en seleccion siguiente
			self.nuevaSeleccion(seleccion.anterior()) // nueva dificultad para
		})
		keyboard.enter().onPressDo({ seleccion.seleccionar()})
	}

	method nuevaSeleccion(pseleccion) {
		seleccion = pseleccion
	}

}

object carteleraJugadores {

	method image() = "carteleraJugadores.png"

}

object botonUnJugador { // candidato a clase con dificil

	var property estaRemarcado = true

	method image() { // podria resumirse en clase
		if (not estaRemarcado) {
			return "1JugadorB.png"
		} else {
			return "1JugadorRemarcadoB.png"
		}
	}

	method quitarMarca() {
		estaRemarcado = false
	}

	method remarcar() { // le quita la marca a uno anterior, y  remarca uno nuevo,
		estaRemarcado = true
	}

	method siguiente() = botonDosJugadores // arriba

	method anterior() = botonDosJugadores // abajo

	method seleccionar() {
		game.clear()
		modoJugadores.eleccion(unJugador) // recuerda que seleccion se toma para utilizarla al crear nivel con polimorfismo
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		game.schedule(1, {=> seleccionDificultad.inicio()})
	}

}

object botonDosJugadores {

	var property estaRemarcado = false

	method image() { // podria resumirse en clase
		if (not estaRemarcado) {
			return "2JugadoresB.png"
		} else {
			return "2JugadoresRemarcado.png"
		}
	}

	method quitarMarca() {
		estaRemarcado = false
	}

	method remarcar() { // le quita la marca a uno anterior, y  remarca uno nuevo,
		estaRemarcado = true
	}

	method siguiente() = botonUnJugador// arriba

	method anterior() = botonUnJugador // abajo

	method seleccionar() {
		game.clear()
		modoJugadores.eleccion(dosJugadores) // recuerda que seleccion se toma para utilizarla al crear nivel con polimorfismo
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		game.schedule(1, {=> seleccionDificultad.inicio()})
	}

}

object unJugador { // configuracion teclas unJugador

	method configurarTeclasExtras() { // clase nivel ya configura personaje1
	// no hace nada
	}
	method iniciar(){
		
	}
	method agregarVisuales() { // el visual de personaje ya fue añadido por clase Nivel
	// no hace nada 
	}

}

 
 
  
object dosJugadores { // wasd teclado


const p2 = new PersonajePrincipal(
	position = game.at(7,3),
	image = "personaje21.png",
	imagenPrincipal = "personaje21.png",
	imagenPasoDado = "personaje2.png",
	accion1 = "accion3.png",
	accion2 = "accion4.png"
)
 	
 	
	method iniciar() {
 		
		game.addVisual(p2)
		game.showAttributes(p2)
		game.addVisualIn(guiaJugadorDos, game.at(7,0))
		game.schedule(reloj.tiempoDelDia() / 2, {=> game.removeVisual(guiaJugadorDos)})
	 	self.configurarTeclasExtras()
		
	}

	method puedeMoverse(pos) { // si hay una animacion (para no cortarla con la animacion de movimiento) o si hay algo en esa direccion que no es atravesable
		return   ( (p2.puedeMoverseA(pos))   and (not p2.estaAnimando()))
	}

	method configurarTeclasExtras() {
	 	keyboard.c().onPressDo{ p2.interactuarPosicion()} // c tecla compartida
	//	keyboard.f().onPressDo{ p2.interactuarPosicion()}
		
		keyboard.w().onPressDo({ 
			var posSiguiente = p2.position().up(1)
		 	if (self.puedeMoverse(posSiguiente)) {
				p2.position(posSiguiente)
				p2.efectoDeCaminar() // setter energia e imagen, delego cambio a posicionNueva a game.addVisualCharacter por rendimiento	
				p2.hacerPasos() // cambio de visual
		 	}
		})
		keyboard.s().onPressDo({ 
			var posSiguiente = p2.position().down(1)
		 	if (self.puedeMoverse(posSiguiente)) {
				p2.position(posSiguiente)
				p2.efectoDeCaminar() // setter energia e imagen, delego cambio a posicionNueva a game.addVisualCharacter por rendimiento	
				p2.hacerPasos() // cambio de visual
		 	}
		})
		
		keyboard.a().onPressDo({ 
			var posSiguiente = p2.position().left(1)
		 	if (self.puedeMoverse(posSiguiente)) {
				p2.position(posSiguiente)
				p2.efectoDeCaminar() // setter energia e imagen, delego cambio a posicionNueva a game.addVisualCharacter por rendimiento	
				p2.hacerPasos() // cambio de visual
		 	}
		})
		
		
		keyboard.d().onPressDo({ 
			var posSiguiente = p2.position().right(1)
		 	if (self.puedeMoverse(posSiguiente)) {
				p2.position(posSiguiente)
				p2.efectoDeCaminar() // setter energia e imagen, delego cambio a posicionNueva a game.addVisualCharacter por rendimiento	
				p2.hacerPasos() // cambio de visual
		 	}
		})
		// Repite logica en cada tecla
		
		} 

}

object modoJugadores { // seleccion guardada de usuario

	var property eleccion

}


 
 