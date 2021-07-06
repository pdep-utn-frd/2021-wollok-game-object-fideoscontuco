import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import fabricaSujetos.*
import nivelPrueba.*

object seleccionDificultad inherits Ventanas { // como se podra usar el mouse?

	var property dificultad = facil

	method inicio() { // pantalla inicial de seleccion de dificultades
		game.height(15)
		game.width(15)
			// game.boardGround("tileNegro.png")
		game.title("fideosConTuco  X salir / L nueva dificultad / C interactuar")
		game.addVisualIn(pantallaNegra, game.origin())
		game.addVisualIn(elegirDif, game.at(4, 12))
		game.addVisualIn(guiaDificultad, game.origin())
		game.addVisual(dificil)
		game.addVisual(facil)
		game.addVisual(normal)
		self.configurarTeclado()
	}

	method configurarTeclado() { // mover con las flechas pasa de un objeto a otro, seleccionar ejecuta el nivel.
		keyboard.x().onPressDo({ game.stop()})
		keyboard.up().onPressDo({ new Sonido().sonidoMenu().play()
			dificultad.quitarMarca() // quita marca a dificultad actual 
			dificultad.siguiente().remarcar() // pone marca en dificultad siguiente
			self.nuevaDificultad(dificultad.siguiente()) // nueva dificultad para
		})
		keyboard.down().onPressDo({ new Sonido().sonidoMenu().play()
			dificultad.quitarMarca() // quita marca a dificultad actual 
			dificultad.anterior().remarcar() // pone marca en dificultad siguiente
			self.nuevaDificultad(dificultad.anterior()) // nueva dificultad para
		})
		keyboard.enter().onPressDo({ dificultad.seleccionar()})
	}

	// estaria bueno una confirmacion, tipo.  SEGURO Y N  en una ventana.
	method nuevaDificultad(nuevaDificultad) {
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

	method anterior() = dificil

	method remarcar() {
		estaRemarcado = true
	}

	method quitarMarca() {
		estaRemarcado = false
	}

	method seleccionar() {
		game.clear()
		game.title("sdsdsdsd")
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		game.schedule(1, {=> nivelFacil.inicio()})
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

	method quitarMarca() {
		estaRemarcado = false
	}

	method remarcar() { // le quita la marca a uno anterior, y  remarca uno nuevo,
		estaRemarcado = true
	}

	method siguiente() = facil

	method anterior() = normal

	method seleccionar() {
		// preguntar si esta seguro?
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

	method quitarMarca() {
		estaRemarcado = false
	}

	method siguiente() = dificil

	method anterior() = facil

	method remarcar() {
		estaRemarcado = true
	}

	method seleccionar() {
		game.clear()
		game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		game.schedule(1, {=> nivelNormal.inicio()})
	}

}