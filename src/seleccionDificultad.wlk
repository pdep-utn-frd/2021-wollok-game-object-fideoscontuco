import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import fabricaSujetos.*
import nivelPrueba.*
import escenarioDerrota.*



class PantallaSeleccion inherits Ventanas{ // utilizado para evitar logica repetida entre niveles de seleccion de dificultad/jugadores
	var property seleccion = null
 
	var property listaDeBotones = []
	
	
	method configurarTeclado() { // mover con las flechas pasa de un objeto a otro, seleccionar ejecuta el nivel.
		keyboard.x().onPressDo({ game.stop()})
		keyboard.up().onPressDo({ 
			var seleccionSiguiente = listaDeBotones.get(seleccion.siguiente())
		    self.efectosSeleccion(seleccionSiguiente )
		})
		keyboard.down().onPressDo({  
			var seleccionAnterior = listaDeBotones.get(seleccion.anterior())
			self.efectosSeleccion(seleccionAnterior)
			
		})
		keyboard.enter().onPressDo({ seleccion.seleccionar()}) // seleccion elegir..
	}
	
	method hacerSonido(){
		const sonidoMenu = game.sound("menuSeleccion.ogg") 
		sonidoMenu.play() 
	}
	
	method remarcarNuevo(pSeleccion){
		seleccion.quitarMarca() 
		self.nuevaSeleccion(pSeleccion)
		seleccion.remarcar() 
	}
	
	method efectosSeleccion(pSeleccion){
		self.hacerSonido()
		self.remarcarNuevo(pSeleccion) 
	}
	
		
	method nuevaSeleccion(nuevaSeleccion) {
		seleccion = nuevaSeleccion
	}
}


object seleccionDificultad inherits PantallaSeleccion(
	seleccion = botonFacil,
	listaDeBotones = [botonFacil, // segun el indice que devuelve mensaje sigueinte o anterior se elige el boton
					  botonNormal,
					  botonDificil
						 
	]){
	 
	method inicio() { // pantalla inicial de seleccion de dificultades
 

	 	game.addVisual(new VisualUI(image = "pantallaNegra.png", position = game.origin()))
	 	game.addVisual(new VisualUI(image = "elegirDif.png", position = game.at(4,12))) 
	  	game.addVisual(new VisualUI(image = "Screenshot_8.png", position = game.origin())) // guia

	 	
	 	
	 	game.addVisual(botonDificil)
	 	game.addVisual(botonFacil)
	 	game.addVisual(botonNormal)
	 	self.configurarTeclado()
	}
	 
 
}




// botones
 

class BotonDificultad inherits Boton{
	override method seleccionar(){
		super()
		game.schedule(1, {=> seleccion.inicio()})
	}
}

class Boton inherits Visual{
	var property estaRemarcado = false 
	var property position = null
	var property imagen1 = null
	var property imagen2 = null
	var property siguiente = null
	var property anterior = null
	var property seleccion = null
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


const botonFacil = new BotonDificultad( 
	position = game.at(4,3), 
	estaRemarcado = true,
	imagen1= "facil2.png",
	imagen2= "facilRemarcado2.png",
	siguiente = 1, // si utilizo siguiente = botonDificil, la referencia aun no existe,wollok.lang.StackOverflowException: null 
	anterior = 2,
	seleccion = nivelFacil
)  

const botonDificil = new BotonDificultad(
	position = game.at(4,9), 
	imagen1= "dificil.png",
	imagen2= "dificilRemarcado.png",
	siguiente = 0,
	anterior = 1,
	seleccion = nivelDificil
)  

const botonNormal = new BotonDificultad(
	position = game.at(4,6),
	imagen1= "normal.png",
	imagen2= "normalRemarcado.png",
	siguiente = 2,
	anterior = 0,
	seleccion = nivelNormal
)

// Se podria vincular niveles con sus respectivos visuales, con un atributo