import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import fabricaSujetos.*
import nivelPrueba.*
import escenarioDerrota.*

class PantallaSeleccion inherits Ventanas { // utilizado para evitar logica repetida entre niveles de seleccion de dificultad/jugadores

	var property seleccionActual = null
	var property listaDeBotones = []

	method configurarTeclado() { // mover con las flechas pasa de un objeto a otro, seleccionar ejecuta el nivel.
		keyboard.x().onPressDo({ game.stop()})
		keyboard.up().onPressDo({ const seleccionSiguiente = listaDeBotones.get(seleccionActual.siguiente())
			self.efectosSeleccion(seleccionSiguiente)
		})
		keyboard.down().onPressDo({ const seleccionAnterior = listaDeBotones.get(seleccionActual.anterior())
			self.efectosSeleccion(seleccionAnterior)
		})
		keyboard.enter().onPressDo({ seleccionActual.seleccionar()}) // seleccion elegir..
	}

	method hacerSonido() {
		const sonidoMenu = game.sound("menuSeleccion.ogg")
		sonidoMenu.play()
	}

	method remarcarNuevo(pSeleccion) {
		seleccionActual.quitarMarca()
		self.nuevaSeleccion(pSeleccion)
		seleccionActual.remarcar()
	}

	method efectosSeleccion(pSeleccion) {
		self.hacerSonido()
		self.remarcarNuevo(pSeleccion)
	}

	method nuevaSeleccion(nuevaSeleccion) {
		seleccionActual = nuevaSeleccion
	}

}

object seleccionDificultad inherits PantallaSeleccion(seleccionActual = botonFacil, listaDeBotones = [ botonFacil, // segun el indice que devuelve mensaje sigueinte o anterior se elige el boton
	botonNormal, botonDificil ]) {

	method inicio() { // pantalla inicial de seleccion de dificultades
		game.addVisual(new VisualUI(image = "pantallaNegra.png", position = game.origin()))
		game.addVisual(new VisualUI(image = "elegirDif.png", position = game.at(4, 12)))
		game.addVisual(new VisualUI(image = "Screenshot_8.png", position = game.origin())) // guia
		game.addVisual(botonDificil)
		game.addVisual(botonFacil)
		game.addVisual(botonNormal)
		self.configurarTeclado()
	}

}

// botones
class BotonDificultad inherits Boton {

	override method seleccionar() {
		super()
		game.schedule(1, {=> self.seleccion().inicio()})
	}

}

class Boton inherits Visual {

	var property estaRemarcado = false
	var property position = null
	var property imagen1 = null
	var property imagen2 = null
	var property siguiente = null
	var property anterior = null
	var property seleccion = null

	method seleccion()

	method remarcar() { // c 
		estaRemarcado = true
	}

	method quitarMarca() { // c 
		estaRemarcado = false
	}

	method seleccionar() { // super
		game.clear()
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
	}

	method image() = if (not estaRemarcado) imagen1 else imagen2

}

object botonFacil inherits BotonDificultad(
	position = game.at(4, 3), 
	estaRemarcado = true, 
	imagen1 = "facil2.png", 
	imagen2 = "facilRemarcado2.png", 
	siguiente = 1, // si utilizo siguiente = botonDificil, la referencia aun no existe,wollok.lang.StackOverflowException: null 
	anterior = 2) {

	override method seleccion() = new NivelFacil()

}

object botonDificil inherits BotonDificultad(
	position = game.at(4, 9), 
	imagen1 = "dificil.png", 
	imagen2 = "dificilRemarcado.png", 
	siguiente = 0, 
	anterior = 1
) {

	override method seleccion() = new NivelDificil()

}

object botonNormal inherits BotonDificultad(
	position = game.at(4, 6), 
	imagen1 = "normal.png", 
	imagen2 = "normalRemarcado.png", 
	siguiente = 2, 
	anterior = 0
) {

	override method seleccion() = new NivelNormal()

}

// Se podria vincular niveles con sus respectivos visuales, con un atributo  