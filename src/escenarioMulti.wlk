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

class BotonJugador inherits Boton{ // el boton jugador tiene una logica de funcionamiento distinta(guarda la decision) y pasa a menu dificultad
	override method seleccionar(){
		super()
		modoJugadores.eleccion(seleccion) // guarda decision
		game.schedule(1, {=> seleccionDificultad.inicio()}) //
	}
}
 
const botonDosJugadores = new BotonJugador( // wollok.lang.StackOverflowException: null
	imagen1 = "2JugadoresB.png",
	imagen2 = "2JugadoresRemarcado.png",
	siguiente = 0, // wollok.lang.StackOverflowException: null. BotonUnJugador aun no existe, tiempo de ejecucion
	anterior = 0, // utilizo indice porque si utilizo referencias botonUnJugador aun no fue creada?
	seleccion = dosJugadores,
	 position =  game.at(4, 4)
)
 
   
const botonUnJugador = new BotonJugador( // mas facil si es necesario hacer muchos botones
	imagen1 = "1JugadorB.png",
	imagen2 = "1JugadorRemarcadoB.png",
	estaRemarcado = true,
 	siguiente = 1, // si fueran 3 decisiones, seria siguiente = 1, anterior = 2
  	anterior = 1,
	seleccion = unJugador,
	position =  game.at(4, 7)
) 


 
object seleccionJugadores inherits PantallaSeleccion(
	 seleccion = botonUnJugador,
	 listaDeBotones = [botonUnJugador,
	 				   botonDosJugadores
	 				  ]
) { // pantalla de seleccion jugadores, 
//podria compartir clase con  pantalla de dificultad

 	
	 
	method inicio() {
		 
		self.configurarPantalla()
	 	game.title("fideosConTuco  X salir / L nueva dificultad / C interactuar")
 
		game.addVisual(new VisualUI(image = "pantallaNegra.png",  position = game.origin()))
		game.addVisual(new VisualUI(image ="carteleraJugadores.png", position = game.at(4,10) ))
 
		game.addVisual(new VisualUI(position = game.at(4,10), image = "carteleraJugadores.png"))
		game.addVisual(new VisualUI(image ="Screenshot_8.png", position = game.origin() ))
 
		
		game.addVisual(botonUnJugador)
		 
	    game.addVisual(botonDosJugadores)
		self.configurarTeclado()
	}

	method configurarPantalla() {
		game.clear()
		game.height(15)
		game.width(15)
	}
	 
	 

}
/* 
object carteleraJugadores {

	method image() = "carteleraJugadores.png"

}
*/


 
  



object unJugador { // configuracion teclas unJugador

	method configurarTeclasExtras() { // clase nivel ya configura personaje1
	// no hace nada
	}
	
	method inicio(){
		modoJugadores.eleccion(self)
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
 	
 	method inicio(){
		modoJugadores.eleccion(self)
	}
 	
	method iniciar() {
 		
		game.addVisual(p2)
		game.showAttributes(p2)
		//game.addVisualIn(guiaJugadorDos, game.at(7,0))
		game.addVisual(guiaJugadorDos)
		game.schedule(reloj.tiempoDelDia() / 2, {=> game.removeVisual(guiaJugadorDos)})
	 	self.configurarTeclasExtras()
		
	}

	method puedeMoverse(pos) { // si hay una animacion (para no cortarla con la animacion de movimiento) o si hay algo en esa direccion que no es atravesable
		return   ( (p2.puedeMoverseA(pos))   and (not p2.estaAnimando()))
	}
	
	method moverse(nuevaPos){ // rever
		if (self.puedeMoverse(nuevaPos)){  
			p2.position(nuevaPos)
			p2.efectoDeCaminar() // setter energia e imagen, delego cambio a posicionNueva a game.addVisualCharacter por rendimiento	
			p2.hacerPasos() // cambio de visual
		}
	}
	
	
	method configurarTeclasExtras() {
	 	keyboard.c().onPressDo{ p2.interactuarPosicion()} // c tecla compartida
	//	keyboard.f().onPressDo{ p2.interactuarPosicion()}
		
		keyboard.w().onPressDo({  
	 //	var posSiguiente = p2.position().up(1)
			var posSiguiente = game.at(p2.position().x(), p2.position().y() + 1)
			self.moverse(posSiguiente)
		})
		
		keyboard.s().onPressDo({ 
			//var posSiguiente = p2.position().down(1)
		 	var posSiguiente = game.at(p2.position().x(), p2.position().y() - 1)
		 	self.moverse(posSiguiente)
		 	}
		)
		
		keyboard.a().onPressDo({ 
		//	var posSiguiente = p2.position().left(1)
		 	var posSiguiente = game.at(p2.position().x() - 1, p2.position().y())
		 	self.moverse(posSiguiente)
		 	})
		//})
		
		
		keyboard.d().onPressDo({ 
		//	var posSiguiente = p2.position().right(1)
		 	var posSiguiente = game.at(p2.position().x() + 1, p2.position().y())
		 	self.moverse(posSiguiente)
		 	}
		//})
		// Repite logica en cada tecla
		
		)
		}

}

object modoJugadores { // seleccion guardada de usuario

	var property eleccion

}


 
 